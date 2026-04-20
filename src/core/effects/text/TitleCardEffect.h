#pragma once
#ifndef FOGNITIX_TITLE_CARD_EFFECT_H
#define FOGNITIX_TITLE_CARD_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class TitleCardEffect final : public EffectBase {
public:
    explicit TitleCardEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
