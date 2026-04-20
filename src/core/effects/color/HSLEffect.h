#pragma once
#ifndef FOGNITIX_H_S_L_EFFECT_H
#define FOGNITIX_H_S_L_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class HSLEffect final : public EffectBase {
public:
    explicit HSLEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
