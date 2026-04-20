#pragma once
#ifndef FOGNITIX_FILM_EMULATION_EFFECT_H
#define FOGNITIX_FILM_EMULATION_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class FilmEmulationEffect final : public EffectBase {
public:
    explicit FilmEmulationEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
