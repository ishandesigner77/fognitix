#pragma once
#ifndef FOGNITIX_COUNTER_EFFECT_H
#define FOGNITIX_COUNTER_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class CounterEffect final : public EffectBase {
public:
    explicit CounterEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
