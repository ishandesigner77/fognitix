#pragma once
#ifndef FOGNITIX_MORPH_CUT_TRANSITION_H
#define FOGNITIX_MORPH_CUT_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class MorphCutTransition final : public EffectBase {
public:
    explicit MorphCutTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
