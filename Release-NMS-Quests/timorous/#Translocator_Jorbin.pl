#REVISED: Angelox
#Zone: timorous
sub EVENT_SAY { 
if ($text=~/Hail/i){quest::say("Hello there. We have most the ships working again. If you need to [travel to Butcherblock] or [travel to Overthere],  [travel to Oasis] or [travel to Firiona] I can help you with this."); }
if ($text=~/travel to butcherblock/i){quest::movepc(68,3168.92,851.92,11.66); }
if ($text=~/travel to firiona/i){quest::movepc(84,1417,-4335,-103,0); }
if ($text=~/travel to oasis/i){quest::movepc(37,-824,886,0,140); }
if ($text=~/travel to overthere/i){quest::movepc(93,2739,3428,-158,260); }
}