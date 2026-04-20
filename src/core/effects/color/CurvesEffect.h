#pragma once
#ifndef FOGNITIX_CURVES_EFFECT_H
#define FOGNITIX_CURVES_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class CurvesEffect final : public EffectBase {
public:
    explicit CurvesEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
