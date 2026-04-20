#include "GroqClient.h"

#include <QEventLoop>
#include <QTimer>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QUrl>

namespace Fognitix::AI {

GroqClient::GroqClient(QObject* parent)
    : QObject(parent)
    , m_nam(this)
{
}

void GroqClient::setApiKey(QString key)
{
    m_apiKey = std::move(key);
}

QJsonObject GroqClient::completeJson(const QString& systemPrompt, const QJsonObject& userPayload, QString* errorOut)
{
    if (m_apiKey.isEmpty()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Groq API key is empty");
        }
        return {};
    }

    QJsonObject body;
    body.insert(QStringLiteral("model"), QStringLiteral("llama-3.3-70b-versatile"));
    QJsonArray messages;
    {
        QJsonObject sys;
        sys.insert(QStringLiteral("role"), QStringLiteral("system"));
        sys.insert(QStringLiteral("content"), systemPrompt);
        messages.append(sys);
    }
    {
        QJsonObject usr;
        usr.insert(QStringLiteral("role"), QStringLiteral("user"));
        usr.insert(QStringLiteral("content"), QString::fromUtf8(QJsonDocument(userPayload).toJson(QJsonDocument::Compact)));
        messages.append(usr);
    }
    body.insert(QStringLiteral("messages"), messages);
    body.insert(QStringLiteral("temperature"), 0.2);

    QNetworkRequest req(QUrl(QStringLiteral("https://api.groq.com/openai/v1/chat/completions")));
    req.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    req.setRawHeader("Authorization", QByteArray("Bearer ") + m_apiKey.toUtf8());

    QNetworkReply* reply = m_nam.post(req, QJsonDocument(body).toJson(QJsonDocument::Compact));

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QTimer::singleShot(120000, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() != QNetworkReply::NoError) {
        const QString msg = reply->errorString();
        if (errorOut) {
            *errorOut = msg;
        }
        emit requestFailed(msg);
        reply->deleteLater();
        return {};
    }

    const QByteArray raw = reply->readAll();
    reply->deleteLater();

    QJsonParseError pe{};
    const QJsonDocument doc = QJsonDocument::fromJson(raw, &pe);
    if (pe.error != QJsonParseError::NoError || !doc.isObject()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Invalid JSON from Groq");
        }
        return {};
    }

    const QJsonObject root = doc.object();
    const QJsonArray choices = root.value(QStringLiteral("choices")).toArray();
    if (choices.isEmpty()) {
        if (errorOut) {
            *errorOut = QStringLiteral("No choices in Groq response");
        }
        return {};
    }
    const QJsonObject message = choices.at(0).toObject().value(QStringLiteral("message")).toObject();
    const QString content = message.value(QStringLiteral("content")).toString();
    const QJsonDocument parsed = QJsonDocument::fromJson(content.toUtf8(), &pe);
    if (pe.error != QJsonParseError::NoError || !parsed.isObject()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Model did not return JSON object");
        }
        return {};
    }
    return parsed.object();
}

bool GroqClient::testConnection(QString* errorOut)
{
    if (m_apiKey.isEmpty()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Groq API key is empty");
        }
        return false;
    }

    QJsonObject body;
    body.insert(QStringLiteral("model"), QStringLiteral("llama-3.1-8b-instant"));
    QJsonArray messages;
    {
        QJsonObject usr;
        usr.insert(QStringLiteral("role"), QStringLiteral("user"));
        usr.insert(QStringLiteral("content"), QStringLiteral("Reply with exactly: ok"));
        messages.append(usr);
    }
    body.insert(QStringLiteral("messages"), messages);
    body.insert(QStringLiteral("temperature"), 0.0);
    body.insert(QStringLiteral("max_tokens"), 8);

    QNetworkRequest req(QUrl(QStringLiteral("https://api.groq.com/openai/v1/chat/completions")));
    req.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));
    req.setRawHeader("Authorization", QByteArray("Bearer ") + m_apiKey.toUtf8());

    QNetworkReply* reply = m_nam.post(req, QJsonDocument(body).toJson(QJsonDocument::Compact));

    QEventLoop loop;
    QObject::connect(reply, &QNetworkReply::finished, &loop, &QEventLoop::quit);
    QTimer::singleShot(30000, &loop, &QEventLoop::quit);
    loop.exec();

    if (reply->error() != QNetworkReply::NoError) {
        const QString msg = reply->errorString();
        if (errorOut) {
            *errorOut = msg;
        }
        emit requestFailed(msg);
        reply->deleteLater();
        return false;
    }

    const QByteArray raw = reply->readAll();
    reply->deleteLater();

    QJsonParseError pe{};
    const QJsonDocument doc = QJsonDocument::fromJson(raw, &pe);
    if (pe.error != QJsonParseError::NoError || !doc.isObject()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Invalid JSON from Groq");
        }
        return false;
    }

    const QJsonObject root = doc.object();
    const QJsonArray choices = root.value(QStringLiteral("choices")).toArray();
    if (choices.isEmpty()) {
        if (errorOut) {
            *errorOut = QStringLiteral("No choices in Groq response");
        }
        return false;
    }
    const QJsonObject message = choices.at(0).toObject().value(QStringLiteral("message")).toObject();
    const QString content = message.value(QStringLiteral("content")).toString().trimmed();
    if (content.isEmpty()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Empty completion");
        }
        return false;
    }
    return true;
}

} // namespace Fognitix::AI
