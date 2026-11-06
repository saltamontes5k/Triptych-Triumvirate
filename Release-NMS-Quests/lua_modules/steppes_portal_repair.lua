-- OFFLINE / DISABLED. Repair is adjacent content, never an HJ objective/reward shortcut.
local M={ENABLED=false}
function M.apply(previous,e)
  if not M.ENABLED then return previous,{},'disabled' end
  if not e.native_completed_cast or not e.validated_portal_volume or not e.charge_consumed then
    return previous,{},'unverified'
  end
  local amount=({[9483]=1,[9484]=2,[9485]=3})[e.spell_id]
  if not amount or not e.receipt then return previous,{},'wrong_spell_or_missing_receipt' end
  -- State must be persisted and serialized for the original open-world portal, not perchar.
  local s={percent=previous.percent,receipts={},threshold=previous.threshold}
  for k,v in pairs(previous.receipts) do s.receipts[k]=v end
  if s.receipts[e.receipt] then return previous,{},'duplicate' end
  if s.percent>=100 then return previous,{},'already_full_pending_reset_policy' end
  s.receipts[e.receipt]=true;s.percent=math.min(100,s.percent+amount)
  local out={}
  if s.percent==100 and not s.threshold then
    s.threshold=true
    out[1]={kind='raid_threshold_unimplemented'}
    -- Do not fabricate Pummelcrush/Demeton, a portal completion or a reset schedule.
  end
  return s,out
end
return M
