#pragma once
#ifndef FOGNITIX_WHIP_PAN_TRANSITION_H
#define FOGNITIX_WHIP_PAN_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class WhipPanTransition final : public EffectBase {
public:
    explicit WhipPanTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
