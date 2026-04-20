#include "CameraShakeEffect.h"

namespace Fognitix::Effects {

CameraShakeEffect::CameraShakeEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view CameraShakeEffect::typeId() const noexcept
{
    return "camera_shake_effect";
}

void CameraShakeEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
