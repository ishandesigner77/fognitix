#pragma once
#ifndef FOGNITIX_TYPEWRITER_EFFECT_H
#define FOGNITIX_TYPEWRITER_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class TypewriterEffect final : public EffectBase {
public:
    explicit TypewriterEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
