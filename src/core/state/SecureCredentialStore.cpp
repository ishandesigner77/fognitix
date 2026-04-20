#include "SecureCredentialStore.h"

#ifdef Q_OS_WIN
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>

#include <wincred.h>
#endif

#include <cstring>

#include <QByteArray>

namespace Fognitix::State {

namespace {

#ifdef Q_OS_WIN
constexpr wchar_t kTarget[] = L"Fognitix/GroqApiKey";
#endif

} // namespace

bool SecureCredentialStore::writeGroqApiKey(const QString& key)
{
#ifdef Q_OS_WIN
    QByteArray utf16;
    utf16.resize(key.size() * 2);
    memcpy(utf16.data(), key.utf16(), static_cast<std::size_t>(key.size()) * 2u);

    CREDENTIALW cred{};
    cred.Type = CRED_TYPE_GENERIC;
    cred.TargetName = const_cast<LPWSTR>(kTarget);
    cred.CredentialBlobSize = static_cast<DWORD>(utf16.size());
    cred.CredentialBlob = reinterpret_cast<LPBYTE>(utf16.data());
    cred.Persist = CRED_PERSIST_LOCAL_MACHINE;
    cred.UserName = const_cast<LPWSTR>(L"Fognitix");
    const BOOL ok = CredWriteW(&cred, 0);
    return ok == TRUE;
#else
    Q_UNUSED(key);
    return false;
#endif
}

QString SecureCredentialStore::readGroqApiKey()
{
#ifdef Q_OS_WIN
    PCREDENTIALW pcred = nullptr;
    if (CredReadW(kTarget, CRED_TYPE_GENERIC, 0, &pcred) != TRUE || !pcred || pcred->CredentialBlobSize == 0) {
        return {};
    }
    const auto* data = reinterpret_cast<const wchar_t*>(pcred->CredentialBlob);
    const std::size_t wcharCount = pcred->CredentialBlobSize / sizeof(wchar_t);
    QString out = QString::fromWCharArray(data, static_cast<int>(wcharCount));
    CredFree(pcred);
    return out;
#else
    return {};
#endif
}

void SecureCredentialStore::clearGroqApiKey()
{
#ifdef Q_OS_WIN
    CredDeleteW(kTarget, CRED_TYPE_GENERIC, 0);
#else
#endif
}

} // namespace Fognitix::State
