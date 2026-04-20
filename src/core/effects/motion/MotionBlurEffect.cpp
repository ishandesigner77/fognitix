#include "MotionBlurEffect.h"

namespace Fognitix::Effects {

MotionBlurEffect::MotionBlurEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view MotionBlurEffect::typeId() const noexcept
{
    return "motion_blur_effect";
}

void MotionBlurEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
