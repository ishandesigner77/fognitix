#pragma once
#ifndef FOGNITIX_ZOOM_BLUR_EFFECT_H
#define FOGNITIX_ZOOM_BLUR_EFFECT_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ZoomBlurEffect final : public EffectBase {
public:
    explicit ZoomBlurEffect(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
