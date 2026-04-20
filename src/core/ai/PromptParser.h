#pragma once

#include <optional>

#include <QString>

#include <QJsonObject>

namespace Fognitix::AI {

class PromptParser {
public:
    static QString trim(const QString& s);
    static std::optional<QJsonObject> tryParseJsonObject(const QString& s);
};

} // namespace Fognitix::AI
