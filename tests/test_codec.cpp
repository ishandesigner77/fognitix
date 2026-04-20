#include <cassert>

#include <QString>

#include "core/codec/VideoDecoder.h"

int main()
{
    Fognitix::Codec::VideoDecoder dec;
    QString err;
    assert(!dec.open(QStringLiteral("___missing_file__.mp4"), &err));
    return 0;
}
