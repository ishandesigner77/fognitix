#pragma once
#ifndef FOGNITIX_SKY_REPLACE_EFFECT_H
#define FOGNITIX_SKY_REPLACE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class SkyReplaceEffect final : public EffectBase {
public:
    explicit SkyReplaceEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
