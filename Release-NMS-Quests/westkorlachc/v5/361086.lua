local binding = require("rof2_dodh_prellius_binding")
if binding.task then
    event_damage_taken = require("rof2_dodh_prellius").damage_handler(binding)
end
