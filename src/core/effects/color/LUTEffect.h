#pragma once
#ifndef FOGNITIX_L_U_T_EFFECT_H
#define FOGNITIX_L_U_T_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class LUTEffect final : public EffectBase {
public:
    explicit LUTEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
