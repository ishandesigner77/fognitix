#pragma once
#ifndef FOGNITIX_LOWER_THIRDS_EFFECT_H
#define FOGNITIX_LOWER_THIRDS_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class LowerThirdsEffect final : public EffectBase {
public:
    explicit LowerThirdsEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
