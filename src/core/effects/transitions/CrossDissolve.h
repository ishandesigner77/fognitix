#pragma once
#ifndef FOGNITIX_CROSS_DISSOLVE_H
#define FOGNITIX_CROSS_DISSOLVE_H

#include "EffectBase.h"

namespace Fognitix::Effects {

class CrossDissolve final : public EffectBase {
public:
    explicit CrossDissolve(std::string instanceId);
    std::string_view typeId() const noexcept override;
    void configureFromDefaults() override;
};

} // namespace Fognitix::Effects

#endif
