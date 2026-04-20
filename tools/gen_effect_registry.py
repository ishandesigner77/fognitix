#!/usr/bin/env python3
"""Generate Fognitix effect registry JSON (1000 entries, 12+ parameters each, composable blocks)."""
from __future__ import annotations

import argparse
import json
import random
from pathlib import Path

# Only shader basenames that exist under shaders/ + resources.qrc
SHADER_FAMILIES: dict[str, list[str]] = {
    "color": [
        "lut3d.glsl",
        "curves.glsl",
        "colorwheels.glsl",
        "hsl.glsl",
        "exposure.glsl",
        "contrast.glsl",
        "saturation.glsl",
        "colorbalance.glsl",
        "splittoning.glsl",
        "filmemulation.glsl",
        "colorspace.glsl",
    ],
    "motion": [
        "blur_motion.glsl",
        "blur_gaussian.glsl",
        "blur_radial.glsl",
        "blur_tiltshift.glsl",
        "sharpen.glsl",
        "depthofField.glsl",
    ],
    "visual": [
        "chromatic.glsl",
        "filmgrain.glsl",
        "vignette.glsl",
        "lensflare.glsl",
        "glow.glsl",
        "bloom.glsl",
        "glitch.glsl",
        "vhs.glsl",
        "hologram.glsl",
        "lightleak.glsl",
        "halation.glsl",
        "pixelsort.glsl",
        "datamosh.glsl",
    ],
    "transitions": [
        "dissolve.glsl",
        "whippan.glsl",
        "zoomblur.glsl",
        "rgbsplit.glsl",
        "lumafade.glsl",
        "glitch_transition.glsl",
        "shatter.glsl",
        "pageturn.glsl",
        "lightflash.glsl",
    ],
    "text": [
        "typewriter.glsl",
        "glitchtext.glsl",
        "neontext.glsl",
        "liquidtext.glsl",
    ],
    "audio": [""],
    # Utility / matte / stylize reuse proven GPU families (same files on disk)
    "utility": ["sharpen.glsl", "blur_gaussian.glsl", "blur_motion.glsl", "depthofField.glsl"],
    "matte": ["lumafade.glsl", "blur_tiltshift.glsl", "dissolve.glsl", "vignette.glsl"],
    "stylize": ["filmgrain.glsl", "glitch.glsl", "chromatic.glsl", "halation.glsl"],
}

TOTAL_EFFECTS = 2200
MIN_PARAMS = 12


def float_param(pid: str, name: str, vmin: float, vmax: float, default: float, kf: bool = True) -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "float",
        "min": vmin,
        "max": vmax,
        "default": default,
        "keyframeable": kf,
    }


def int_param(pid: str, name: str, vmin: int, vmax: int, default: int, kf: bool = True) -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "int",
        "min": vmin,
        "max": vmax,
        "default": default,
        "keyframeable": kf,
    }


def bool_param(pid: str, name: str, default: bool) -> dict:
    return {"id": pid, "name": name, "type": "bool", "default": default, "keyframeable": False}


def color_param(pid: str, name: str, default: list[float], kf: bool = True) -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "color",
        "default": default,
        "keyframeable": kf,
    }


def color_wheel_param(pid: str, name: str, default: list[float], kf: bool = True) -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "color_wheel",
        "default": default,
        "keyframeable": kf,
    }


def enum_param(pid: str, name: str, options: list[str], default: str) -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "enum",
        "options": options,
        "default": default,
        "keyframeable": False,
    }


def curve_param(pid: str, name: str, points: list[list[float]], kf: bool = True) -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "curve",
        "points": points,
        "keyframeable": kf,
    }


def file_param(pid: str, name: str, accepts: list[str], default: str = "") -> dict:
    return {
        "id": pid,
        "name": name,
        "type": "file",
        "default": default,
        "accepts": accepts,
        "keyframeable": False,
    }


def string_param(pid: str, name: str, default: str, kf: bool = False) -> dict:
    return {"id": pid, "name": name, "type": "string", "default": default, "keyframeable": kf}


def block_spatial_transform(seed: int) -> list[dict]:
    rng = random.Random(seed)
    return [
        float_param("pos_x", "Position X", -2.0, 2.0, 0.0),
        float_param("pos_y", "Position Y", -2.0, 2.0, 0.0),
        float_param("anchor_x", "Anchor X", 0.0, 1.0, 0.5),
        float_param("anchor_y", "Anchor Y", 0.0, 1.0, 0.5),
        float_param("scale_uniform", "Uniform Scale", 0.05, 8.0, 1.0),
        float_param("skew_x", "Skew X", -1.0, 1.0, 0.0),
        float_param("skew_y", "Skew Y", -1.0, 1.0, 0.0),
        float_param("perspective", "Perspective", 0.0, 1.0, 0.0),
        float_param("motion_blur_samples", "Motion Blur Samples", 1.0, 64.0, 8.0, kf=False),
        enum_param("transform_order", "Transform Order", ["TRS", "TSR", "RST"], "TRS"),
        float_param("randomize_amount", "Randomize Amount", 0.0, 1.0, rng.uniform(0, 0.05)),
    ]


