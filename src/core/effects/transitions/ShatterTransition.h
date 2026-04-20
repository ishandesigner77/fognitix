#pragma once
#ifndef FOGNITIX_SHATTER_TRANSITION_H
#define FOGNITIX_SHATTER_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ShatterTransition final : public EffectBase {
public:
    explicit ShatterTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
