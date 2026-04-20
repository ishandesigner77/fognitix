#pragma once
#ifndef FOGNITIX_GLOW_EFFECT_H
#define FOGNITIX_GLOW_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class GlowEffect final : public EffectBase {
public:
    explicit GlowEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
