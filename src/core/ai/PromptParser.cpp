#include "PromptParser.h"

#include <optional>

#include <QJsonDocument>
#include <QJsonParseError>

namespace Fognitix::AI {

QString PromptParser::trim(const QString& s)
{
    return s.trimmed();
}

std::optional<QJsonObject> PromptParser::tryParseJsonObject(const QString& s)
{
    QJsonParseError pe{};
    const QJsonDocument doc = QJsonDocument::fromJson(s.toUtf8(), &pe);
    if (pe.error != QJsonParseError::NoError || !doc.isObject()) {
        return std::nullopt;
    }
    return doc.object();
}

} // namespace Fognitix::AI
