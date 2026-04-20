#pragma once
#ifndef FOGNITIX_ZOOM_TRANSITION_H
#define FOGNITIX_ZOOM_TRANSITION_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class ZoomTransition final : public EffectBase {
public:
    explicit ZoomTransition(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
