-- Full installation enables the quest chain and corruption encounter.
-- These are internal server groups, not historical faction-award amounts.
return {
 enabled=true,
 zone=397,
 shade_type=397196,
 shade_spawn=112270,
 hostile_group=3040461,
 friendly_group=3040462,
 controller_timer='achievement_mesa_corruption',
 controller_interval=1,
 replacement_wait_ticks=5, -- bounded entity-removal safety guard, not a Live timer -- implementation scheduling, not a recovered Live timer
 -- Zero retains current native aggro/assist/stat fields. Do not invent ranges.
 -- Native loader maps zero DB aggro to70; zero here preserves that behavior.
 aggro_range=0,
 ai_recast_seconds=-1,
 aura_radius=200, -- labelled reconstruction from native spell range, not recovered original aura extent
 aura_tick_seconds=6, -- period reports say each game tick
 aura_timer='achievement_mesa_corruption_aura', -- native spell timing/defaults; original AI frequency unknown
 actors={
  [112191]=397157,
  [112208]=397168,
  [112227]=397178,
  [112230]=397180,
  [112231]=397180,
  [112232]=397181,
  [112234]=397182,
  [112235]=397183,
  [112237]=397183,
  [112238]=397183,
  [112245]=397186,
  [112246]=397181,
  [112249]=397188,
  [112252]=397181,
  [112259]=397193,
  [112260]=397188,
  [112261]=397188,
  [112264]=397188,
  [112265]=397186,
  [112273]=397183,
  [112282]=397181,
  [112288]=397180,
  [112290]=397203,
  [112293]=397178,
  [112307]=397211,
  [112319]=397183,
  [112323]=397183,
  [112327]=397216,
  [112329]=397218,
  [112332]=397220,
  [112333]=397221,
  [112334]=397180,
  [112339]=397157,
  [112340]=397220,
  [112345]=397218,
  [112360]=397225,
  [112368]=397226,
  [112372]=397182,
  [112393]=397168,
  [112402]=397235,
 },
 -- Period-reported spells, matched by exact name to the installed spell catalogue.
 -- AI priorities/types use the existing native behavior; original selection rates unknown.
 spells={
  {id=559,kind=1}, -- Ignite Bones
  {id=2014,kind=1}, -- Incinerate Bones
  {id=2545,kind=256}, -- Insidious Retrogression
  {id=133,kind=4}, -- Paralyzing Earth
  {id=12311,kind=2048}, -- Scream in Terror
  {id=9147,kind=256}, -- Air of Corruption; camp-wide aura geometry still unrecovered
 },
}
