#pragma once
#ifndef FOGNITIX_COMPRESSOR_EFFECT_H
#define FOGNITIX_COMPRESSOR_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class CompressorEffect final : public EffectBase {
public:
    explicit CompressorEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
