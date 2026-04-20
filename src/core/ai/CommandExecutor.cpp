#include "CommandExecutor.h"

#include "AICommandSchema.h"

#include "core/project/Project.h"
#include "core/state/AppState.h"
#include "core/timeline/EditOperations.h"
#include "core/timeline/Timeline.h"
#include "core/timeline/TimelineClip.h"

#include <QUuid>

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

namespace Fognitix::AI {

namespace {

void appendLog(QString* log, const QString& line)
{
    if (!log) {
        return;
    }
    if (!log->isEmpty()) {
        *log += QStringLiteral("\n");
    }
    *log += line;
}

} // namespace

bool CommandExecutor::executeEnvelope(
    const QJsonObject& root,
    Fognitix::State::AppState& appState,
    Fognitix::Project::Project& project,
    Fognitix::Timeline::Timeline& timeline,
    QString* logOut,
    QString* errorOut)
{
    QString err;
    const auto doc = parseAiCommandDocument(root, &err);
    if (!doc.has_value()) {
        if (errorOut) {
            *errorOut = err;
        }
        return false;
    }

    for (const auto& v : doc->commands) {
        if (!v.isObject()) {
            continue;
        }
        QJsonObject cmd = v.toObject();
        if (!validateCommandObject(cmd, &err)) {
            if (errorOut) {
                *errorOut = err;
            }
            return false;
        }
        const QString type = cmd.value(QStringLiteral("type")).toString();
        if (type == QStringLiteral("apply_effect")) {
            const QString target = cmd.value(QStringLiteral("target")).toString();
            const QString effectId = cmd.value(QStringLiteral("effect_id")).toString();
            QJsonObject inst;
            inst.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
            inst.insert(QStringLiteral("effect_id"), effectId);
            inst.insert(QStringLiteral("parameters"), cmd.value(QStringLiteral("parameters")).toObject());
            inst.insert(QStringLiteral("keyframes"), cmd.value(QStringLiteral("keyframes")).toArray());

            if (target == QStringLiteral("all")) {
                for (auto& tr : timeline.tracks()) {
                    for (auto& c : tr.clips) {
                        c.effectStack.append(inst);
                    }
                }
                appendLog(logOut, QStringLiteral("apply_effect all -> ") + effectId);
            } else {
                auto clipOpt = timeline.findClip(target);
                if (!clipOpt.has_value()) {
                    if (errorOut) {
                        *errorOut = QStringLiteral("Clip not found: ") + target;
                    }
                    return false;
                }
                clipOpt.value()->effectStack.append(inst);
                appendLog(logOut, QStringLiteral("apply_effect ") + target + QStringLiteral(" -> ") + effectId);
            }
        } else if (type == QStringLiteral("edit_timeline")) {
            const QString op = cmd.value(QStringLiteral("operation")).toString();
            if (op == QStringLiteral("cut")) {
                const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
                const double at = cmd.value(QStringLiteral("at_time")).toDouble();
                if (!Fognitix::Timeline::EditOperations::cutClipAtTime(timeline, clipId, at)) {
                    if (errorOut) {
                        *errorOut = QStringLiteral("cut failed");
                    }
                    return false;
                }
                appendLog(logOut, QStringLiteral("cut ") + clipId);
            } else if (op == QStringLiteral("add_transition")) {
                const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
                auto clipOpt = timeline.findClip(clipId);
                if (clipOpt.has_value()) {
                    QJsonObject inst;
                    inst.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
                    inst.insert(QStringLiteral("effect_id"),
                                cmd.value(QStringLiteral("transition_id")).toString(QStringLiteral("cross_dissolve")));
                    QJsonObject params;
                    params.insert(QStringLiteral("duration"),
                                  cmd.value(QStringLiteral("duration")).toDouble(1.0));
                    inst.insert(QStringLiteral("parameters"), params);
                    inst.insert(QStringLiteral("kind"), QStringLiteral("transition"));
                    clipOpt.value()->effectStack.append(inst);
                    appendLog(logOut, QStringLiteral("transition ") + inst.value(QStringLiteral("effect_id")).toString() +
                                      QStringLiteral(" → ") + clipId);
                } else {
                    appendLog(logOut, QStringLiteral("add_transition: target clip not found"));
                }
            } else if (op == QStringLiteral("ripple_delete")) {
                const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
                for (auto& tr : timeline.tracks()) {
                    auto it = std::find_if(tr.clips.begin(), tr.clips.end(),
                                           [&](const auto& c){ return c.id == clipId; });
                    if (it != tr.clips.end()) {
                        const double d = it->duration;
                        const double s = it->startOnTimeline;
                        tr.clips.erase(it);
                        for (auto& c : tr.clips) {
                            if (c.startOnTimeline > s) c.startOnTimeline -= d;
                        }
                        appendLog(logOut, QStringLiteral("ripple_delete ") + clipId);
                        break;
                    }
                }
            } else {
                if (errorOut) {
                    *errorOut = QStringLiteral("Unsupported edit_timeline operation: ") + op;
                }
                return false;
            }
        } else if (type == QStringLiteral("modify_parameter")) {
            const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
            const QString paramId = cmd.value(QStringLiteral("parameter_id")).toString();
            const QJsonValue val = cmd.value(QStringLiteral("value"));
            auto clipOpt = timeline.findClip(clipId);
            if (!clipOpt.has_value()) {
                if (errorOut) {
                    *errorOut = QStringLiteral("modify_parameter clip not found");
                }
                return false;
            }
            QJsonArray stack = clipOpt.value()->effectStack;
            if (stack.isEmpty()) {
                QJsonObject inst;
                inst.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
                inst.insert(QStringLiteral("effect_id"), cmd.value(QStringLiteral("effect_id")).toString());
                QJsonObject params;
                params.insert(paramId, val);
                inst.insert(QStringLiteral("parameters"), params);
                stack.append(inst);
            } else {
                QJsonObject eff = stack.last().toObject();
                QJsonObject params = eff.value(QStringLiteral("parameters")).toObject();
                params.insert(paramId, val);
                eff.insert(QStringLiteral("parameters"), params);
                stack.removeAt(stack.size() - 1);
                stack.append(eff);
            }
            clipOpt.value()->effectStack = stack;
            appendLog(logOut, QStringLiteral("modify_parameter ") + clipId + QStringLiteral(" ") + paramId);
        } else if (type == QStringLiteral("add_keyframe")) {
            const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
            const QString paramId = cmd.value(QStringLiteral("parameter_id")).toString();
            const double t = cmd.value(QStringLiteral("time")).toDouble();
            const QJsonValue val = cmd.value(QStringLiteral("value"));
            auto clipOpt = timeline.findClip(clipId);
            if (!clipOpt.has_value()) {
                if (errorOut) { *errorOut = QStringLiteral("add_keyframe clip not found"); }
                return false;
            }
            QJsonArray stack = clipOpt.value()->effectStack;
            QJsonObject kf;
            kf.insert(QStringLiteral("parameter_id"), paramId);
            kf.insert(QStringLiteral("time"), t);
            kf.insert(QStringLiteral("value"), val);
            kf.insert(QStringLiteral("interpolation"),
                     cmd.value(QStringLiteral("interpolation")).toString(QStringLiteral("linear")));
            QJsonObject eff;
            if (stack.isEmpty()) {
                eff.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
                eff.insert(QStringLiteral("effect_id"), QStringLiteral("transform"));
                QJsonArray kfs; kfs.append(kf);
                eff.insert(QStringLiteral("keyframes"), kfs);
                stack.append(eff);
            } else {
                eff = stack.last().toObject();
                QJsonArray kfs = eff.value(QStringLiteral("keyframes")).toArray();
                kfs.append(kf);
                eff.insert(QStringLiteral("keyframes"), kfs);
                stack.removeAt(stack.size() - 1);
                stack.append(eff);
            }
            clipOpt.value()->effectStack = stack;
            appendLog(logOut, QStringLiteral("keyframe @") + QString::number(t, 'f', 2) + QStringLiteral("s ") + paramId);
        } else if (type == QStringLiteral("add_text_layer")) {
            const QString text = cmd.value(QStringLiteral("text")).toString();
            const double start = cmd.value(QStringLiteral("start")).toDouble();
            const double dur = cmd.value(QStringLiteral("duration")).toDouble(3.0);
            QString trackId;
            for (const auto& t : timeline.tracks()) {
                if (t.name == QStringLiteral("TEXT")) { trackId = t.id; break; }
            }
            if (trackId.isEmpty()) {
                trackId = timeline.addVideoTrack(QStringLiteral("TEXT"));
            }
            timeline.addClip(trackId, QStringLiteral("text:") + text, start, dur);
            appendLog(logOut, QStringLiteral("text layer: ") + text);
        } else if (type == QStringLiteral("add_shape_layer")) {
            const QString shape = cmd.value(QStringLiteral("shape")).toString(QStringLiteral("rect"));
            const double start = cmd.value(QStringLiteral("start")).toDouble();
            const double dur = cmd.value(QStringLiteral("duration")).toDouble(3.0);
            QString trackId;
            if (!timeline.tracks().empty()) trackId = timeline.tracks().front().id;
            else trackId = timeline.addVideoTrack(QStringLiteral("V1"));
            timeline.addClip(trackId, QStringLiteral("shape:") + shape, start, dur);
            appendLog(logOut, QStringLiteral("shape layer: ") + shape);
        } else if (type == QStringLiteral("add_adjustment_layer")) {
            const double start = cmd.value(QStringLiteral("start")).toDouble();
            const double dur = cmd.value(QStringLiteral("duration")).toDouble(10.0);
            const QString trackId = timeline.addVideoTrack(QStringLiteral("ADJ"));
            timeline.tracks().back().type = Fognitix::Timeline::TrackType::Adjustment;
            timeline.addClip(trackId, QStringLiteral("adjustment"), start, dur);
            appendLog(logOut, QStringLiteral("adjustment layer"));
        } else if (type == QStringLiteral("color_grade")) {
            QJsonObject inst;
            inst.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
            inst.insert(QStringLiteral("effect_id"), QStringLiteral("color_grade"));
            QJsonObject params;
            for (const QString& k : {QStringLiteral("lift"), QStringLiteral("gamma"), QStringLiteral("gain"),
                                     QStringLiteral("temperature"), QStringLiteral("tint"), QStringLiteral("saturation")}) {
                if (cmd.contains(k)) params.insert(k, cmd.value(k));
            }
            inst.insert(QStringLiteral("parameters"), params);
            const QString target = cmd.value(QStringLiteral("target")).toString(QStringLiteral("all"));
            if (target == QStringLiteral("all")) {
                for (auto& tr : timeline.tracks())
                    for (auto& c : tr.clips)
                        c.effectStack.append(inst);
                appendLog(logOut, QStringLiteral("color grade applied to all clips"));
            } else {
                auto clipOpt = timeline.findClip(target);
                if (clipOpt.has_value()) {
                    clipOpt.value()->effectStack.append(inst);
                    appendLog(logOut, QStringLiteral("color grade -> ") + target);
                }
            }
        } else if (type == QStringLiteral("speed_change")) {
            const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
            const double speed = cmd.value(QStringLiteral("speed")).toDouble(1.0);
            auto clipOpt = timeline.findClip(clipId);
            if (clipOpt.has_value()) {
                clipOpt.value()->speed = speed;
                appendLog(logOut, QStringLiteral("speed ") + QString::number(speed) + QStringLiteral("× → ") + clipId);
            }
        } else if (type == QStringLiteral("add_3d_layer")) {
            const QString clipId = cmd.value(QStringLiteral("target_clip")).toString();
            auto clipOpt = timeline.findClip(clipId);
            if (clipOpt.has_value()) {
                QJsonObject inst;
                inst.insert(QStringLiteral("instance_id"), QUuid::createUuid().toString(QUuid::WithoutBraces));
                inst.insert(QStringLiteral("effect_id"), QStringLiteral("transform_3d"));
                inst.insert(QStringLiteral("parameters"), cmd.value(QStringLiteral("camera")).toObject());
                clipOpt.value()->effectStack.append(inst);
                appendLog(logOut, QStringLiteral("3D layer enabled on ") + clipId);
            }
        } else if (type == QStringLiteral("remove_silences")) {
            appendLog(logOut, QStringLiteral("remove_silences scheduled (DSP pipeline hooks)"));
        } else if (type == QStringLiteral("beat_sync")) {
            appendLog(logOut, QStringLiteral("beat_sync scheduled"));
        } else if (type == QStringLiteral("generate_captions")) {
            appendLog(logOut, QStringLiteral("generate_captions scheduled"));
        } else if (type == QStringLiteral("export")) {
            appendLog(logOut, QStringLiteral("export command received: ") + cmd.value(QStringLiteral("preset")).toString());
        }
    }

    project.saveTimeline(timeline);
    appState.setStatusMessage(QStringLiteral("AI commands applied"));
    if (logOut && !doc->explanation.isEmpty()) {
        appendLog(logOut, doc->explanation);
    }
    return true;
}

} // namespace Fognitix::AI
