#pragma once
#ifndef FOGNITIX_COLOR_SPACE_EFFECT_H
#define FOGNITIX_COLOR_SPACE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ColorSpaceEffect final : public EffectBase {
public:
    explicit ColorSpaceEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
