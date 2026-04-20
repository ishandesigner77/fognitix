#pragma once
#ifndef FOGNITIX_KINETIC_TEXT_EFFECT_H
#define FOGNITIX_KINETIC_TEXT_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class KineticTextEffect final : public EffectBase {
public:
    explicit KineticTextEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
