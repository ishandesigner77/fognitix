#pragma once
#ifndef FOGNITIX_SATURATION_EFFECT_H
#define FOGNITIX_SATURATION_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class SaturationEffect final : public EffectBase {
public:
    explicit SaturationEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
