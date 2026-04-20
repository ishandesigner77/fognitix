#pragma once
#ifndef FOGNITIX_PAGE_TURN_TRANSITION_H
#define FOGNITIX_PAGE_TURN_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class PageTurnTransition final : public EffectBase {
public:
    explicit PageTurnTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
