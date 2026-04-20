#pragma once
#ifndef FOGNITIX_COLOR_MATCH_EFFECT_H
#define FOGNITIX_COLOR_MATCH_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ColorMatchEffect final : public EffectBase {
public:
    explicit ColorMatchEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
