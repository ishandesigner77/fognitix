#include "AudioEngine.h"

#include <cmath>

#include <soundio/soundio.h>

#include <QtLogging>

namespace Fognitix::Engine {

int AudioEngine::paCallback(
    const void* /*inputBuffer*/,
    void* outputBuffer,
    unsigned long frameCount,
    const PaStreamCallbackTimeInfo* /*timeInfo*/,
    PaStreamCallbackFlags /*statusFlags*/,
    void* userData)
{
    auto* self = static_cast<AudioEngine*>(userData);
    auto* out = static_cast<float*>(outputBuffer);
    if (out) {
        for (unsigned long i = 0; i < frameCount * 2; ++i) {
            out[i] = 0.0f;
        }
    }
    self->onFrames(frameCount);
    return paContinue;
}

void AudioEngine::onFrames(unsigned long frameCount)
{
    const double v = std::sin(static_cast<double>(frameCount) * 0.01) * 0.0001;
    m_masterLevel.store(std::abs(v));
}

AudioEngine::AudioEngine() = default;

AudioEngine::~AudioEngine()
{
    stop();
}

bool AudioEngine::start(QString* errorOut)
{
    if (m_stream) {
        return true;
    }

    struct SoundIo* sio = soundio_create();
    if (!sio) {
        if (errorOut) {
            *errorOut = QStringLiteral("libsoundio: soundio_create failed");
        }
    } else {
        soundio_destroy(sio);
    }

    const PaError err = Pa_Initialize();
    if (err != paNoError) {
        if (errorOut) {
            *errorOut = QString::fromUtf8(Pa_GetErrorText(err));
        }
        return false;
    }
    m_paInitialized = true;

    PaError o = Pa_OpenDefaultStream(&m_stream, 0, 2, paFloat32, 48000, 256, &AudioEngine::paCallback, this);
    if (o != paNoError) {
        if (errorOut) {
            *errorOut = QString::fromUtf8(Pa_GetErrorText(o));
        }
        Pa_Terminate();
        m_paInitialized = false;
        return false;
    }
    o = Pa_StartStream(m_stream);
    if (o != paNoError) {
        if (errorOut) {
            *errorOut = QString::fromUtf8(Pa_GetErrorText(o));
        }
        Pa_CloseStream(m_stream);
        m_stream = nullptr;
        Pa_Terminate();
        m_paInitialized = false;
        return false;
    }
    return true;
}

void AudioEngine::stop()
{
    if (m_stream) {
        Pa_StopStream(m_stream);
        Pa_CloseStream(m_stream);
        m_stream = nullptr;
    }
    if (m_paInitialized) {
        Pa_Terminate();
        m_paInitialized = false;
    }
}

} // namespace Fognitix::Engine
