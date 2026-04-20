#pragma once
#ifndef FOGNITIX_EXPOSURE_EFFECT_H
#define FOGNITIX_EXPOSURE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ExposureEffect final : public EffectBase {
public:
    explicit ExposureEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
