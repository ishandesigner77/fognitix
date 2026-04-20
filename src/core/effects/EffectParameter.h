#pragma once

#include <QString>
#include <QJsonValue>

namespace Fognitix::Effects {

class EffectParameter {
public:
    EffectParameter(QString id, QJsonValue defaultValue, bool keyframeable);

    const QString& id() const noexcept { return m_id; }
    bool keyframeable() const noexcept { return m_keyframeable; }

    QJsonValue value() const noexcept { return m_value; }
    void setValue(const QJsonValue& v) { m_value = v; }

private:
    QString m_id;
    QJsonValue m_value;
    bool m_keyframeable = true;
};

} // namespace Fognitix::Effects
