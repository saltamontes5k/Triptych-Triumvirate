#include "client.h"
#include "zone.h"
#include "../common/fellowship/vitality.h"
#include "../common/fellowship/journal.h"
#include "../common/rulesys.h"
#include <algorithm>
#include <cstdint>
#include <limits>
#include <vector>

extern Zone* zone;
namespace {
bool Ready(const Client& c) {
 return zone && c.CharacterID() && c.Connected() && c.ClientDataLoaded() &&
  c.ClientVersion() == EQ::versions::ClientVersion::RoF2;
}
uint64_t Add(uint64_t a, uint64_t b) {
 return a + std::min(b, std::numeric_limits<uint64_t>::max() - a);
}
uint64_t Multiply(uint64_t a, uint64_t b) {
 const auto limit=std::numeric_limits<uint64_t>::max();
 return b && a>limit/b ? limit : a*b;
}
uint64_t RemainingAA(Client& c) {
 if (c.GetLevel()<=50) return 0;
 const auto limit=RuleI(AA, UnusedAAPointCap);
 if (limit<0) return std::numeric_limits<uint64_t>::max();
 if (c.GetAAPoints()>=static_cast<uint32_t>(limit)) return 0;
 const auto points=static_cast<uint64_t>(limit)-c.GetAAPoints();
 const auto target=Multiply(points,c.GetRequiredAAExperience());
 return target>c.GetAAXP()?target-c.GetAAXP():0;
}
uint64_t RemainingNormal(Client& c) {
 const uint32_t level=c.GetLevel();
 auto maximum=RuleI(Character, MaxExpLevel);
 if(maximum<1)maximum=RuleI(Character, MaxLevel);
 if(c.GetClientMaxLevel())maximum=c.GetClientMaxLevel();
 if(!level||level>=255||maximum<1||maximum>=255)return 0;
 const auto boundary=RuleB(Character, KeepLevelOverMax)&&level>static_cast<uint32_t>(maximum)?level+1:static_cast<uint32_t>(maximum+1);
 const uint64_t ceiling=c.GetEXPForLevel(static_cast<uint16_t>(boundary));
 return ceiling!=0xFFFFFFFFULL&&ceiling>c.GetEXP()?ceiling-c.GetEXP():0;
}
Fellowship::VitalityCaps Caps(Client& c) {
 Fellowship::VitalityCaps caps;
 const uint32_t level = c.GetLevel();
 auto maximum = RuleI(Character, MaxExpLevel);
 if (maximum < 1) maximum = RuleI(Character, MaxLevel);
 if (c.GetClientMaxLevel()) maximum = c.GetClientMaxLevel();
 const uint64_t current = level && level<255 ? c.GetEXPForLevel(static_cast<uint8_t>(level)) : 0xFFFFFFFFULL;
 const uint64_t next = level && level<255 ? c.GetEXPForLevel(static_cast<uint8_t>(level + 1)) : 0xFFFFFFFFULL;
 // Server policy: ten current-level ranges, limited by the configured maximum
 // progression threshold. This approximates the native NumLevelsVitalityCap=10;
 // exact Live level/progression conversion has not been established.
 if (level && current!=0xFFFFFFFFULL && next!=0xFFFFFFFFULL && next > current && maximum >= 1 && maximum < 255) {
  uint64_t ceiling = c.GetEXPForLevel(static_cast<uint8_t>(maximum + 1));
  if (RuleB(Character, KeepLevelOverMax) && level > static_cast<uint32_t>(maximum)) ceiling = next;
  if (ceiling!=0xFFFFFFFFULL && ceiling > c.GetEXP()) caps.normal = std::min(Multiply(next-current,10),ceiling-c.GetEXP());
 }
 if (level > 50) {
  caps.aa = static_cast<uint32_t>(std::min<uint64_t>(
   RemainingAA(c),
   static_cast<uint64_t>(std::numeric_limits<int32_t>::max())));
 }
 const auto normal_kill_cap=RuleI(Character, ExperiencePercentCapPerKill);
 if(normal_kill_cap>=0&&current!=0xFFFFFFFFULL&&next!=0xFFFFFFFFULL&&next>current)
  caps.normal_award=Multiply(next-current,static_cast<uint64_t>(normal_kill_cap))/100;
 const auto aa_kill_cap=RuleI(AA, MaxAAEXPPerKill);
 if(aa_kill_cap>=0)caps.aa_award=static_cast<uint64_t>(aa_kill_cap);
 return caps;
}
std::vector<uint8_t> Encode(const Fellowship::VitalityPools& p) {
 // Handler0x4b7110 reads64-bit normal fields and low32 bits of AA slots.
 // HighAA words remain zero; native alignment/64-bit AA wire type is unresolved.
 std::vector<uint8_t> bytes(32,0);
 auto put=[&](size_t offset,uint64_t value){for(size_t i=0;i<8;++i)bytes[offset+i]=static_cast<uint8_t>(value>>(i*8));};
 put(0,p.normal);put(8,p.caps.normal);put(16,p.aa);put(24,p.caps.aa);return bytes;
}
}
void Client::RefreshFellowshipVitality() {
 if (!Ready(*this) || !RuleB(Custom, Fellowships) || !RuleB(Custom, FellowshipVitality)) return;
 Fellowship::VitalityService service(database);
 const auto result=service.Get(CharacterID(),Caps(*this));
 if (!result) return;
 auto bytes=Encode(result.value);
 if (bytes==m_fellowship_vitality_snapshot) return;
 EQApplicationPacket packet(OP_FellowshipVitality,bytes.size());
 std::copy(bytes.begin(),bytes.end(),packet.pBuffer);
 QueuePacket(&packet);
 m_fellowship_vitality_snapshot=std::move(bytes);
}
bool Client::ProcessFellowshipCombatExperience(ExpSource source,uint64 exp_total,uint64 aa_total,NPC* npc) {
 if (!RuleB(Custom, Fellowships) || !RuleB(Custom, FellowshipVitality)) return false;
 if (m_fellowship_xp_persistence_failed) return true;
 if (m_fellowship_xp_transaction_active || !Ready(*this)) return false;
 // Preserve the existing path for characters with neither membership nor a bank.
 bool bank=false;
 for (size_t i=0;i<m_fellowship_vitality_snapshot.size();++i)
  if ((i<8 || (i>=16&&i<20)) && m_fellowship_vitality_snapshot[i]) bank=true;
 if (!m_fellowship_id && !bank) return false;
 const uint64_t previous=GetEXP(),previous_aa=GetAAXP();
 const uint32_t previous_points=GetAAPoints();
 const auto caps=Caps(*this);
 const uint64_t earned=std::min<uint64_t>({exp_total>previous?exp_total-previous:0,RemainingNormal(*this),caps.normal_award});
 uint64_t aa_delta=aa_total>previous_aa?aa_total-previous_aa:0;
 aa_delta=std::min({aa_delta,RemainingAA(*this),caps.aa_award});
 if (!earned&&!aa_delta) return false;
 // Transactional persistence is valid only while all participating tables are
 // InnoDB. Refuse the award if installation/schema assumptions do not hold.
 auto engines=database.QueryDatabase(std::string("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name IN ('character_data','fellowship_guard','fellowship_members','fellowship_vitality','fellowship_xp_commits') AND engine='InnoDB'"),false);
 if (!engines.Success()||engines.RowCount()!=1||std::stoul(engines.begin()[0])!=5) {
  Message(Chat::Red,"Fellowship experience storage is unavailable; this combat award was withheld.");return true;
 }
 bool finalized=false;
 Fellowship::VitalityService service(database);
 const auto result=service.ApplyCombat(CharacterID(),earned,aa_delta,caps,4,2,[&](const Fellowship::VitalityAward& award) {
  auto identity=database.QueryDatabase(std::string("SELECT CONNECTION_ID(),@@in_transaction"),false);
  if (!identity.Success()||identity.RowCount()!=1||!std::stoul(identity.begin()[1])) return false;
  const auto connection=std::stoull(identity.begin()[0]);
  m_fellowship_xp_transaction_active=true;
  finalized=true;
  SetEXP(source,Add(previous,award.normal),Add(previous_aa,award.aa),false,npc);
  auto check=database.QueryDatabase(std::string("SELECT CONNECTION_ID(),@@in_transaction"),false);
  if (!check.Success()||check.RowCount()!=1||std::stoull(check.begin()[0])!=connection||!std::stoul(check.begin()[1])) return false;
  Fellowship::ExperienceState before;before.normal=previous;before.aa=previous_aa;before.aa_points=previous_points;
  Fellowship::ExperienceState after;
  after.normal=m_pp.exp;after.aa=m_pp.expAA;after.aa_points=m_pp.aapoints;after.aa_spent=m_pp.aapoints_spent;
  after.level=m_pp.level;after.level2=m_pp.level2;after.points=m_pp.points;after.percent_to_aa=m_epp.perAA;
  return Fellowship::PersistCombatExperience(database,CharacterID(),connection,before,after);
 });
 m_fellowship_xp_transaction_active=false;
 if (!result) {
  // Once SetEXP touched memory, reconnect must reload the authoritative commit
  // outcome. Save/SaveAA/SaveCharacterData are blocked for this failed session.
  if (finalized||result.error==Fellowship::Error::CommitUncertain) {
   m_fellowship_xp_persistence_failed=true;
   Kick("Fellowship XP transaction failed; reconnect to reload committed experience");
  } else Message(Chat::Red,"Fellowship experience could not be saved; this combat award was withheld.");
  return true;
 }
 RefreshFellowshipVitality();
 return true;
}
