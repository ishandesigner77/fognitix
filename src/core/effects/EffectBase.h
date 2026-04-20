#pragma once

#include <memory>
#include <string>
#include <string_view>
#include <unordered_map>
#include <vector>

#include <QJsonObject>
#include <QString>

namespace Fognitix::Effects {

class EffectParameter;

class EffectBase {
public:
    explicit EffectBase(std::string instanceId);
    virtual ~EffectBase();

    EffectBase(const EffectBase&) = delete;
    EffectBase& operator=(const EffectBase&) = delete;
    EffectBase(EffectBase&&) = delete;
    EffectBase& operator=(EffectBase&&) = delete;

    const QString& instanceId() const noexcept { return m_instanceId; }

    virtual std::string_view typeId() const noexcept = 0;

    virtual void configureFromDefaults() = 0;

    void setParameterValue(const QString& parameterId, const QJsonValue& value);
    QJsonValue parameterValue(const QString& parameterId) const;

    QJsonObject snapshotParameters() const;

    void loadParameterSnapshot(const QJsonObject& obj);

protected:
    void registerParameter(std::unique_ptr<EffectParameter> parameter);

private:
    QString m_instanceId;
    std::vector<std::unique_ptr<EffectParameter>> m_parameters;
    std::unordered_map<QString, EffectParameter*> m_parameterIndex;
};

} // namespace Fognitix::Effects
