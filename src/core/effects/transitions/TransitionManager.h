#pragma once
#ifndef FOGNITIX_TRANSITION_MANAGER_H
#define FOGNITIX_TRANSITION_MANAGER_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class TransitionManager final : public EffectBase {
public:
    explicit TransitionManager(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
