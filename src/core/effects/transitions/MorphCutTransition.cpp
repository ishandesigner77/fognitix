#include "MorphCutTransition.h"

namespace Fognitix::Effects {

MorphCutTransition::MorphCutTransition(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view MorphCutTransition::typeId() const noexcept
{
    return "morph_cut_transition";
}

void MorphCutTransition::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
