#pragma once
#ifndef FOGNITIX_V_H_S_EFFECT_H
#define FOGNITIX_V_H_S_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class VHSEffect final : public EffectBase {
public:
    explicit VHSEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