def block_temporal_blend(seed: int) -> list[dict]:
    rng = random.Random(seed + 17)
    return [
        float_param("mix_amount", "Mix", 0.0, 1.0, 1.0),
        float_param("opacity", "Opacity", 0.0, 1.0, 1.0),
        float_param("time_offset", "Time Offset", -5.0, 5.0, 0.0),
        float_param("phase", "Phase", 0.0, 6.28318, rng.uniform(0, 3.14)),
        bool_param("bypass_when_inactive", "Bypass When Inactive", False),
        int_param("render_pass", "Render Pass", 0, 16, 0, kf=False),
        enum_param("alpha_mode", "Alpha Mode", ["Straight", "Premultiplied", "Ignore"], "Straight"),
        float_param("jitter_time", "Temporal Jitter", 0.0, 1.0, 0.0),
    ]


def block_matte_edge() -> list[dict]:
    return [
        float_param("matte_feather", "Matte Feather", 0.0, 200.0, 12.0),
        float_param("matte_contrast", "Matte Contrast", 0.0, 4.0, 1.0),
        float_param("matte_offset", "Matte Offset", -1.0, 1.0, 0.0),
        float_param("edge_choker", "Edge Choke", -50.0, 50.0, 0.0),
        bool_param("invert_matte", "Invert Matte", False),
        color_param("matte_tint", "Matte Tint", [1, 1, 1, 1]),
        curve_param("matte_curve", "Matte Curve", [[0, 0], [0.5, 0.5], [1, 1]]),
    ]


def block_audio_dynamics() -> list[dict]:
    return [
        float_param("input_gain_db", "Input Gain dB", -24.0, 24.0, 0.0),
        float_param("output_gain_db", "Output Gain dB", -24.0, 24.0, 0.0),
        float_param("attack_ms", "Attack ms", 0.1, 500.0, 10.0),
        float_param("release_ms", "Release ms", 1.0, 2000.0, 120.0),
        float_param("knee_db", "Knee dB", 0.0, 24.0, 3.0),
        enum_param("sidechain_mode", "Sidechain", ["Off", "External", "Internal"], "Off"),
        int_param("oversample", "Oversample", 1, 8, 2, kf=False),
    ]


def base_color_params(seed: int) -> list[dict]:
    rng = random.Random(seed)
    return [
        float_param("exposure_stop", "Exposure Stops", -6.0, 6.0, 0.0),
        float_param("contrast_pivot", "Contrast Pivot", 0.0, 1.0, 0.5),
        float_param("saturation", "Saturation", 0.0, 2.0, 1.0),
        color_param("tint", "Tint", [1.0, 1.0, 1.0, 1.0]),
        color_wheel_param("lift_wheel", "Lift Wheel", [0.5, 0.5, 0.5]),
        color_wheel_param("gamma_wheel", "Gamma Wheel", [0.5, 0.5, 0.5]),
        curve_param(
            "master_curve",
            "Master",
            [[0, 0], [0.25, 0.25], [0.5, 0.5], [0.75, 0.75], [1, 1]],
        ),
        float_param("film_grain_mix", "Film Grain Mix", 0.0, 1.0, 0.0),
        enum_param("working_space", "Working Space", ["Rec709", "Rec2020", "DCIP3", "ACEScg"], "Rec709"),
        bool_param("preserve_skin", "Preserve Skin Tones", False),
        float_param("skin_threshold", "Skin Threshold", 0.0, 1.0, 0.6),
        int_param("quality", "Quality", 0, 2, 1, kf=False),
        float_param("hue_rotate", "Hue Rotate", -180.0, 180.0, rng.uniform(-2, 2)),
    ]


