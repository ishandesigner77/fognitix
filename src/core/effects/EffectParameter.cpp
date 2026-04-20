#include "EffectParameter.h"

namespace Fognitix::Effects {

EffectParameter::EffectParameter(QString id, QJsonValue defaultValue, bool keyframeable)
    : m_id(std::move(id))
    , m_value(std::move(defaultValue))
    , m_keyframeable(keyframeable)
{
}

} // namespace Fognitix::Effects
