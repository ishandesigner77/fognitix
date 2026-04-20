#include "FilmGrainEffect.h"

namespace Fognitix::Effects {

FilmGrainEffect::FilmGrainEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view FilmGrainEffect::typeId() const noexcept
{
    return "film_grain_effect";
}

void FilmGrainEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
