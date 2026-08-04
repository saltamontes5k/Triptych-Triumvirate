sub EVENT_SAY 
{ 
 if ($text=~ /Hail/i)
 {
    $client->IncrementAA(205);
    $client->Message(15, "You gained Endless Quiver!");
 } 
}

