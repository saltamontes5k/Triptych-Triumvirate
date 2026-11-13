-- Proximity/range/timer values are configurable reconstruction settings, not
-- recovered original constants. NPC templates and SQL are not yet deployed.
return {
 enabled=true,
 kathryn=397100,
 actors={thug=397901,grabber=397902},
 spawn={x=-115,y=-305,z=181,heading=0},
 trigger_radius=40,owner_radius=250,vertical_radius=35,
 timeout_seconds=1200,wave_delay_seconds=150,retry_delay_seconds=120,
 tasks={
  [3040442]={waves={'thug'},kill_activities={1}},
  [3040445]={waves={'thug','grabber'},kill_activities={1,2},simultaneous=true},
  [3040448]={waves={'thug','grabber','thug','grabber'},kill_activities={1,2,3,4},note_item=97238}
 }
}
