#pragma once
#ifndef FOGNITIX_STABILIZER_EFFECT_H
#define FOGNITIX_STABILIZER_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class StabilizerEffect final : public EffectBase {
public:
    explicit StabilizerEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
