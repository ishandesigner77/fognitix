cmake_minimum_required(VERSION 3.28)
project(Fognitix VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

option(FOGNITIX_ENABLE_SANITIZERS "Enable MSVC ASan when supported" OFF)
option(FOGNITIX_ENABLE_VULKAN "Enable Vulkan renderer path" ON)
option(FOGNITIX_ENABLE_OPENCV "Enable OpenCV integrations" OFF)
option(FOGNITIX_ENABLE_ONNX "Enable ONNX Runtime integrations" OFF)

include(GNUInstallDirs)

find_package(Python3 COMPONENTS Interpreter REQUIRED)

set(FOGNITIX_GENERATED_REGISTRY "${CMAKE_BINARY_DIR}/generated/registry.generated.json")
add_custom_command(
    OUTPUT "${FOGNITIX_GENERATED_REGISTRY}"
    COMMAND "${Python3_EXECUTABLE}" "${CMAKE_SOURCE_DIR}/tools/gen_effect_registry.py" --out
            "${FOGNITIX_GENERATED_REGISTRY}"
    DEPENDS "${CMAKE_SOURCE_DIR}/tools/gen_effect_registry.py"
    VERBATIM)

find_package(Qt6 6.6 REQUIRED COMPONENTS Core Gui Widgets Quick QuickControls2 Concurrent Sql Network
                                        Svg OpenGL OpenGLWidgets)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(FFMPEG REQUIRED)
find_package(OpenCV QUIET)
find_package(onnxruntime QUIET)
find_package(portaudio CONFIG QUIET)
find_package(PortAudio CONFIG QUIET)
find_package(libsoundio CONFIG QUIET)

if(TARGET portaudio)
    set(FOGNITIX_PORTAUDIO_LIB portaudio)
    set(FOGNITIX_HAVE_PORTAUDIO TRUE)
elseif(TARGET PortAudio::PortAudio)
    set(FOGNITIX_PORTAUDIO_LIB PortAudio::PortAudio)
    set(FOGNITIX_HAVE_PORTAUDIO TRUE)
elseif(TARGET unofficial::portaudio::portaudio)
    set(FOGNITIX_PORTAUDIO_LIB unofficial::portaudio::portaudio)
    set(FOGNITIX_HAVE_PORTAUDIO TRUE)
else()
    message(WARNING "PortAudio not found — audio playback will be disabled")
    set(FOGNITIX_HAVE_PORTAUDIO FALSE)
endif()
find_package(unofficial-sqlite3 CONFIG REQUIRED)

if(FOGNITIX_ENABLE_VULKAN)
    find_package(Vulkan QUIET)
endif()

file(GLOB_RECURSE FOGNITIX_CPP CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/*.cpp")
file(GLOB_RECURSE FOGNITIX_HEADERS CONFIGURE_DEPENDS "${CMAKE_SOURCE_DIR}/src/*.h")

set(FOGNITIX_QML_FILES
    src/ui/menus/AppMenuBar.qml
    src/ui/menus/FileMenu.qml
    src/ui/menus/EditMenu.qml
    src/ui/MainWindow.qml
    src/ui/windows/EditorWindow.qml
    src/ui/windows/ExportWindow.qml
    src/ui/windows/ImportWindow.qml
    src/ui/windows/SettingsWindow.qml
    src/ui/windows/AgentWindow.qml
    src/ui/windows/EffectsWindow.qml
    src/ui/windows/ColorWindow.qml
    src/ui/windows/AudioWindow.qml
    src/ui/windows/AnalyticsWindow.qml
    src/ui/windows/MediaBrowserWindow.qml
    src/ui/panels/ProjectPanel.qml
    src/ui/panels/MediaPoolPanel.qml
    src/ui/panels/PreviewPanel.qml
    src/ui/panels/TimelinePanel.qml
    src/ui/panels/EffectsPanel.qml
    src/ui/panels/EffectsBrowser.qml
    src/ui/panels/AlignPanel.qml
    src/ui/panels/CharacterPanel.qml
    src/ui/panels/ContentAwareFillPanel.qml
    src/ui/panels/EssentialGraphicsPanel.qml
    src/ui/panels/FootageInfoPanel.qml
    src/ui/panels/FlowchartPanel.qml
    src/ui/panels/GraphEditorPanel.qml
    src/ui/panels/InfoPanel.qml
    src/ui/panels/LibraryPanel.qml
    src/ui/panels/LumetriScopesPanel.qml
    src/ui/panels/MaskInterpolationPanel.qml
    src/ui/panels/MediaBrowserPanel.qml
    src/ui/panels/MetadataPanel.qml
    src/ui/panels/MotionSketchPanel.qml
    src/ui/panels/ParagraphPanel.qml
    src/ui/panels/PropertiesPanel.qml
    src/ui/panels/ColorPanel.qml
    src/ui/panels/AudioMixerPanel.qml
    src/ui/panels/AIPromptPanel.qml
    src/ui/panels/PanelRegistry.qml
    src/ui/panels/PanelPlaceholder.qml
    src/ui/panels/TransitionsPanel.qml
    src/ui/panels/ScopesPanel.qml
    src/ui/panels/SmootherPanel.qml
    src/ui/panels/ThreeDPanel.qml
    src/ui/panels/TrackerPanel.qml
    src/ui/components/ToolIcon.qml
    src/ui/components/TimelineTrackView.qml
    src/ui/components/TimelineClipView.qml
    src/ui/components/TimelineRuler.qml
    src/ui/components/TimelinePlayhead.qml
    src/ui/components/KeyframeEditor.qml
    src/ui/components/GraphEditor.qml
    src/ui/components/EffectCard.qml
    src/ui/components/EffectControls.qml
    src/ui/components/EffectStackPanel.qml
    src/ui/components/ParameterSlider.qml
    src/ui/components/ParameterColorPicker.qml
    src/ui/components/ParameterAngleDial.qml
    src/ui/components/ParameterCurveEditor.qml
    src/ui/components/ParameterCheckbox.qml
    src/ui/components/ParameterDropdown.qml
    src/ui/components/WaveformMonitor.qml
    src/ui/components/Vectorscope.qml
    src/ui/components/Histogram.qml
    src/ui/components/ParadeScope.qml
    src/ui/components/AudioVUMeter.qml
    src/ui/components/MediaThumbnail.qml
    src/ui/components/TransportControls.qml
    src/ui/components/ZoomControl.qml
    src/ui/components/ProgressBar.qml
    src/ui/components/StatusBar.qml
    src/ui/components/AIResponseCard.qml
    src/ui/components/SplashScreen.qml
    src/ui/components/FxButton.qml
    src/ui/components/FxTabBar.qml
    src/ui/components/FxTextField.qml
    src/ui/components/HomeScreen.qml
    src/ui/dialogs/NewProjectDialog.qml
    src/ui/dialogs/CompositionSettingsDialog.qml
    src/ui/dialogs/ExportDialog.qml
    src/ui/components/ShortcutManager.qml
    src/ui/windows/WelcomeScreen.qml
    src/ui/panels/MarkersPanel.qml
    src/ui/panels/RenderQueuePanel.qml
    src/ui/panels/HistoryPanel.qml
    src/ui/panels/InspectorPanel.qml
    src/ui/theme/Theme.qml
    src/ui/theme/Colors.qml
    src/ui/theme/ColorsLight.qml
    src/ui/theme/Spacing.qml
    src/ui/theme/Typography.qml
    src/ui/theme/Icons.qml
    src/ui/theme/Animations.qml)

set_source_files_properties("${FOGNITIX_GENERATED_REGISTRY}" PROPERTIES
    GENERATED TRUE
    QT_RESOURCE_ALIAS "registry.generated.json")

qt_standard_project_setup()

qt_add_executable(Fognitix WIN32 MACOSX_BUNDLE ${FOGNITIX_CPP} ${FOGNITIX_HEADERS})

add_custom_target(fognitix_generated_registry DEPENDS "${FOGNITIX_GENERATED_REGISTRY}")
add_dependencies(Fognitix fognitix_generated_registry)

set_property(SOURCE "${CMAKE_SOURCE_DIR}/resources.qrc" APPEND PROPERTY OBJECT_DEPENDS "${FOGNITIX_GENERATED_REGISTRY}")
target_sources(Fognitix PRIVATE "${CMAKE_SOURCE_DIR}/resources.qrc")

qt_add_resources(
    Fognitix
    "fognitix_registry"
    PREFIX
    "/effects"
    FILES
    "${FOGNITIX_GENERATED_REGISTRY}")

qt_add_qml_module(
    Fognitix
    URI
    Fognitix
    VERSION
    1.0
    QML_FILES
    ${FOGNITIX_QML_FILES})

set_target_properties(Fognitix PROPERTIES WIN_EXECUTABLE TRUE)

# Headless engine sidecar for the Tauri/React shell (stdio JSON-RPC–style lines).
add_executable(fognitix-engine engine/sidecar/main.cpp)
target_compile_features(fognitix-engine PRIVATE cxx_std_20)
set_target_properties(
    fognitix-engine
    PROPERTIES OUTPUT_NAME "fognitix-engine" AUTOMOC OFF AUTOUIC OFF AUTORCC OFF)
install(TARGETS fognitix-engine RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

target_include_directories(
    Fognitix
    PRIVATE
        "${CMAKE_SOURCE_DIR}/src"
        "${CMAKE_SOURCE_DIR}/src/core/effects"
        "${CMAKE_SOURCE_DIR}/src/core/effects/color"
        "${CMAKE_SOURCE_DIR}/src/core/effects/motion"
        "${CMAKE_SOURCE_DIR}/src/core/effects/visual"
        "${CMAKE_SOURCE_DIR}/src/core/effects/transitions"
        "${CMAKE_SOURCE_DIR}/src/core/effects/text"
        "${CMAKE_SOURCE_DIR}/src/core/effects/audio"
        ${FFMPEG_INCLUDE_DIRS})

target_link_directories(Fognitix PRIVATE ${FFMPEG_LIBRARY_DIRS})

target_compile_definitions(Fognitix PRIVATE QT_NO_CAST_FROM_BYTEARRAY QT_DISABLE_DEPRECATED_BEFORE=0x060600)

if(FOGNITIX_ENABLE_VULKAN AND Vulkan_FOUND)
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_VULKAN=1)
else()
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_VULKAN=0)
endif()

if(MSVC AND FOGNITIX_ENABLE_SANITIZERS)
    target_compile_options(Fognitix PRIVATE /fsanitize=address)
    target_link_options(Fognitix PRIVATE /INFERASANLIBS /fsanitize=address)
endif()

target_link_libraries(
    Fognitix
    PRIVATE Qt6::Core
            Qt6::Gui
            Qt6::Widgets
            Qt6::Quick
            Qt6::QuickControls2
            Qt6::Concurrent
            Qt6::Sql
            Qt6::Network
            Qt6::Svg
            Qt6::OpenGL
            Qt6::OpenGLWidgets
            ${FFMPEG_LIBRARIES}
            unofficial::sqlite3::sqlite3)

if(FOGNITIX_HAVE_PORTAUDIO)
    target_link_libraries(Fognitix PRIVATE ${FOGNITIX_PORTAUDIO_LIB})
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_PORTAUDIO=1)
else()
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_PORTAUDIO=0)
endif()

if(TARGET libsoundio::libsoundio)
    target_link_libraries(Fognitix PRIVATE libsoundio::libsoundio)
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_SOUNDIO=1)
else()
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_SOUNDIO=0)
endif()

if(FOGNITIX_ENABLE_OPENCV AND OpenCV_FOUND)
    target_include_directories(Fognitix PRIVATE ${OpenCV_INCLUDE_DIRS})
    target_link_libraries(Fognitix PRIVATE ${OpenCV_LIBS})
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_OPENCV=1)
else()
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_OPENCV=0)
endif()

if(FOGNITIX_ENABLE_ONNX AND onnxruntime_FOUND)
    if(TARGET onnxruntime::onnxruntime)
        target_link_libraries(Fognitix PRIVATE onnxruntime::onnxruntime)
    else()
        target_link_libraries(Fognitix PRIVATE onnxruntime)
    endif()
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_ONNX=1)
else()
    target_compile_definitions(Fognitix PRIVATE FOGNITIX_HAVE_ONNX=0)
endif()

if(Vulkan_FOUND)
    target_link_libraries(Fognitix PRIVATE Vulkan::Vulkan)
endif()

if(WIN32)
    target_link_libraries(Fognitix PRIVATE crypt32 secur32 bcrypt dxgi)
endif()

# Qt Quick needs Qt DLLs + platforms/qwindows.dll beside the .exe when Qt is not on PATH.
# (FFmpeg/PortAudio/SQLite are deployed by vcpkg's applocal.ps1 hook during the link step.)
if(WIN32)
    get_target_property(_fognitix_qmake Qt6::qmake IMPORTED_LOCATION)
    if(_fognitix_qmake)
        get_filename_component(_fognitix_qt_bin "${_fognitix_qmake}" DIRECTORY)
        find_program(FOGNITIX_WINDEPLOYQT windeployqt HINTS "${_fognitix_qt_bin}")
        if(FOGNITIX_WINDEPLOYQT)
            add_custom_command(
                TARGET Fognitix
                POST_BUILD
                COMMAND "${FOGNITIX_WINDEPLOYQT}"
                        $<$<CONFIG:Debug>:--debug>
                        $<$<NOT:$<CONFIG:Debug>>:--release>
                        --verbose 0
                        --no-translations
                        --qmldir "${CMAKE_SOURCE_DIR}/src/ui"
                        "$<TARGET_FILE:Fognitix>"
                COMMENT "windeployqt → Qt DLLs + platforms/ next to Fognitix.exe")
        else()
            message(WARNING "windeployqt not found (Qt bin). Fognitix may not start unless Qt is on PATH.")
        endif()
    endif()
endif()

install(
    TARGETS Fognitix
    BUNDLE DESTINATION .
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}")

enable_testing()

set(FOGNITIX_TEST_SQL_LIBS Qt6::Core Qt6::Sql unofficial::sqlite3::sqlite3)
set(FOGNITIX_TEST_FFMPEG_LIBS ${FFMPEG_LIBRARIES})

add_executable(
    test_timeline
    tests/test_timeline.cpp
    src/core/project/Project.cpp
    src/core/timeline/Timeline.cpp
    src/core/timeline/TimelineTrack.cpp
    src/core/timeline/TimelineClip.cpp
    src/core/timeline/EditOperations.cpp)
target_link_libraries(test_timeline PRIVATE ${FOGNITIX_TEST_SQL_LIBS})
target_include_directories(test_timeline PRIVATE "${CMAKE_SOURCE_DIR}/src")
add_test(NAME test_timeline COMMAND test_timeline)

configure_file(
    "${CMAKE_SOURCE_DIR}/tests/test_registry_path.h.in"
    "${CMAKE_BINARY_DIR}/tests/test_registry_path.h"
    @ONLY)

add_executable(test_effects tests/test_effects.cpp src/core/effects/EffectRegistry.cpp)
target_link_libraries(test_effects PRIVATE Qt6::Core)
target_include_directories(
    test_effects
    PRIVATE "${CMAKE_SOURCE_DIR}/src" "${CMAKE_BINARY_DIR}/tests")
add_dependencies(test_effects fognitix_generated_registry)
add_test(NAME test_effects COMMAND test_effects)

add_executable(
    test_ai
    tests/test_ai.cpp
    src/core/ai/AICommandSchema.cpp
    src/core/ai/CommandExecutor.cpp
    src/core/project/Project.cpp
    src/core/state/AppState.cpp
    src/core/timeline/Timeline.cpp
    src/core/timeline/TimelineTrack.cpp
    src/core/timeline/TimelineClip.cpp
    src/core/timeline/EditOperations.cpp)
target_link_libraries(test_ai PRIVATE ${FOGNITIX_TEST_SQL_LIBS} Qt6::Gui)
target_include_directories(test_ai PRIVATE "${CMAKE_SOURCE_DIR}/src")
add_test(NAME test_ai COMMAND test_ai)

add_executable(test_codec tests/test_codec.cpp src/core/codec/VideoDecoder.cpp)
target_link_libraries(test_codec PRIVATE Qt6::Core ${FOGNITIX_TEST_FFMPEG_LIBS})
target_include_directories(test_codec PRIVATE "${CMAKE_SOURCE_DIR}/src" ${FFMPEG_INCLUDE_DIRS})
target_link_directories(test_codec PRIVATE ${FFMPEG_LIBRARY_DIRS})
add_test(NAME test_codec COMMAND test_codec)

add_executable(test_export tests/test_export.cpp src/core/export/MP4Exporter.cpp)
target_link_libraries(test_export PRIVATE Qt6::Core ${FOGNITIX_TEST_FFMPEG_LIBS})
target_include_directories(test_export PRIVATE "${CMAKE_SOURCE_DIR}/src" ${FFMPEG_INCLUDE_DIRS})
target_link_directories(test_export PRIVATE ${FFMPEG_LIBRARY_DIRS})
add_test(NAME test_export COMMAND test_export)
