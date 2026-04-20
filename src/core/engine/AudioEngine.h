#pragma once

#include <atomic>

#include <QString>

#include <portaudio.h>

namespace Fognitix::Engine {

class AudioEngine {
public:
    AudioEngine();
    ~AudioEngine();

    bool start(QString* errorOut);
    void stop();

    double masterLevel() const noexcept { return m_masterLevel.load(); }

private:
    static int paCallback(
        const void* inputBuffer,
        void* outputBuffer,
        unsigned long frameCount,
        const PaStreamCallbackTimeInfo* timeInfo,
        PaStreamCallbackFlags statusFlags,
        void* userData);

    void onFrames(unsigned long frameCount);

    PaStream* m_stream = nullptr;
    bool m_paInitialized = false;
    std::atomic<double> m_masterLevel{0.0};
};

} // namespace Fognitix::Engine
