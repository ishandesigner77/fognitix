#pragma once

#include <optional>

#include <QString>

#include <QJsonArray>
#include <QJsonObject>

namespace Fognitix::AI {

struct AiCommandDocument {
    QString version;
    QString explanation;
    QJsonArray commands;
};

std::optional<AiCommandDocument> parseAiCommandDocument(const QJsonObject& root, QString* errorOut);

bool validateCommandObject(const QJsonObject& cmd, QString* errorOut);

} // namespace Fognitix::AI