def base_motion_params(seed: int) -> list[dict]:
    rng = random.Random(seed)
    return [
        float_param("mix", "Mix", 0.0, 1.0, 1.0),
        float_param("intensity", "Intensity", 0.0, 2.0, 1.0),
        float_param("scale_x", "Scale X", 0.1, 4.0, 1.0),
        float_param("scale_y", "Scale Y", 0.1, 4.0, 1.0),
        float_param("rotation", "Rotation", -180.0, 180.0, rng.uniform(-5, 5)),
        float_param("center_x", "Center X", -1.0, 1.0, 0.0),
        float_param("center_y", "Center Y", -1.0, 1.0, 0.0),
        float_param("edge_softness", "Edge Softness", 0.0, 1.0, 0.1),
        enum_param("blend_mode", "Blend Mode", ["Normal", "Add", "Multiply", "Screen"], "Normal"),
        bool_param("clamp", "Clamp Output", True),
        float_param("temporal_smooth", "Temporal Smooth", 0.0, 1.0, 0.25),
        float_param("blur_amount", "Blur Amount", 0.0, 200.0, 8.0),
        float_param("sharpen_amount", "Sharpen", 0.0, 2.0, 0.0),
    ]


def base_visual_params(seed: int) -> list[dict]:
    rng = random.Random(seed)
    return [
        float_param("glow_radius", "Glow Radius", 0.0, 120.0, 12.0),
        float_param("glow_threshold", "Glow Threshold", 0.0, 1.0, 0.65),
        float_param("aberration", "Aberration", 0.0, 40.0, 2.0),
        float_param("noise", "Noise", 0.0, 1.0, 0.05),
        float_param("vignette", "Vignette", 0.0, 1.0, 0.2),
        color_param("tint_low", "Shadow Tint", [0.05, 0.05, 0.1, 1.0]),
        color_param("tint_high", "Highlight Tint", [1.0, 0.95, 0.9, 1.0]),
        enum_param("sampling", "Sampling", ["Bilinear", "Bicubic", "Lanczos"], "Bilinear"),
        bool_param("hdr_mode", "HDR Mode", False),
        float_param("seed", "Random Seed", 0.0, 10000.0, rng.uniform(0, 1000)),
        float_param("bloom", "Bloom", 0.0, 3.0, 0.4),
        float_param("halation", "Halation", 0.0, 2.0, 0.15),
    ]


def base_transition_params(seed: int) -> list[dict]:
    return [
        float_param("duration", "Duration", 0.05, 5.0, 0.5),
        float_param("feather", "Feather", 0.0, 1.0, 0.15),
        float_param("softness", "Softness", 0.0, 1.0, 0.35),
        enum_param("direction", "Direction", ["Forward", "Reverse", "PingPong"], "Forward"),
        float_param("luma_low", "Luma Low", 0.0, 1.0, 0.0),
        float_param("luma_high", "Luma High", 0.0, 1.0, 1.0),
        color_param("tint_a", "Tint A", [1, 1, 1, 1]),
        color_param("tint_b", "Tint B", [1, 1, 1, 1]),
        bool_param("use_motion_blur", "Motion Blur", True),
        float_param("blur_shutter", "Blur Shutter Angle", 0.0, 360.0, 180.0),
        float_param("scale", "Zoom Scale", 0.5, 3.0, 1.15),
        float_param("rotation", "Rotation", -90.0, 90.0, 0.0),
    ]


def base_text_params(seed: int) -> list[dict]:
    return [
        string_param("text", "Text", "Fognitix", kf=False),
        enum_param("font_family", "Font", ["Inter", "Oswald", "JetBrains Mono", "Bebas Neue"], "Inter"),
        float_param("font_size", "Font Size", 8.0, 300.0, 48.0),
        color_param("color", "Color", [1, 1, 1, 1]),
        float_param("tracking", "Tracking", -50.0, 200.0, 0.0),
        float_param("leading", "Leading", 0.8, 3.0, 1.1),
        float_param("position_x", "Position X", -1.0, 1.0, 0.0),
        float_param("position_y", "Position Y", -1.0, 1.0, 0.0),
        enum_param("alignment", "Alignment", ["Left", "Center", "Right"], "Center"),
        bool_param("background_enabled", "Background", False),
        color_param("background_color", "Background Color", [0, 0, 0, 0.5]),
        float_param("animation_speed", "Animation Speed", 0.1, 10.0, 2.0),
        float_param("randomness", "Randomness", 0.0, 1.0, 0.05),
        string_param("locale_tag", "Locale Tag", "en", kf=False),
    ]


