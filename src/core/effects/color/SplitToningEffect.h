#pragma once
#ifndef FOGNITIX_SPLIT_TONING_EFFECT_H
#define FOGNITIX_SPLIT_TONING_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class SplitToningEffect final : public EffectBase {
public:
    explicit SplitToningEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
