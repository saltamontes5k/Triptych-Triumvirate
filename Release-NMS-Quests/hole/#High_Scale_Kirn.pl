sub EVENT_SPAWN {
 if(plugin::HasClassName($client, "Shaman")) {
  quest::attack($name);
 }
}

#Submitted by: Jim Mills (Gilmore Girls`Is`Awesome`XOXO)