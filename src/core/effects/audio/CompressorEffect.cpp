#include "CompressorEffect.h"

namespace Fognitix::Effects {

CompressorEffect::CompressorEffect(std::string instanceId)
    : EffectBase(std::move(instanceId))
{
    configureFromDefaults();
}

std::string_view CompressorEffect::typeId() const noexcept
{
    return "compressor_effect";
}

void CompressorEffect::configureFromDefaults()
{
    // Defaults are overridden by EffectRegistry JSON at runtime.
}

} // namespace Fognitix::Effects
