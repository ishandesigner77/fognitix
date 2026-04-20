#include "TitleCardEffect.h"

namespace Fognitix::Effects {

TitleCardEffect::TitleCardEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view TitleCardEffect::typeId() const noexcept
{
    return "title_card_effect";
}

void TitleCardEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
