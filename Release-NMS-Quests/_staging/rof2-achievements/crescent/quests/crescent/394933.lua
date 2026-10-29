function event_spawn(e)eq.set_timer("expire",300000)end
function event_timer(e)if e.timer=="expire"then eq.depop()end end
