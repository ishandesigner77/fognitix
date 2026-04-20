#include "EffectBase.h"

#include "EffectParameter.h"

namespace Fognitix::Effects {

EffectBase::EffectBase(std::string instanceId)
    : m_instanceId(QString::fromStdString(instanceId))
{
}

EffectBase::~EffectBase() = default;

void EffectBase::registerParameter(std::unique_ptr<EffectParameter> parameter)
{
    if (!parameter) {
        return;
    }
    const QString id = parameter->id();
    m_parameterIndex[id] = parameter.get();
    m_parameters.push_back(std::move(parameter));
}

void EffectBase::setParameterValue(const QString& parameterId, const QJsonValue& value)
{
    auto it = m_parameterIndex.find(parameterId);
    if (it == m_parameterIndex.end()) {
        return;
    }
    it->second->setValue(value);
}

QJsonValue EffectBase::parameterValue(const QString& parameterId) const
{
    auto it = m_parameterIndex.find(parameterId);
    if (it == m_parameterIndex.end()) {
        return {};
    }
    return it->second->value();
}

QJsonObject EffectBase::snapshotParameters() const
{
    QJsonObject out;
    for (const auto& p : m_parameters) {
        out.insert(p->id(), p->value());
    }
    return out;
}

void EffectBase::loadParameterSnapshot(const QJsonObject& obj)
{
    for (auto it = obj.begin(); it != obj.end(); ++it) {
        setParameterValue(it.key(), it.value());
    }
}

} // namespace Fognitix::Effects
