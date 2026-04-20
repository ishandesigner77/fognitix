#pragma once
#ifndef FOGNITIX_LENS_FLARE_EFFECT_H
#define FOGNITIX_LENS_FLARE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class LensFlareEffect final : public EffectBase {
public:
    explicit LensFlareEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