def base_audio_params(seed: int) -> list[dict]:
    return [
        float_param("wet_dry", "Wet/Dry", 0.0, 1.0, 0.75),
        float_param("drive", "Drive", 0.0, 24.0, 0.0),
        float_param("tone", "Tone", -1.0, 1.0, 0.0),
        float_param("width", "Stereo Width", 0.0, 2.0, 1.0),
        float_param("low_cut_hz", "Low Cut Hz", 10.0, 500.0, 30.0, kf=False),
        float_param("high_cut_hz", "High Cut Hz", 8000.0, 20000.0, 18000.0, kf=False),
        int_param("lookahead_ms", "Lookahead ms", 0, 20, 2, kf=False),
        bool_param("phase_linearize", "Linear Phase", True),
        float_param("latency_comp_ms", "Latency Comp ms", 0.0, 50.0, 0.0),
        enum_param("routing", "Routing", ["Insert", "Send"], "Insert"),
        float_param("threshold", "Threshold", -80.0, 0.0, -24.0),
        float_param("ratio", "Ratio", 1.0, 20.0, 3.0),
    ]


def category_schedule() -> list[str]:
    """Exactly TOTAL_EFFECTS entries, balanced mix."""
    parts = (
        ["color"] * 500
        + ["motion"] * 500
        + ["visual"] * 500
        + ["transitions"] * 220
        + ["text"] * 220
        + ["audio"] * 180
        + ["utility"] * 40
        + ["matte"] * 20
        + ["stylize"] * 20
    )
    assert len(parts) == TOTAL_EFFECTS
    return parts


def make_effect(idx: int) -> dict:
    categories = category_schedule()
    cat = categories[idx]
    shader_list = SHADER_FAMILIES[cat]
    shader = shader_list[idx % len(shader_list)] if shader_list[0] else ""

    if cat == "color":
        params = (
            base_color_params(idx)
            + block_spatial_transform(idx)
            + block_temporal_blend(idx)
            + [
                file_param("lut_file", "LUT File", [".cube", ".3dl", ".look"]),
                float_param("lut_intensity", "LUT Intensity", 0.0, 1.0, 0.85),
            ]
        )
        name = f"Color Operator {idx+1:04d}"
        eid = f"color_gen_{idx+1:04d}"
    elif cat == "motion":
        params = base_motion_params(idx) + block_spatial_transform(idx + 3) + block_temporal_blend(idx + 5)
        name = f"Motion Operator {idx+1:04d}"
        eid = f"motion_gen_{idx+1:04d}"
    elif cat == "visual":
        params = base_visual_params(idx) + block_spatial_transform(idx + 7) + block_temporal_blend(idx + 9)
        name = f"Visual Operator {idx+1:04d}"
        eid = f"visual_gen_{idx+1:04d}"
    elif cat == "transitions":
        params = base_transition_params(idx) + block_spatial_transform(idx + 11) + block_temporal_blend(idx + 13)
        name = f"Transition {idx+1:04d}"
        eid = f"transition_gen_{idx+1:04d}"
    elif cat == "text":
        params = base_text_params(idx) + block_spatial_transform(idx + 19) + block_temporal_blend(idx + 21)
        name = f"Text Operator {idx+1:04d}"
        eid = f"text_gen_{idx+1:04d}"
    elif cat == "audio":
        params = base_audio_params(idx) + block_audio_dynamics() + block_temporal_blend(idx + 23)
        name = f"Audio Operator {idx+1:04d}"
        eid = f"audio_gen_{idx+1:04d}"
    elif cat == "utility":
        params = base_motion_params(idx) + block_spatial_transform(idx + 29) + block_temporal_blend(idx + 31)
        name = f"Utility Operator {idx+1:04d}"
        eid = f"utility_gen_{idx+1:04d}"
    elif cat == "matte":
        params = base_visual_params(idx) + block_matte_edge() + block_temporal_blend(idx + 37)
        name = f"Matte Operator {idx+1:04d}"
        eid = f"matte_gen_{idx+1:04d}"
    else:  # stylize
        params = base_visual_params(idx) + block_spatial_transform(idx + 41) + [
            float_param("style_intensity", "Style Intensity", 0.0, 2.0, 1.0),
            enum_param("style_preset", "Style Preset", ["Clean", "Gritty", "Vintage", "Neon"], "Clean"),
            curve_param("response_curve", "Response", [[0, 0], [1, 1]]),
        ]
        name = f"Stylize Operator {idx+1:04d}"
        eid = f"stylize_gen_{idx+1:04d}"

    assert len(params) >= MIN_PARAMS, f"{eid} has {len(params)}"
    effect: dict = {"id": eid, "name": name, "category": cat, "parameters": params}
    if shader:
        effect["shader"] = shader
    return effect


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", type=Path, required=True)
    args = ap.parse_args()
    random.seed(1337)
    effects = [make_effect(i) for i in range(TOTAL_EFFECTS)]
    for i, e in enumerate(effects):
        n = len(e["parameters"])
        assert n >= MIN_PARAMS, f"index {i} id {e['id']} params {n}"
    data = {"version": 1, "effects": effects}
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(data, indent=2), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
