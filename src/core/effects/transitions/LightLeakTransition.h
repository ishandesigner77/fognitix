#pragma once
#ifndef FOGNITIX_LIGHT_LEAK_TRANSITION_H
#define FOGNITIX_LIGHT_LEAK_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class LightLeakTransition final : public EffectBase {
public:
    explicit LightLeakTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
