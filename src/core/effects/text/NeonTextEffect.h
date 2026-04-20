#pragma once
#ifndef FOGNITIX_NEON_TEXT_EFFECT_H
#define FOGNITIX_NEON_TEXT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class NeonTextEffect final : public EffectBase {
public:
    explicit NeonTextEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
