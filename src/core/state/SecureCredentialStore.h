#pragma once

#include <QString>

namespace Fognitix::State {

class SecureCredentialStore {
public:
    static bool writeGroqApiKey(const QString& key);
    static QString readGroqApiKey();
    static void clearGroqApiKey();
};

} // namespace Fognitix::State
