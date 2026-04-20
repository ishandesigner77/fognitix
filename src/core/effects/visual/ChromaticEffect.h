#pragma once
#ifndef FOGNITIX_CHROMATIC_EFFECT_H
#define FOGNITIX_CHROMATIC_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ChromaticEffect final : public EffectBase {
public:
    explicit ChromaticEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
