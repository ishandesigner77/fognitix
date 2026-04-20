#pragma once
#ifndef FOGNITIX_TEXT_EFFECT_BASE_H
#define FOGNITIX_TEXT_EFFECT_BASE_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class TextEffectBase final : public EffectBase {
public:
    explicit TextEffectBase(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
