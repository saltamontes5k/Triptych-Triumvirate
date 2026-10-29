#include "vitality.h"
#include "../database.h"
#include <algorithm>
#include <limits>
namespace Fellowship {
namespace {
struct Failure { Error error; };
MySQLRequestResult Q(Database& db, const std::string& sql) {
 if(db.GetStatus()!=DBcore::Connected)throw Failure{Error::DatabaseFailure};
 auto r=db.QueryDatabase(sql,false); if(!r.Success()) throw Failure{Error::DatabaseFailure}; return r;
}
uint64_t N(const char* s) { if(!s) throw Failure{Error::DatabaseFailure};return std::stoull(s); }
struct Tx {
 Database& db; bool active=false; uint64_t connection=0;
 explicit Tx(Database& d):db(d) {
  auto r=Q(db,"SELECT @@in_transaction");if(r.RowCount()!=1||N(r.begin()[0]))throw Failure{Error::InvalidArgument};
  Q(db,"START TRANSACTION");active=true;
  try{auto identity=Q(db,"SELECT CONNECTION_ID(),@@in_transaction");connection=N(identity.begin()[0]);
  if(!N(identity.begin()[1]))throw Failure{Error::DatabaseFailure};
  auto g=Q(db,"SELECT id FROM fellowship_guard WHERE id=1 FOR UPDATE");if(g.RowCount()!=1)throw Failure{Error::DatabaseFailure};}
  catch(...){if(db.GetStatus()==DBcore::Connected)db.QueryDatabase(std::string("ROLLBACK"),false);active=false;throw;}
 }
 ~Tx(){if(active&&db.GetStatus()==DBcore::Connected)db.QueryDatabase(std::string("ROLLBACK"),false);}
 void Check(){auto r=Q(db,"SELECT CONNECTION_ID(),@@in_transaction");if(r.RowCount()!=1||N(r.begin()[0])!=connection||!N(r.begin()[1]))throw Failure{Error::DatabaseFailure};}
 void Commit(){Check();if(!db.QueryDatabase(std::string("COMMIT"),false).Success())throw Failure{Error::CommitUncertain};active=false;}
};
template<class T,class F> Result<T> Run(Database& db,F f){try{Tx tx(db);auto v=f();tx.Commit();return {std::move(v),Error::None};}catch(const Failure& x){return {{},x.error};}catch(...){return {{},Error::DatabaseFailure};}}
void Valid(Database& db,uint32_t id){if(!id)throw Failure{Error::InvalidArgument};auto r=Q(db,"SELECT c.id FROM character_data c JOIN account a ON a.id=c.account_id WHERE c.id="+std::to_string(id)+" AND c.deleted_at IS NULL");if(r.RowCount()!=1)throw Failure{Error::NotFound};}
void Ensure(Database& db,uint32_t id){Q(db,"INSERT IGNORE INTO fellowship_vitality(character_id) VALUES ("+std::to_string(id)+")");}
VitalityPools Load(Database& db,uint32_t id){auto r=Q(db,"SELECT normal_pool,aa_pool,normal_cap,aa_cap FROM fellowship_vitality WHERE character_id="+std::to_string(id)+" FOR UPDATE");if(r.RowCount()!=1)throw Failure{Error::DatabaseFailure};auto x=r.begin();VitalityPools p;p.normal=N(x[0]);p.aa=N(x[1]);p.caps.normal=N(x[2]);p.caps.aa=N(x[3]);return p;}
void Save(Database& db,uint32_t id,const VitalityPools& p){Q(db,"UPDATE fellowship_vitality SET normal_pool="+std::to_string(p.normal)+",aa_pool="+std::to_string(p.aa)+",normal_cap="+std::to_string(p.caps.normal)+",aa_cap="+std::to_string(p.caps.aa)+" WHERE character_id="+std::to_string(id));}
VitalityPools Refresh(Database& db,uint32_t id,VitalityCaps caps){Ensure(db,id);auto p=Load(db,id);p.caps=caps;return p;}
bool Full(const VitalityPools& p){return !p.caps.normal || p.normal>=p.caps.normal || (p.caps.aa&&p.aa>=p.caps.aa);}
void AutoStop(Database& db,uint32_t id,const VitalityPools& p){
 if(!Full(p))return;
 auto r=Q(db,"UPDATE fellowship_members SET share_experience=0 WHERE character_id="+std::to_string(id)+" AND share_experience=1");
 if(r.RowsAffected())Q(db,"UPDATE fellowships f JOIN fellowship_members m ON m.fellowship_id=f.id SET f.revision=f.revision+1 WHERE m.character_id="+std::to_string(id));
}
uint64_t Bonus(uint64_t earned,uint64_t pool,uint32_t multiplier){if(!multiplier)return 0;auto limit=std::numeric_limits<uint64_t>::max();auto bound=earned>limit/multiplier?limit:earned*multiplier;return std::min({pool,bound,limit-earned});}
uint64_t Credit(uint64_t pool,uint64_t amount,uint64_t cap){if(pool>=cap)return pool;return pool+std::min(amount,cap-pool);}
}
Result<VitalityPools> VitalityService::Get(uint32_t c,VitalityCaps caps){
 // Polls normally read cached capacities without writes or the global guard.
 // A new row/capacity change falls back to the serialized mutation path.
 try {
  if(!c) return {{},Error::InvalidArgument};
  auto nested=Q(database_,"SELECT @@in_transaction");
  if(nested.RowCount()!=1||N(nested.begin()[0]))return {{},Error::InvalidArgument};
  auto r=Q(database_,"SELECT v.normal_pool,v.aa_pool,v.normal_cap,v.aa_cap,COALESCE(m.share_experience,0) FROM fellowship_vitality v JOIN character_data c ON c.id=v.character_id JOIN account a ON a.id=c.account_id LEFT JOIN fellowship_members m ON m.character_id=c.id WHERE c.deleted_at IS NULL AND v.character_id="+std::to_string(c));
  if(r.RowCount()==1){auto x=r.begin();VitalityPools p;p.normal=N(x[0]);p.aa=N(x[1]);p.caps.normal=N(x[2]);p.caps.aa=N(x[3]);if(p.caps.normal==caps.normal&&p.caps.aa==caps.aa&&!(N(x[4])&&Full(p)))return {p,Error::None};}
 }catch(...){return {{},Error::DatabaseFailure};}
 return Run<VitalityPools>(database_,[&]{Valid(database_,c);auto p=Refresh(database_,c,caps);Save(database_,c,p);AutoStop(database_,c,p);return p;});
}
Result<VitalityAward> VitalityService::ApplyCombat(uint32_t c,uint64_t normal,uint64_t aa,VitalityCaps caps,uint32_t nm,uint32_t am,const std::function<bool(const VitalityAward&)>& finalizer){
 return Run<VitalityAward>(database_,[&]{
  Valid(database_,c);auto pool=Refresh(database_,c,caps);AutoStop(database_,c,pool);VitalityAward out;
  // A capped member may have manually toggled sharing since its last poll.
  // Remove all capped recipients before choosing the divisor/donating XP.
  auto stopped=Q(database_,"UPDATE fellowship_members peer JOIN fellowship_members actor ON actor.fellowship_id=peer.fellowship_id JOIN fellowship_vitality v ON v.character_id=peer.character_id SET peer.share_experience=0 WHERE actor.character_id="+std::to_string(c)+" AND peer.share_experience=1 AND (v.normal_cap=0 OR v.normal_pool>=v.normal_cap OR (v.aa_cap>0 AND v.aa_pool>=v.aa_cap))");
  if(stopped.RowsAffected())Q(database_,"UPDATE fellowships f JOIN fellowship_members m ON m.fellowship_id=f.id SET f.revision=f.revision+1 WHERE m.character_id="+std::to_string(c));
  std::vector<uint32_t> participants;
  auto members=Q(database_,"SELECT peer.character_id FROM fellowship_members actor JOIN fellowship_members peer ON peer.fellowship_id=actor.fellowship_id JOIN character_data c ON c.id=peer.character_id AND c.deleted_at IS NULL WHERE actor.character_id="+std::to_string(c)+" AND actor.share_experience=1 AND peer.share_experience=1 ORDER BY peer.character_id");
  if(members.RowCount()>MaximumMembers)throw Failure{Error::DatabaseFailure};
  for(auto r=members.begin();r.operator!=(members.end());++r)participants.push_back(N(r[0]));
  auto count=participants.size();auto normal_share=count>1?normal/count:0;auto aa_share=count>1?aa/count:0;
  // Keep division remainder with the earner; the sum of retained and donated
  // ORIGINAL XP is exactly the input, before any capped credits are discarded.
  auto retained_normal=normal-normal_share*(count>1?count-1:0);
  auto retained_aa=aa-aa_share*(count>1?count-1:0);
  auto nb=Bonus(retained_normal,pool.normal,nm);auto ab=Bonus(retained_aa,pool.aa,am);
  // The caller bounds normal capacity by remaining progression room. Do not
  // consume a bonus that SetEXP would discard at the configured level ceiling.
  nb=std::min(nb,caps.normal>retained_normal?caps.normal-retained_normal:0);
  ab=std::min<uint64_t>(ab,caps.aa>retained_aa?caps.aa-retained_aa:0);
  nb=std::min(nb,caps.normal_award>retained_normal?caps.normal_award-retained_normal:0);
  ab=std::min(ab,caps.aa_award>retained_aa?caps.aa_award-retained_aa:0);
  pool.normal-=nb;pool.aa-=static_cast<uint32_t>(ab);
  out.normal=retained_normal+nb;out.aa=retained_aa+ab;Save(database_,c,pool);
  out.changed_characters.push_back(c);
  for(auto target:participants){if(target==c)continue;Ensure(database_,target);auto p=Load(database_,target);p.normal=Credit(p.normal,normal_share,p.caps.normal);p.aa=static_cast<uint32_t>(Credit(p.aa,aa_share,p.caps.aa));Save(database_,target,p);AutoStop(database_,target,p);out.changed_characters.push_back(target);}
  out.pools=pool;
  if(finalizer&&!finalizer(out))throw Failure{Error::DatabaseFailure};
  return out;
 });
}
Result<bool> VitalityService::Clear(uint32_t c){return Run<bool>(database_,[&]{if(!c)throw Failure{Error::InvalidArgument};Q(database_,"DELETE FROM fellowship_vitality WHERE character_id="+std::to_string(c));return true;});}
}
