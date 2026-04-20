#include "AICommandSchema.h"

namespace Fognitix::AI {

namespace {

const QStringList kKnownTypes = {
    QStringLiteral("apply_effect"),
    QStringLiteral("edit_timeline"),
    QStringLiteral("modify_parameter"),
    QStringLiteral("add_keyframe"),
    QStringLiteral("add_text_layer"),
    QStringLiteral("add_shape_layer"),
    QStringLiteral("add_adjustment_layer"),
    QStringLiteral("color_grade"),
    QStringLiteral("speed_change"),
    QStringLiteral("add_3d_layer"),
    QStringLiteral("remove_silences"),
    QStringLiteral("beat_sync"),
    QStringLiteral("generate_captions"),
    QStringLiteral("export"),
};

} // namespace

std::optional<AiCommandDocument> parseAiCommandDocument(const QJsonObject& root, QString* errorOut)
{
    QJsonObject envelope = root;
    if (root.contains(QStringLiteral("ai_command"))) {
        envelope = root.value(QStringLiteral("ai_command")).toObject();
    }
    if (!envelope.contains(QStringLiteral("commands")) || !envelope.value(QStringLiteral("commands")).isArray()) {
        if (errorOut) {
            *errorOut = QStringLiteral("Missing commands[]");
        }
        return std::nullopt;
    }
    AiCommandDocument doc;
    doc.version = envelope.value(QStringLiteral("version")).toString(QStringLiteral("1.0"));
    doc.explanation = envelope.value(QStringLiteral("explanation")).toString();
    doc.commands = envelope.value(QStringLiteral("commands")).toArray();
    return doc;
}

bool validateCommandObject(const QJsonObject& cmd, QString* errorOut)
{
    const QString type = cmd.value(QStringLiteral("type")).toString();
    if (!kKnownTypes.contains(type)) {
        if (errorOut) {
            *errorOut = QStringLiteral("Unknown command type: ") + type;
        }
        return false;
    }
    if (type == QStringLiteral("apply_effect")) {
        if (!cmd.contains(QStringLiteral("effect_id"))) {
            if (errorOut) {
                *errorOut = QStringLiteral("apply_effect requires effect_id");
            }
            return false;
        }
        return true;
    }
    if (type == QStringLiteral("edit_timeline")) {
        if (!cmd.contains(QStringLiteral("operation"))) {
            if (errorOut) {
                *errorOut = QStringLiteral("edit_timeline requires operation");
            }
            return false;
        }
        return true;
    }
    if (type == QStringLiteral("modify_parameter")) {
        if (!cmd.contains(QStringLiteral("target_clip")) || !cmd.contains(QStringLiteral("parameter_id"))) {
            if (errorOut) {
                *errorOut = QStringLiteral("modify_parameter requires target_clip and parameter_id");
            }
            return false;
        }
        return true;
    }
    return true;
}

} // namespace Fognitix::AI
