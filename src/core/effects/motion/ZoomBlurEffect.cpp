#include "ZoomBlurEffect.h"

namespace Fognitix::Effects {

ZoomBlurEffect::ZoomBlurEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view ZoomBlurEffect::typeId() const noexcept
{
    return "zoom_blur_effect";
}

void ZoomBlurEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
