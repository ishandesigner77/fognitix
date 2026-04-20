#pragma once
#ifndef FOGNITIX_REVERB_EFFECT_H
#define FOGNITIX_REVERB_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ReverbEffect final : public EffectBase {
public:
    explicit ReverbEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
