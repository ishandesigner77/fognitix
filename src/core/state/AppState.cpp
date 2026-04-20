#include "AppState.h"

#include <QString>
#include <algorithm>
#include <limits>

namespace Fognitix::State {

AppState::AppState(QObject* parent)
    : QObject(parent)
{
}

AppState::~AppState() = default;

void AppState::setPlayheadSeconds(double v)
{
    if (m_playheadSeconds == v) {
        return;
    }
    m_playheadSeconds = v;
    emit playheadSecondsChanged();
}

void AppState::setIsPlaying(bool v)
{
    if (m_isPlaying == v) {
        return;
    }
    m_isPlaying = v;
    emit isPlayingChanged();
}

void AppState::setStatusMessage(QString v)
{
    if (m_statusMessage == v) {
        return;
    }
    m_statusMessage = std::move(v);
    emit statusMessageChanged();
}

QString AppState::previewImageSource() const
{
    if (m_previewFrame.isNull()) {
        return {};
    }
    return QStringLiteral("image://fognitixPreview/") + QString::number(m_previewToken);
}

void AppState::setPreviewFrame(QImage img)
{
    m_previewFrame = std::move(img);
    ++m_previewToken;
    emit previewFrameChanged();
    emit previewImageSourceChanged();
}

void AppState::setInPoint(double v)
{
    m_inPoint = std::max(0.0, v);
    m_hasInPoint = true;
    emit inPointChanged();
}

void AppState::setOutPoint(double v)
{
    m_outPoint = std::max(0.0, v);
    m_hasOutPoint = true;
    emit outPointChanged();
}

void AppState::clearInPoint()
{
    m_hasInPoint = false;
    m_inPoint = 0.0;
    emit inPointChanged();
}

void AppState::clearOutPoint()
{
    m_hasOutPoint = false;
    m_outPoint = 0.0;
    emit outPointChanged();
}

void AppState::clearInOut()
{
    clearInPoint();
    clearOutPoint();
}

void AppState::setPlaybackRate(double v)
{
    if (m_playbackRate == v) return;
    m_playbackRate = v;
    emit playbackRateChanged();
}

void AppState::setTimelineDuration(double v)
{
    if (m_timelineDuration == v) return;
    m_timelineDuration = std::max(0.0, v);
    emit timelineDurationChanged();
}

int AppState::addMarker(double time, const QString& name, const QString& color)
{
    Marker m;
    m.time = std::max(0.0, time);
    m.name = name;
    m.color = color;
    m_markers.push_back(m);
    std::sort(m_markers.begin(), m_markers.end(),
              [](const Marker& a, const Marker& b) { return a.time < b.time; });
    emit markersChanged();
    for (int i = 0; i < m_markers.size(); ++i) {
        if (qFuzzyCompare(m_markers[i].time, m.time) && m_markers[i].name == m.name) return i;
    }
    return m_markers.size() - 1;
}

void AppState::removeMarkerAt(int index)
{
    if (index < 0 || index >= m_markers.size()) return;
    m_markers.remove(index);
    emit markersChanged();
}

void AppState::clearMarkers()
{
    if (m_markers.isEmpty()) return;
    m_markers.clear();
    emit markersChanged();
}

void AppState::updateMarker(int index, const QString& name, const QString& color, const QString& notes)
{
    if (index < 0 || index >= m_markers.size()) return;
    m_markers[index].name = name;
    m_markers[index].color = color;
    m_markers[index].notes = notes;
    emit markersChanged();
}

QVariantMap AppState::markerAt(int index) const
{
    QVariantMap m;
    if (index < 0 || index >= m_markers.size()) return m;
    const auto& mk = m_markers[index];
    m["time"] = mk.time;
    m["name"] = mk.name;
    m["color"] = mk.color;
    m["notes"] = mk.notes;
    m["duration"] = mk.duration;
    return m;
}

double AppState::nextMarkerTime(double from) const
{
    for (const auto& m : m_markers) {
        if (m.time > from + 1e-6) return m.time;
    }
    return -1.0;
}

double AppState::prevMarkerTime(double from) const
{
    double best = -1.0;
    for (const auto& m : m_markers) {
        if (m.time < from - 1e-6) best = m.time;
        else break;
    }
    return best;
}

QVariantList AppState::markersVariant() const
{
    QVariantList list;
    list.reserve(m_markers.size());
    for (const auto& mk : m_markers) {
        QVariantMap m;
        m["time"] = mk.time;
        m["name"] = mk.name;
        m["color"] = mk.color;
        m["notes"] = mk.notes;
        m["duration"] = mk.duration;
        list.append(m);
    }
    return list;
}

} // namespace Fognitix::State
