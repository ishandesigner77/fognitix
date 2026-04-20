#pragma once
#ifndef FOGNITIX_BACKGROUND_REMOVE_EFFECT_H
#define FOGNITIX_BACKGROUND_REMOVE_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class BackgroundRemoveEffect final : public EffectBase {
public:
    explicit BackgroundRemoveEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
