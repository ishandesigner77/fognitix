#include "TextEffectBase.h"

namespace Fognitix::Effects {

TextEffectBase::TextEffectBase(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view TextEffectBase::typeId() const noexcept
{
    return "text_effect_base";
}

void TextEffectBase::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
