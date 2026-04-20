#pragma once
#ifndef FOGNITIX_GLITCH_TRANSITION_H
#define FOGNITIX_GLITCH_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class GlitchTransition final : public EffectBase {
public:
    explicit GlitchTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
