#pragma once

#include <cmath>

namespace EQ::GroundAura {

// Ground-ring coordinates originate in the client packet. Validate them before
// either distance comparisons or constructing a persistent world entity.
inline bool InRange(float cx, float cy, float cz, float x, float y, float z,
                    float maximum, float minimum)
{
	if (!std::isfinite(cx) || !std::isfinite(cy) || !std::isfinite(cz) ||
	    !std::isfinite(x) || !std::isfinite(y) || !std::isfinite(z) ||
	    !std::isfinite(maximum) || !std::isfinite(minimum) ||
	    maximum < 0 || minimum < 0 || minimum > maximum) {
		return false;
	}
	const double dx = static_cast<double>(x) - cx;
	const double dy = static_cast<double>(y) - cy;
	const double dz = static_cast<double>(z) - cz;
	const double distance = dx * dx + dy * dy + dz * dz;
	return distance <= static_cast<double>(maximum) * maximum &&
	       distance >= static_cast<double>(minimum) * minimum;
}

} // namespace EQ::GroundAura
