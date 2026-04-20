#include <cassert>
#include <cstdlib>

#include <QFile>
#include <QTemporaryDir>

#include <QtGlobal>

#include "core/effects/EffectRegistry.h"
#include "test_registry_path.h"

int main()
{
    QTemporaryDir dir;
    assert(dir.isValid());
    const QString badPath = dir.path() + QStringLiteral("/bad.json");
    {
        QFile f(badPath);
        assert(f.open(QIODevice::WriteOnly | QIODevice::Truncate));
        f.write(R"({"version":1})");
        f.close();
    }

    Fognitix::Effects::EffectRegistry reg;
    QString err;
    assert(!reg.loadFromFile(badPath, &err));

    const QString goodPath = dir.path() + QStringLiteral("/good.json");
    {
        QFile f(goodPath);
        assert(f.open(QIODevice::WriteOnly | QIODevice::Truncate));
        f.write(
            R"({"version":1,"effects":[{"id":"x","name":"X","category":"c","shader":"lut3d.glsl","parameters":[
{"id":"p01","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p02","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p03","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p04","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p05","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p06","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p07","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p08","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p09","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p10","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p11","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true},
{"id":"p12","type":"float","min":0,"max":1,"default":0.5,"keyframeable":true}
]}]})");
        f.close();
    }

    assert(reg.loadFromFile(goodPath, &err));
    assert(reg.effects().size() == 1u);

    Fognitix::Effects::EffectRegistry bulk;
    assert(bulk.loadFromFile(QString::fromUtf8(FOGNITIX_TEST_REGISTRY_PATH), &err));
    assert(bulk.effects().size() == 1000u);
    constexpr int kMinParams = 12;
    for (const auto& e : bulk.effects()) {
        assert(e.parameters.size() >= kMinParams);
    }
    return 0;
}
