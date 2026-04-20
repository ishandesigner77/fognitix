#pragma once
#ifndef FOGNITIX_COLOR_WHEELS_EFFECT_H
#define FOGNITIX_COLOR_WHEELS_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ColorWheelsEffect final : public EffectBase {
public:
    explicit ColorWheelsEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
