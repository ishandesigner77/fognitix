#pragma once

#include <QString>

#include <QJsonObject>
#include <QNetworkAccessManager>
#include <QObject>

namespace Fognitix::AI {

class GroqClient : public QObject {
    Q_OBJECT
public:
    explicit GroqClient(QObject* parent = nullptr);

    void setApiKey(QString key);
    QString apiKey() const { return m_apiKey; }

    QJsonObject completeJson(const QString& systemPrompt, const QJsonObject& userPayload, QString* errorOut);

    /// Minimal chat completion to verify key and connectivity (non-JSON response).
    bool testConnection(QString* errorOut);

signals:
    void requestFailed(QString message);

private:
    QNetworkAccessManager m_nam;
    QString m_apiKey;
};

} // namespace Fognitix::AI
