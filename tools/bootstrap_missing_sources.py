#!/usr/bin/env python3
"""Create missing Fognitix src modules with minimal compiling implementations."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

FILES = [
    "src/main.cpp",
    "src/Application.h",
    "src/Application.cpp",
    "src/core/engine/VideoEngine.h",
    "src/core/engine/VideoEngine.cpp",
    "src/core/engine/AudioEngine.h",
    "src/core/engine/AudioEngine.cpp",
    "src/core/engine/RenderEngine.h",
    "src/core/engine/RenderEngine.cpp",
    "src/core/engine/FrameProcessor.h",
    "src/core/engine/FrameProcessor.cpp",
    "src/core/engine/GPUPipeline.h",
    "src/core/engine/GPUPipeline.cpp",
    "src/core/engine/VulkanRenderer.h",
    "src/core/engine/VulkanRenderer.cpp",
    "src/core/engine/OpenGLRenderer.h",
    "src/core/engine/OpenGLRenderer.cpp",
    "src/core/engine/MemoryManager.h",
    "src/core/engine/MemoryManager.cpp",
    "src/core/engine/ThreadPool.h",
    "src/core/engine/ThreadPool.cpp",
    "src/core/engine/CacheManager.h",
    "src/core/engine/CacheManager.cpp",
    "src/core/timeline/Timeline.h",
    "src/core/timeline/Timeline.cpp",
    "src/core/timeline/TimelineTrack.h",
    "src/core/timeline/TimelineTrack.cpp",
    "src/core/timeline/TimelineClip.h",
    "src/core/timeline/TimelineClip.cpp",
    "src/core/timeline/Keyframe.h",
    "src/core/timeline/Keyframe.cpp",
    "src/core/timeline/KeyframeGraph.h",
    "src/core/timeline/KeyframeGraph.cpp",
    "src/core/timeline/Composition.h",
    "src/core/timeline/Composition.cpp",
    "src/core/timeline/NestedComposition.h",
    "src/core/timeline/NestedComposition.cpp",
    "src/core/timeline/AdjustmentLayer.h",
    "src/core/timeline/AdjustmentLayer.cpp",
    "src/core/timeline/NullObject.h",
    "src/core/timeline/NullObject.cpp",
    "src/core/timeline/ShapeLayer.h",
    "src/core/timeline/ShapeLayer.cpp",
    "src/core/timeline/TextLayer.h",
    "src/core/timeline/TextLayer.cpp",
    "src/core/timeline/SolidLayer.h",
    "src/core/timeline/SolidLayer.cpp",
    "src/core/timeline/EditOperations.h",
    "src/core/timeline/EditOperations.cpp",
    "src/core/timeline/RippleEdit.h",
    "src/core/timeline/RippleEdit.cpp",
    "src/core/timeline/RollingEdit.h",
    "src/core/timeline/RollingEdit.cpp",
    "src/core/timeline/SlipEdit.h",
    "src/core/timeline/SlipEdit.cpp",
    "src/core/timeline/SlideEdit.h",
    "src/core/timeline/SlideEdit.cpp",
    "src/core/timeline/SpeedControl.h",
    "src/core/timeline/SpeedControl.cpp",
    "src/core/timeline/TimeRemap.h",
    "src/core/timeline/TimeRemap.cpp",
    "src/core/timeline/OpticalFlow.h",
    "src/core/timeline/OpticalFlow.cpp",
    "src/core/effects/EffectManager.h",
    "src/core/effects/EffectManager.cpp",
    "src/core/effects/EffectStack.h",
    "src/core/effects/EffectStack.cpp",
    "src/core/effects/EffectRegistry.h",
    "src/core/effects/EffectRegistry.cpp",
    "src/core/effects/EffectMask.h",
    "src/core/effects/EffectMask.cpp",
    "src/core/effects/EffectExpression.h",
    "src/core/effects/EffectExpression.cpp",
    "src/core/ai/AIEngine.h",
    "src/core/ai/AIEngine.cpp",
    "src/core/ai/GroqClient.h",
    "src/core/ai/GroqClient.cpp",
    "src/core/ai/PromptParser.h",
    "src/core/ai/PromptParser.cpp",
    "src/core/ai/CommandExecutor.h",
    "src/core/ai/CommandExecutor.cpp",
    "src/core/ai/SceneAnalyzer.h",
    "src/core/ai/SceneAnalyzer.cpp",
    "src/core/ai/AutoEditor.h",
    "src/core/ai/AutoEditor.cpp",
    "src/core/ai/AutoColorAI.h",
    "src/core/ai/AutoColorAI.cpp",
    "src/core/ai/BeatSyncAI.h",
    "src/core/ai/BeatSyncAI.cpp",
    "src/core/ai/SilenceRemover.h",
    "src/core/ai/SilenceRemover.cpp",
    "src/core/ai/CaptionAI.h",
    "src/core/ai/CaptionAI.cpp",
    "src/core/ai/StyleTransferAI.h",
    "src/core/ai/StyleTransferAI.cpp",
    "src/core/ai/AnalyticsAI.h",
    "src/core/ai/AnalyticsAI.cpp",
    "src/core/ai/FaceTracker.h",
    "src/core/ai/FaceTracker.cpp",
    "src/core/ai/ObjectTracker.h",
    "src/core/ai/ObjectTracker.cpp",
    "src/core/ai/FrameInterpolation.h",
    "src/core/ai/FrameInterpolation.cpp",
    "src/core/ai/AICommandSchema.h",
    "src/core/ai/AICommandSchema.cpp",
    "src/core/codec/VideoDecoder.h",
    "src/core/codec/VideoDecoder.cpp",
    "src/core/codec/VideoEncoder.h",
    "src/core/codec/VideoEncoder.cpp",
    "src/core/codec/AudioDecoder.h",
    "src/core/codec/AudioDecoder.cpp",
    "src/core/codec/AudioEncoder.h",
    "src/core/codec/AudioEncoder.cpp",
    "src/core/codec/FormatManager.h",
    "src/core/codec/FormatManager.cpp",
    "src/core/codec/HardwareEncoder.h",
    "src/core/codec/HardwareEncoder.cpp",
    "src/core/codec/ProxyGenerator.h",
    "src/core/codec/ProxyGenerator.cpp",
    "src/core/export/ExportEngine.h",
    "src/core/export/ExportEngine.cpp",
    "src/core/export/ExportQueue.h",
    "src/core/export/ExportQueue.cpp",
    "src/core/export/ExportPreset.h",
    "src/core/export/ExportPreset.cpp",
    "src/core/export/MP4Exporter.h",
    "src/core/export/MP4Exporter.cpp",
    "src/core/export/ProResExporter.h",
    "src/core/export/ProResExporter.cpp",
    "src/core/export/DNxExporter.h",
    "src/core/export/DNxExporter.cpp",
    "src/core/export/GIFExporter.h",
    "src/core/export/GIFExporter.cpp",
    "src/core/export/ImageSequenceExporter.h",
    "src/core/export/ImageSequenceExporter.cpp",
    "src/core/export/AudioExporter.h",
    "src/core/export/AudioExporter.cpp",
    "src/core/project/Project.h",
    "src/core/project/Project.cpp",
    "src/core/project/ProjectManager.h",
    "src/core/project/ProjectManager.cpp",
    "src/core/project/AutoSave.h",
    "src/core/project/AutoSave.cpp",
    "src/core/project/UndoStack.h",
    "src/core/project/UndoStack.cpp",
    "src/core/project/VersionHistory.h",
    "src/core/project/VersionHistory.cpp",
    "src/core/project/MediaPool.h",
    "src/core/project/MediaPool.cpp",
    "src/core/project/TemplateSystem.h",
    "src/core/project/TemplateSystem.cpp",
    "src/core/state/Observable.h",
    "src/core/state/AppState.h",
    "src/core/state/AppState.cpp",
    "src/core/state/SecureCredentialStore.h",
    "src/core/state/SecureCredentialStore.cpp",
    "src/ui/MainWindow.h",
    "src/ui/MainWindow.cpp",
    "src/ui/windows/EditorWindow.h",
    "src/ui/windows/EditorWindow.cpp",
    "src/ui/windows/ExportWindow.h",
    "src/ui/windows/ExportWindow.cpp",
    "src/ui/windows/ImportWindow.h",
    "src/ui/windows/ImportWindow.cpp",
    "src/ui/windows/SettingsWindow.h",
    "src/ui/windows/SettingsWindow.cpp",
    "src/ui/windows/AgentWindow.h",
    "src/ui/windows/AgentWindow.cpp",
    "src/ui/windows/EffectsWindow.h",
    "src/ui/windows/EffectsWindow.cpp",
    "src/ui/windows/ColorWindow.h",
    "src/ui/windows/ColorWindow.cpp",
    "src/ui/windows/AudioWindow.h",
    "src/ui/windows/AudioWindow.cpp",
    "src/ui/windows/AnalyticsWindow.h",
    "src/ui/windows/AnalyticsWindow.cpp",
    "src/ui/windows/MediaBrowserWindow.h",
    "src/ui/windows/MediaBrowserWindow.cpp",
    "src/ui/panels/ProjectPanel.h",
    "src/ui/panels/ProjectPanel.cpp",
    "src/ui/panels/PreviewPanel.h",
    "src/ui/panels/PreviewPanel.cpp",
    "src/ui/panels/TimelinePanel.h",
    "src/ui/panels/TimelinePanel.cpp",
    "src/ui/panels/EffectsPanel.h",
    "src/ui/panels/EffectsPanel.cpp",
    "src/ui/panels/PropertiesPanel.h",
    "src/ui/panels/PropertiesPanel.cpp",
    "src/ui/panels/ColorPanel.h",
    "src/ui/panels/ColorPanel.cpp",
    "src/ui/panels/AudioMixerPanel.h",
    "src/ui/panels/AudioMixerPanel.cpp",
    "src/ui/panels/AIPromptPanel.h",
    "src/ui/panels/AIPromptPanel.cpp",
    "src/ui/panels/ScopesPanel.h",
    "src/ui/panels/ScopesPanel.cpp",
]


def class_name_from_file(stem: str) -> str:
    parts = re.split(r"[_-]", stem)
    return "".join(p[:1].upper() + p[1:] for p in parts if p)


def ns_for(path: Path) -> str:
    rel = str(path).replace("\\", "/")
    if "/timeline/" in rel:
        return "Fognitix::Timeline"
    if "/codec/" in rel:
        return "Fognitix::Codec"
    if "/export/" in rel:
        return "Fognitix::Export"
    if "/project/" in rel:
        return "Fognitix::Project"
    if "/ai/" in rel:
        return "Fognitix::AI"
    if "/engine/" in rel:
        return "Fognitix::Engine"
    if "/effects/" in rel:
        return "Fognitix::Effects"
    if "/state/" in rel:
        return "Fognitix::State"
    if "/ui/" in rel:
        return "Fognitix::UI"
    return "Fognitix"


def write_header(path: Path, cls: str, ns: str) -> None:
    guard = re.sub(r"[^A-Z0-9]", "_", str(path.relative_to(ROOT)).upper())
    guard = f"FOGNITIX_{guard}_H"
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        return
    path.write_text(
        f"#pragma once\n#ifndef {guard}\n#define {guard}\n\nnamespace {ns} {{\n\nclass {cls} {{\npublic:\n    {cls}();\n    ~{cls}();\n}};\n\n}} // namespace {ns}\n\n#endif\n",
        encoding="utf-8",
    )


def write_cpp(path: Path, cls: str, ns: str) -> None:
    h = path.with_suffix(".h").name
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        return
    path.write_text(
        f'#include "{h}"\n\nnamespace {ns} {{\n\n{cls}::{cls}() = default;\n{cls}::~{cls}() = default;\n\n}} // namespace {ns}\n',
        encoding="utf-8",
    )


def main() -> None:
    for rel in FILES:
        path = ROOT / rel
        stem = path.stem
        if stem == "main":
            continue
        if stem == "Application":
            continue
        if stem == "Observable":
            continue
        cls = class_name_from_file(stem)
        ns = ns_for(path)
        if path.suffix == ".h":
            write_header(path, cls, ns)
        elif path.suffix == ".cpp":
            hdr = path.with_suffix(".h")
            if not hdr.exists():
                write_header(hdr, cls, ns)
            write_cpp(path, cls, ns)


if __name__ == "__main__":
    main()
