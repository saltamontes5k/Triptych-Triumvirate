#include "../client.h"

void command_attackmode(Client *c, const Seperator *sep)
{
	if (!c || !sep) {
		return;
	}

	std::string usage = "Usage: #attackmode [ranged, melee, or toggle].";

	if (sep->argnum == 0) {
		Client::AttackMode current_mode = c->GetAttackMode();
		std::string mode_str = current_mode == Client::RANGED ? "ranged" : "melee";
		c->Message(Chat::White, "Your current attack mode is: %s", mode_str.c_str());
		c->Message(Chat::White, "%s", usage.c_str());
		return;
	}

	if (sep->argnum > 0) {
		std::string arg = sep->arg[1];
		std::string arg_lower = Strings::ToLower(arg);

		if (arg_lower == "ranged") {
			c->SetAttackMode(Client::RANGED);
			c->Message(Chat::White, "Attack mode changed to: Ranged");
		}
		else if (arg_lower == "melee") {
			c->SetAttackMode(Client::MELEE);
			c->Message(Chat::White, "Attack mode changed to: Melee");
		}
		else if (arg_lower == "toggle") {
			Client::AttackMode current_mode = c->GetAttackMode();
			Client::AttackMode new_mode = (current_mode == Client::RANGED) ? Client::MELEE : Client::RANGED;
			c->SetAttackMode(new_mode);
			std::string mode_str = new_mode == Client::RANGED ? "Ranged" : "Melee";
			c->Message(Chat::White, "Attack mode changed to: %s", mode_str.c_str());
		}
		else {
			c->Message(Chat::White, "Invalid attack mode: %s", arg.c_str());
			c->Message(Chat::White, "%s", usage.c_str());
		}
	}
}