#pragma once

#include <memory>

#include <QImage>
#include <QObject>
#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <QVector>

#include "Observable.h"

#include "core/project/Project.h"
#include "core/timeline/Timeline.h"

namespace Fognitix::State {

struct Marker {
    double time = 0.0;        // seconds
    QString name;
    QString color = QStringLiteral("#d4c9b0");
    QString notes;
    double duration = 0.0;    // 0 = point marker
};

class AppState : public QObject {
    Q_OBJECT
    Q_PROPERTY(double playheadSeconds READ playheadSeconds WRITE setPlayheadSeconds NOTIFY playheadSecondsChanged)
    Q_PROPERTY(bool isPlaying READ isPlaying WRITE setIsPlaying NOTIFY isPlayingChanged)
    Q_PROPERTY(QString statusMessage READ statusMessage WRITE setStatusMessage NOTIFY statusMessageChanged)
    Q_PROPERTY(QImage previewFrame READ previewFrame NOTIFY previewFrameChanged)
    Q_PROPERTY(QString previewImageSource READ previewImageSource NOTIFY previewImageSourceChanged)
    Q_PROPERTY(double inPoint READ inPoint WRITE setInPoint NOTIFY inPointChanged)
    Q_PROPERTY(double outPoint READ outPoint WRITE setOutPoint NOTIFY outPointChanged)
    Q_PROPERTY(bool hasInPoint READ hasInPoint NOTIFY inPointChanged)
    Q_PROPERTY(bool hasOutPoint READ hasOutPoint NOTIFY outPointChanged)
    Q_PROPERTY(double playbackRate READ playbackRate WRITE setPlaybackRate NOTIFY playbackRateChanged)
    Q_PROPERTY(QVariantList markers READ markersVariant NOTIFY markersChanged)
    Q_PROPERTY(double timelineDuration READ timelineDuration WRITE setTimelineDuration NOTIFY timelineDurationChanged)

public:
    explicit AppState(QObject* parent = nullptr);
    ~AppState() override;

    double playheadSeconds() const noexcept { return m_playheadSeconds; }
    void setPlayheadSeconds(double v);

    bool isPlaying() const noexcept { return m_isPlaying; }
    void setIsPlaying(bool v);

    const QString& statusMessage() const noexcept { return m_statusMessage; }
    void setStatusMessage(QString v);

    const QImage& previewFrame() const noexcept { return m_previewFrame; }
    void setPreviewFrame(QImage img);

    QString previewImageSource() const;

    double inPoint() const noexcept { return m_inPoint; }
    void setInPoint(double v);
    double outPoint() const noexcept { return m_outPoint; }
    void setOutPoint(double v);
    bool hasInPoint() const noexcept { return m_hasInPoint; }
    bool hasOutPoint() const noexcept { return m_hasOutPoint; }
    Q_INVOKABLE void clearInPoint();
    Q_INVOKABLE void clearOutPoint();
    Q_INVOKABLE void clearInOut();

    double playbackRate() const noexcept { return m_playbackRate; }
    void setPlaybackRate(double v);

    double timelineDuration() const noexcept { return m_timelineDuration; }
    void setTimelineDuration(double v);

    // Markers
    Q_INVOKABLE int addMarker(double time, const QString& name = {}, const QString& color = QStringLiteral("#d4c9b0"));
    Q_INVOKABLE void removeMarkerAt(int index);
    Q_INVOKABLE void clearMarkers();
    Q_INVOKABLE void updateMarker(int index, const QString& name, const QString& color, const QString& notes);
    Q_INVOKABLE QVariantMap markerAt(int index) const;
    Q_INVOKABLE int markerCount() const { return m_markers.size(); }
    Q_INVOKABLE double nextMarkerTime(double from) const;
    Q_INVOKABLE double prevMarkerTime(double from) const;
    QVariantList markersVariant() const;

    Observable<std::shared_ptr<Fognitix::Project::Project>>& projectObservable() noexcept { return m_project; }
    Observable<std::shared_ptr<Fognitix::Timeline::Timeline>>& timelineObservable() noexcept { return m_timeline; }

signals:
    void playheadSecondsChanged();
    void isPlayingChanged();
    void statusMessageChanged();
    void previewFrameChanged();
    void previewImageSourceChanged();
    void inPointChanged();
    void outPointChanged();
    void playbackRateChanged();
    void markersChanged();
    void timelineDurationChanged();

private:
    double m_playheadSeconds = 0.0;
    bool m_isPlaying = false;
    QString m_statusMessage;
    QImage m_previewFrame;
    quint64 m_previewToken = 0;

    double m_inPoint = 0.0;
    double m_outPoint = 0.0;
    bool m_hasInPoint = false;
    bool m_hasOutPoint = false;
    double m_playbackRate = 1.0;
    double m_timelineDuration = 0.0;

    QVector<Marker> m_markers;

    Observable<std::shared_ptr<Fognitix::Project::Project>> m_project;
    Observable<std::shared_ptr<Fognitix::Timeline::Timeline>> m_timeline;
};

} // namespace Fognitix::State
