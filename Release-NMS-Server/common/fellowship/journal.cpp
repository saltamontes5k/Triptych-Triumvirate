#include "journal.h"
#include "../database.h"
#include <string>
namespace Fellowship {
bool PersistCombatExperience(Database& db,uint32_t c,uint64_t connection,const ExperienceState& before,const ExperienceState& after){
 if(!c||db.GetStatus()!=DBcore::Connected)return false;
 auto check=db.QueryDatabase(std::string("SELECT CONNECTION_ID(),@@in_transaction"),false);
 if(!check.Success()||check.RowCount()!=1||std::stoull(check.begin()[0])!=connection||!std::stoul(check.begin()[1]))return false;
 auto saved=db.QueryDatabase("UPDATE character_data SET exp="+std::to_string(after.normal)+",aa_exp="+std::to_string(after.aa)+",aa_points="+std::to_string(after.aa_points)+",aa_points_spent="+std::to_string(after.aa_spent)+",level="+std::to_string(after.level)+",level2="+std::to_string(after.level2)+",points="+std::to_string(after.points)+",e_percent_to_aa="+std::to_string(after.percent_to_aa)+" WHERE id="+std::to_string(c)+" AND deleted_at IS NULL",false);
 if(!saved.Success()||saved.RowsAffected()!=1)return false;
 auto receipt=db.QueryDatabase("INSERT INTO fellowship_xp_commits(character_id,normal_before,normal_after,aa_before,aa_after,aa_points_before,aa_points_after) VALUES ("+std::to_string(c)+","+std::to_string(before.normal)+","+std::to_string(after.normal)+","+std::to_string(before.aa)+","+std::to_string(after.aa)+","+std::to_string(before.aa_points)+","+std::to_string(after.aa_points)+")",false);
 if(!receipt.Success())return false;
 auto oldest=db.QueryDatabase("SELECT id FROM fellowship_xp_commits WHERE character_id="+std::to_string(c)+" ORDER BY id DESC LIMIT 1 OFFSET "+std::to_string(ExperienceReceiptRetention-1),false);
 if(!oldest.Success())return false;
 if(oldest.RowCount()){
  auto trimmed=db.QueryDatabase("DELETE FROM fellowship_xp_commits WHERE character_id="+std::to_string(c)+" AND id<"+std::to_string(std::stoull(oldest.begin()[0])),false);
  if(!trimmed.Success())return false;
 }
 return true;
}
}
