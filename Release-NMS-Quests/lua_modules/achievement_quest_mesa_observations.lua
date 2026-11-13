local D=require('achievement_quest_mesa_observations_data')
local I=require('achievement_quest_mesa_inventory')
local M={}
local timer='achievement_mesa_observations'
local function yes(v)return v==true or v==1 end
local function active(c,t,a)return yes(c:IsTaskActive(t))and yes(c:IsTaskActivityActive(t,a))end
local function near(c,p)
 local x,y=c:GetX()-p.x,c:GetY()-p.y
 return x*x+y*y<=p.radius*p.radius and(not p.vertical or math.abs(c:GetZ()-p.z)<=p.vertical)
end
local function water(c,p)
 return math.abs(c:GetX()-p.x)<=p.half_x and math.abs(c:GetY()-p.y)<=p.half_y and math.abs(c:GetZ()-p.z)<=p.half_z
end
local function poll(c)
 if not D.enabled or eq.get_zone_id()~=397 or c:IsDead()then return false end
 local pending=false
 for _,p in ipairs(D.observations.points)do
  if active(c,D.observations.task,p.activity)then
   pending=true
   if near(c,p)then c:UpdateTaskActivity(D.observations.task,p.activity,1)end
  end
 end
 local p=D.letter
 if active(c,p.task,p.activity)then
  pending=true
  if near(c,p)then c:UpdateTaskActivity(p.task,p.activity,1)end
 end
 p=D.pond
 if active(c,p.task,p.activity)then
  pending=true
  -- Banked flask, being on the bank above the water, an occupied cursor and
  -- another task's old pond water cannot substitute for this real gather.
  if I.count(c,p.flask)>0 and near(c,p)and water(c,p.water)and I.give(c,p.output,p.quantity)then
   c:UpdateTaskActivity(p.task,p.activity,1)
  end
 end
 return pending
end
function M.resume(e)
 if poll(e.self)then e.self:SetTimer(timer,1)else e.self:StopTimer(timer)end
end
function M.timer(e)
 if e.timer~=timer then return false end
 if not poll(e.self)then e.self:StopTimer(timer)end
 return true
end
return M
