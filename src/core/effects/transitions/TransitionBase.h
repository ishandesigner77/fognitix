#pragma once
#ifndef FOGNITIX_TRANSITION_BASE_H
#define FOGNITIX_TRANSITION_BASE_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class TransitionBase final : public EffectBase {
public:
    explicit TransitionBase(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
