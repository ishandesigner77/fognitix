#pragma once
#ifndef FOGNITIX_WARP_EFFECT_H
#define FOGNITIX_WARP_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class WarpEffect final : public EffectBase {
public:
    explicit WarpEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
