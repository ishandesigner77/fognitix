#pragma once
#ifndef FOGNITIX_FILM_GRAIN_EFFECT_H
#define FOGNITIX_FILM_GRAIN_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class FilmGrainEffect final : public EffectBase {
public:
    explicit FilmGrainEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
