#pragma once
#ifndef FOGNITIX_AUTO_DUCK_EFFECT_H
#define FOGNITIX_AUTO_DUCK_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class AutoDuckEffect final : public EffectBase {
public:
    explicit AutoDuckEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
