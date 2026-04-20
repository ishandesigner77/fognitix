#pragma once
#ifndef FOGNITIX_LUMA_FADE_TRANSITION_H
#define FOGNITIX_LUMA_FADE_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class LumaFadeTransition final : public EffectBase {
public:
    explicit LumaFadeTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
