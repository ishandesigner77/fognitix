#pragma once
#ifndef FOGNITIX_CONTRAST_EFFECT_H
#define FOGNITIX_CONTRAST_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ContrastEffect final : public EffectBase {
public:
    explicit ContrastEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
