#!/usr/bin/env python3
"""Emit C++ skeleton files for Fognitix module tree (idempotent)."""
from __future__ import annotations

import textwrap
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

EFFECT_FILES = [
    ("src/core/effects", "EffectBase"),
    ("src/core/effects", "EffectManager"),
    ("src/core/effects", "EffectStack"),
    ("src/core/effects", "EffectRegistry"),
    ("src/core/effects", "EffectParameter"),
    ("src/core/effects", "EffectMask"),
    ("src/core/effects", "EffectExpression"),
]

COLOR_EFFECTS = [
    "LUTEffect",
    "CurvesEffect",
    "ColorWheelsEffect",
    "HSLEffect",
    "ExposureEffect",
    "ContrastEffect",
    "SaturationEffect",
    "ColorBalanceEffect",
    "SplitToningEffect",
    "ColorMatchEffect",
    "FilmEmulationEffect",
    "ColorSpaceEffect",
]

MOTION_EFFECTS = [
    "MotionBlurEffect",
    "StabilizerEffect",
    "CameraShakeEffect",
    "ZoomBlurEffect",
    "TiltShiftEffect",
    "WarpEffect",
    "ParticleSystem",
    "PhysicsEngine",
]

VISUAL_EFFECTS = [
    "LensFlareEffect",
    "GlowEffect",
    "FilmGrainEffect",
    "ChromaticEffect",
    "VignetteEffect",
    "GlitchEffect",
    "VHSEffect",
    "HologramEffect",
    "AIUpscaleEffect",
    "BackgroundRemoveEffect",
    "SkyReplaceEffect",
]

TRANSITIONS = [
    "TransitionBase",
    "TransitionManager",
    "CrossDissolve",
    "WhipPanTransition",
    "ZoomTransition",
    "GlitchTransition",
    "LightLeakTransition",
    "LumaFadeTransition",
    "ShatterTransition",
    "PageTurnTransition",
    "MorphCutTransition",
]

TEXT_FX = [
    "TextEffectBase",
    "TypewriterEffect",
    "KineticTextEffect",
    "GlitchTextEffect",
    "NeonTextEffect",
    "LiquidTextEffect",
    "ParticleTextEffect",
    "LowerThirdsEffect",
    "TitleCardEffect",
    "CounterEffect",
]

AUDIO_FX = [
    "ParametricEQEffect",
    "CompressorEffect",
    "ReverbEffect",
    "NoiseReductionEffect",
    "AutoDuckEffect",
    "BeatDetectEffect",
    "PitchShiftEffect",
    "VoiceEnhanceEffect",
]


def snake(name: str) -> str:
    out = []
    for i, ch in enumerate(name):
        if ch.isupper() and i:
            out.append("_")
        out.append(ch.lower())
    return "".join(out)


def emit_effect_pair(subdir: str, cls: str, ns: str = "Fognitix::Effects") -> None:
    h = ROOT / subdir / f"{cls}.h"
    cpp = ROOT / subdir / f"{cls}.cpp"
    guard = f"FOGNITIX_{snake(cls).upper()}_H"
    h.parent.mkdir(parents=True, exist_ok=True)
    if h.exists() and cpp.exists():
        return
    h.write_text(
        textwrap.dedent(
            f"""\
            #pragma once
            #ifndef {guard}
            #define {guard}

            #include "EffectBase.h"

            namespace Fognitix::Effects {{

            class {cls} final : public EffectBase {{
            public:
                explicit {cls}(std::string instanceId);
                std::string_view typeId() const noexcept override;
                void configureFromDefaults() override;
            }};

            }} // namespace Fognitix::Effects

            #endif
            """
        ),
        encoding="utf-8",
    )
    cpp.write_text(
        textwrap.dedent(
            f"""\
            #include "{cls}.h"

            namespace Fognitix::Effects {{

            {cls}::{cls}(std::string instanceId)
                : EffectBase(std::move(instanceId))
            {{
                configureFromDefaults();
            }}

            std::string_view {cls}::typeId() const noexcept
            {{
                return "{snake(cls)}";
            }}

            void {cls}::configureFromDefaults()
            {{
                // Defaults are overridden by EffectRegistry JSON at runtime.
            }}

            }} // namespace Fognitix::Effects
            """
        ),
        encoding="utf-8",
    )


def main() -> None:
    for cls in COLOR_EFFECTS:
        emit_effect_pair("src/core/effects/color", cls)
    for cls in MOTION_EFFECTS:
        emit_effect_pair("src/core/effects/motion", cls)
    for cls in VISUAL_EFFECTS:
        emit_effect_pair("src/core/effects/visual", cls)
    for cls in TRANSITIONS:
        emit_effect_pair("src/core/effects/transitions", cls)
    for cls in TEXT_FX:
        emit_effect_pair("src/core/effects/text", cls)
    for cls in AUDIO_FX:
        emit_effect_pair("src/core/effects/audio", cls)


if __name__ == "__main__":
    main()
