#include "FilmEmulationEffect.h"

namespace Fognitix::Effects {

FilmEmulationEffect::FilmEmulationEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view FilmEmulationEffect::typeId() const noexcept
{
    return "film_emulation_effect";
}

void FilmEmulationEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
