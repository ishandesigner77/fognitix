import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Fognitix

Rectangle {
    id: root
    color: theme.colors.panelBackground

    Theme {
        id: theme
    }

    // -------------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------------

    function categoryAccent(cat) {
        if (!cat || cat.length === 0)
            return theme.colors.accent
        let h = 0
        for (let i = 0; i < cat.length; ++i)
            h = (h * 31 + cat.charCodeAt(i)) >>> 0
        return Qt.hsla((h % 360) / 360, 0.5, 0.48, 1)
    }

    // -------------------------------------------------------------------------
    // Effects database
    // -------------------------------------------------------------------------

    readonly property var effectsDb: [
        {
            category: "3D Channel",
            effects: [
                { id: "3dc.extract",   name: "3D Channel Extract" },
                { id: "3dc.depthmatte",name: "Depth Matte" },
                { id: "3dc.dof",       name: "Depth of Field" },
                { id: "3dc.extractor", name: "EXtractoR" },
                { id: "3dc.idmatte",   name: "ID Matte" },
                { id: "3dc.idselect",  name: "ID Selection" }
            ]
        },
        {
            category: "Audio",
            effects: [
                { id: "aud.backwards",   name: "Backwards" },
                { id: "aud.basstreb",    name: "Bass & Treble" },
                { id: "aud.compressor",  name: "Compressor" },
                { id: "aud.delay",       name: "Delay" },
                { id: "aud.flange",      name: "Flange & Chorus" },
                { id: "aud.hilopass",    name: "High-Low Pass" },
                { id: "aud.modulator",   name: "Modulator" },
                { id: "aud.noisegate",   name: "Noise Gate" },
                { id: "aud.notch",       name: "Notch Filter" },
                { id: "aud.parameq",     name: "Parametric EQ" },
                { id: "aud.phaser",      name: "Phaser" },
                { id: "aud.pitch",       name: "Pitch Shifter" },
                { id: "aud.reverb",      name: "Reverb" },
                { id: "aud.stereomix",   name: "Stereo Mixer" },
                { id: "aud.tone",        name: "Tone" },
                { id: "aud.warp",        name: "Warp" }
            ]
        },
        {
            category: "Blur & Sharpen",
            effects: [
                { id: "blr.bilateral",    name: "Bilateral Blur" },
                { id: "blr.cameralens",   name: "Camera Lens Blur" },
                { id: "blr.cccross",      name: "CC Cross Blur" },
                { id: "blr.ccradial",     name: "CC Radial Blur" },
                { id: "blr.ccradfast",    name: "CC Radial Fast Blur" },
                { id: "blr.ccvector",     name: "CC Vector Blur" },
                { id: "blr.channel",      name: "Channel Blur" },
                { id: "blr.compound",     name: "Compound Blur" },
                { id: "blr.dpupscale",    name: "Detail-Preserving Upscale" },
                { id: "blr.directional",  name: "Directional Blur" },
                { id: "blr.fastbox",      name: "Fast Box Blur" },
                { id: "blr.gaussian",     name: "Gaussian Blur" },
                { id: "blr.lens",         name: "Lens Blur" },
                { id: "blr.radial",       name: "Radial Blur" },
                { id: "blr.reduceintl",   name: "Reduce Interlace Flicker" },
                { id: "blr.sharpen",      name: "Sharpen" },
                { id: "blr.smart",        name: "Smart Blur" },
                { id: "blr.tiltshift",    name: "Tilt-Shift Blur" },
                { id: "blr.unsharp",      name: "Unsharp Mask" },
                { id: "blr.warpstab",     name: "Warp Stabilizer VFX" },
                { id: "blr.box",          name: "Box Blur" },
                { id: "blr.motion",       name: "Motion Blur" }
            ]
        },
        {
            category: "Channel",
            effects: [
                { id: "chn.arithmetic",   name: "Arithmetic" },
                { id: "chn.blend",        name: "Blend" },
                { id: "chn.calculations", name: "Calculations" },
                { id: "chn.combiner",     name: "Channel Combiner" },
                { id: "chn.comparith",    name: "Compound Arithmetic" },
                { id: "chn.invert",       name: "Invert" },
                { id: "chn.minimax",      name: "Minimax" },
                { id: "chn.removematte",  name: "Remove Color Matting" },
                { id: "chn.setchannels",  name: "Set Channels" },
                { id: "chn.setmatte",     name: "Set Matte" },
                { id: "chn.shift",        name: "Shift Channels" },
                { id: "chn.solidcomp",    name: "Solid Composite" }
            ]
        },
        {
            category: "Color Correction",
            effects: [
                { id: "col.autocolor",     name: "Auto Color" },
                { id: "col.autocontrast",  name: "Auto Contrast" },
                { id: "col.autolevels",    name: "Auto Levels" },
                { id: "col.bw",            name: "Black & White" },
                { id: "col.brightness",    name: "Brightness & Contrast" },
                { id: "col.broadcast",     name: "Broadcast Colors" },
                { id: "col.cameraraw",     name: "Camera RAW Filter" },
                { id: "col.changecolor",   name: "Change Color" },
                { id: "col.changeto",      name: "Change to Color" },
                { id: "col.chanmixer",     name: "Channel Mixer" },
                { id: "col.balance",       name: "Color Balance" },
                { id: "col.balancehls",    name: "Color Balance (HLS)" },
                { id: "col.link",          name: "Color Link" },
                { id: "col.stabilizer",    name: "Color Stabilizer" },
                { id: "col.colorama",      name: "Colorama" },
                { id: "col.curves",        name: "Curves" },
                { id: "col.equalize",      name: "Equalize" },
                { id: "col.exposure",      name: "Exposure" },
                { id: "col.gammapg",       name: "Gamma/Pedestal/Gain" },
                { id: "col.huesat",        name: "Hue/Saturation" },
                { id: "col.leavecolor",    name: "Leave Color" },
                { id: "col.levels",        name: "Levels" },
                { id: "col.lumetri",       name: "Lumetri Color" },
                { id: "col.photo",         name: "Photo Filter" },
                { id: "col.selective",     name: "Selective Color" },
                { id: "col.shadowhl",      name: "Shadow/Highlight" },
                { id: "col.tint",          name: "Tint" },
                { id: "col.tritone",       name: "Tritone" },
                { id: "col.vibrance",      name: "Vibrance" },
                { id: "col.videolim",      name: "Video Limiter" },
                { id: "col.whitebal",      name: "White Balance" },
                { id: "col.lut",           name: "Color LUT" }
            ]
        },
        {
            category: "Distort",
            effects: [
                { id: "dst.bezierwarp",  name: "Bezier Warp" },
                { id: "dst.bulge",       name: "Bulge" },
                { id: "dst.ccbendit",    name: "CC Bend It" },
                { id: "dst.ccbender",    name: "CC Bender" },
                { id: "dst.ccblob",      name: "CC Blobbylize" },
                { id: "dst.ccflo",       name: "CC Flo Motion" },
                { id: "dst.ccgrid",      name: "CC Griddler" },
                { id: "dst.cclens",      name: "CC Lens" },
                { id: "dst.ccpage",      name: "CC Page Turn" },
                { id: "dst.ccpower",     name: "CC Power Pin" },
                { id: "dst.ccripple",    name: "CC Ripple Pulse" },
                { id: "dst.ccslant",     name: "CC Slant" },
                { id: "dst.ccsmear",     name: "CC Smear" },
                { id: "dst.ccsplit",     name: "CC Split" },
                { id: "dst.ccsplit2",    name: "CC Split 2" },
                { id: "dst.cctiler",     name: "CC Tiler" },
                { id: "dst.dispmap",     name: "Displacement Map" },
                { id: "dst.liquify",     name: "Liquify" },
                { id: "dst.magnify",     name: "Magnify" },
                { id: "dst.meshwarp",    name: "Mesh Warp" },
                { id: "dst.mirror",      name: "Mirror" },
                { id: "dst.offset",      name: "Offset" },
                { id: "dst.optics",      name: "Optics Compensation" },
                { id: "dst.polar",       name: "Polar Coordinates" },
                { id: "dst.reshape",     name: "Reshape" },
                { id: "dst.ripple",      name: "Ripple" },
                { id: "dst.rollingshut", name: "Rolling Shutter Repair" },
                { id: "dst.spherize",    name: "Spherize" },
                { id: "dst.transform",   name: "Transform" },
                { id: "dst.turbulent",   name: "Turbulent Displace" },
                { id: "dst.twirl",       name: "Twirl" },
                { id: "dst.wavewarp",    name: "Wave Warp" }
            ]
        },
        {
            category: "Expression Controls",
            effects: [
                { id: "exp.angle",    name: "Angle Control" },
                { id: "exp.checkbox", name: "Checkbox Control" },
                { id: "exp.color",    name: "Color Control" },
                { id: "exp.layer",    name: "Layer Control" },
                { id: "exp.point",    name: "Point Control" },
                { id: "exp.slider",   name: "Slider Control" }
            ]
        },
        {
            category: "Generate",
            effects: [
                { id: "gen.4color",    name: "4-Color Gradient" },
                { id: "gen.advlight",  name: "Advanced Lightning" },
                { id: "gen.audiospect",name: "Audio Spectrum" },
                { id: "gen.audiowav",  name: "Audio Waveform" },
                { id: "gen.beam",      name: "Beam" },
                { id: "gen.ccglue",    name: "CC Glue Gun" },
                { id: "gen.cclightb",  name: "CC Light Burst 2.5" },
                { id: "gen.cclightr",  name: "CC Light Rays" },
                { id: "gen.cclights",  name: "CC Light Sweep" },
                { id: "gen.cell",      name: "Cell Pattern" },
                { id: "gen.checker",   name: "Checkerboard" },
                { id: "gen.circle",    name: "Circle" },
                { id: "gen.ellipse",   name: "Ellipse" },
                { id: "gen.eyedrop",   name: "Eyedropper Fill" },
                { id: "gen.fill",      name: "Fill" },
                { id: "gen.fractal",   name: "Fractal" },
                { id: "gen.gradramp",  name: "Gradient Ramp" },
                { id: "gen.grid",      name: "Grid" },
                { id: "gen.lensflare", name: "Lens Flare" },
                { id: "gen.paintbkt",  name: "Paint Bucket" },
                { id: "gen.radiowav",  name: "Radio Waves" },
                { id: "gen.scribble",  name: "Scribble" },
                { id: "gen.stroke",    name: "Stroke" },
                { id: "gen.vegas",     name: "Vegas" },
                { id: "gen.writeon",   name: "Write-on" }
            ]
        },
        {
            category: "Immersive Video",
            effects: [
                { id: "imv.vrblur",    name: "VR Blur" },
                { id: "imv.vrchroma",  name: "VR Chromatic Aberrations" },
                { id: "imv.vrcolor",   name: "VR Color Gradients" },
                { id: "imv.vrdnoise",  name: "VR De-Noise" },
                { id: "imv.vrglitch",  name: "VR Digital Glitch" },
                { id: "imv.vrfractal", name: "VR Fractal Noise" },
                { id: "imv.vrglow",    name: "VR Glow" },
                { id: "imv.vrplane",   name: "VR Plane to Sphere" },
                { id: "imv.vrrotate",  name: "VR Rotate Sphere" },
                { id: "imv.vrsharpen", name: "VR Sharpen" }
            ]
        },
        {
            category: "Keying",
            effects: [
                { id: "key.ccwire",    name: "CC Simple Wire Removal" },
                { id: "key.coldiff",   name: "Color Difference Key" },
                { id: "key.colorkey",  name: "Color Key" },
                { id: "key.colorange", name: "Color Range" },
                { id: "key.diffmatte", name: "Difference Matte" },
                { id: "key.extract",   name: "Extract" },
                { id: "key.innerouter",name: "Inner/Outer Key" },
                { id: "key.cleaner",   name: "Key Cleaner" },
                { id: "key.keylight",  name: "Keylight 1.2" },
                { id: "key.linear",    name: "Linear Color Key" },
                { id: "key.lumainv",   name: "Luma Inverted Matte" },
                { id: "key.luma",      name: "Luma Matte" },
                { id: "key.spill",     name: "Spill Suppressor" },
                { id: "key.ultra",     name: "Ultra Key" }
            ]
        },
        {
            category: "Matte",
            effects: [
                { id: "mat.choker",   name: "Matte Choker" },
                { id: "mat.mocha",    name: "Mocha AE" },
                { id: "mat.refhard",  name: "Refine Hard Matte" },
                { id: "mat.refine",   name: "Refine Matte" },
                { id: "mat.simple",   name: "Simple Choker" },
                { id: "mat.track",    name: "Track Matte Key" }
            ]
        },
        {
            category: "Noise & Grain",
            effects: [
                { id: "noi.addgrain",  name: "Add Grain" },
                { id: "noi.cellnoise", name: "Cell Noise" },
                { id: "noi.dust",      name: "Dust & Scratches" },
                { id: "noi.fractal",   name: "Fractal Noise" },
                { id: "noi.match",     name: "Match Grain" },
                { id: "noi.median",    name: "Median" },
                { id: "noi.noise",     name: "Noise" },
                { id: "noi.alpha",     name: "Noise Alpha" },
                { id: "noi.hls",       name: "Noise HLS" },
                { id: "noi.hlsauto",   name: "Noise HLS Auto" },
                { id: "noi.remove",    name: "Remove Grain" },
                { id: "noi.turbulent", name: "Turbulent Noise" }
            ]
        },
        {
            category: "Perspective",
            effects: [
                { id: "per.3dcam",    name: "3D Camera Tracker" },
                { id: "per.bevelalp", name: "Bevel Alpha" },
                { id: "per.beveled",  name: "Bevel Edges" },
                { id: "per.cccyl",    name: "CC Cylinder" },
                { id: "per.ccenv",    name: "CC Environment" },
                { id: "per.ccsphere", name: "CC Sphere" },
                { id: "per.ccspot",   name: "CC Spotlight" },
                { id: "per.dropshadow",name: "Drop Shadow" }
            ]
        },
        {
            category: "Simulation",
            effects: [
                { id: "sim.carddance",  name: "Card Dance" },
                { id: "sim.caustics",   name: "Caustics" },
                { id: "sim.ccball",     name: "CC Ball Action" },
                { id: "sim.ccbubbles",  name: "CC Bubbles" },
                { id: "sim.ccdrizzle",  name: "CC Drizzle" },
                { id: "sim.cchair",     name: "CC Hair" },
                { id: "sim.ccmercury",  name: "CC Mr. Mercury" },
                { id: "sim.ccparticle2",name: "CC Particle Systems II" },
                { id: "sim.ccpworld",   name: "CC Particle World" },
                { id: "sim.ccpixpoly",  name: "CC Pixel Polly" },
                { id: "sim.ccrain",     name: "CC Rainfall" },
                { id: "sim.ccscatter",  name: "CC Scatterize" },
                { id: "sim.ccsnow",     name: "CC Snowfall" },
                { id: "sim.ccstarburst",name: "CC Star Burst" },
                { id: "sim.foam",       name: "Foam" },
                { id: "sim.particles",  name: "Particle Playground" },
                { id: "sim.shatter",    name: "Shatter" },
                { id: "sim.waveworld",  name: "Wave World" },
                { id: "sim.fire",       name: "Fire Simulation" },
                { id: "sim.smoke",      name: "Smoke Simulation" }
            ]
        },
        {
            category: "Stylize",
            effects: [
                { id: "sty.brush",     name: "Brush Strokes" },
                { id: "sty.cartoon",   name: "Cartoon" },
                { id: "sty.ccblock",   name: "CC Block Load" },
                { id: "sty.ccburn",    name: "CC Burn Film" },
                { id: "sty.ccglass",   name: "CC Glass" },
                { id: "sty.cchex",     name: "CC HexTile" },
                { id: "sty.cckaleida", name: "CC Kaleida" },
                { id: "sty.ccplastic", name: "CC Plastic" },
                { id: "sty.ccrep",     name: "CC RepeTile" },
                { id: "sty.ccthresh",  name: "CC Threshold RGB" },
                { id: "sty.embosscol", name: "Color Emboss" },
                { id: "sty.emboss",    name: "Emboss" },
                { id: "sty.findedges", name: "Find Edges" },
                { id: "sty.glow",      name: "Glow" },
                { id: "sty.mosaic",    name: "Mosaic" },
                { id: "sty.motiontile",name: "Motion Tile" },
                { id: "sty.posterize", name: "Posterize" },
                { id: "sty.roughen",   name: "Roughen Edges" },
                { id: "sty.strobe",    name: "Strobe Light" },
                { id: "sty.texturize", name: "Texturize" }
            ]
        },
        {
            category: "Text",
            effects: [
                { id: "txt.basic",    name: "Basic Text" },
                { id: "txt.numbers",  name: "Numbers" },
                { id: "txt.path",     name: "Path Text" },
                { id: "txt.animator", name: "Text Animator" },
                { id: "txt.timecode", name: "Timecode" },
                { id: "txt.source",   name: "Source Text" }
            ]
        },
        {
            category: "Time",
            effects: [
                { id: "tim.ccforce",  name: "CC Force Motion Blur" },
                { id: "tim.ccwide",   name: "CC Wide Time" },
                { id: "tim.echo",     name: "Echo" },
                { id: "tim.pixmot",   name: "Pixel Motion Blur" },
                { id: "tim.posterize",name: "Posterize Time" },
                { id: "tim.blend",    name: "Time Blend" },
                { id: "tim.diff",     name: "Time Difference" },
                { id: "tim.displace", name: "Time Displacement" }
            ]
        },
        {
            category: "Transition",
            effects: [
                { id: "trn.block",    name: "Block Dissolve" },
                { id: "trn.card",     name: "Card Wipe" },
                { id: "trn.ccglass",  name: "CC Glass Wipe" },
                { id: "trn.ccgrid",   name: "CC Grid Wipe" },
                { id: "trn.ccimage",  name: "CC Image Wipe" },
                { id: "trn.ccjaws",   name: "CC Jaws" },
                { id: "trn.cclight",  name: "CC Light Wipe" },
                { id: "trn.ccline",   name: "CC Line Sweep" },
                { id: "trn.ccradscale",name: "CC Radial ScaleWipe" },
                { id: "trn.ccscale",  name: "CC Scale Wipe" },
                { id: "trn.cctwist",  name: "CC Twister" },
                { id: "trn.ccwarp",   name: "CC WarpoMatic" },
                { id: "trn.gradient", name: "Gradient Wipe" },
                { id: "trn.iris",     name: "Iris Wipe" },
                { id: "trn.linear",   name: "Linear Wipe" },
                { id: "trn.radial",   name: "Radial Wipe" },
                { id: "trn.venetian", name: "Venetian Blinds" },
                { id: "trn.cross",    name: "Cross Dissolve" }
            ]
        },
        {
            category: "Utility",
            effects: [
                { id: "utl.applylut",  name: "Apply Color LUT" },
                { id: "utl.cineon",    name: "Cineon Converter" },
                { id: "utl.profile",   name: "Color Profile Converter" },
                { id: "utl.grow",      name: "Grow Bounds" },
                { id: "utl.hdrcomp",   name: "HDR Compander" },
                { id: "utl.hdrhigh",   name: "HDR Highlight Compression" },
                { id: "utl.proxy",     name: "Proxy" },
                { id: "utl.rmunused",  name: "Remove Unused" }
            ]
        },
        {
            category: "AI Effects",
            effects: [
                { id: "ai.autocolor",  name: "AI Auto-Color" },
                { id: "ai.reframe",    name: "AI Auto-Reframe" },
                { id: "ai.bgremove",   name: "AI Background Remove" },
                { id: "ai.colormatch", name: "AI Color Match" },
                { id: "ai.denoise",    name: "AI De-Noise" },
                { id: "ai.face",       name: "AI Face Enhance" },
                { id: "ai.interp",     name: "AI Frame Interpolation" },
                { id: "ai.objseg",     name: "AI Object Segmentation" },
                { id: "ai.scenecut",   name: "AI Scene Cut Detect" },
                { id: "ai.skyreplace", name: "AI Sky Replace" },
                { id: "ai.speech",     name: "AI Speech-to-Text" },
                { id: "ai.style",      name: "AI Style Transfer" },
                { id: "ai.superres",   name: "AI Super Resolution" },
                { id: "ai.subtitle",   name: "AI Auto-Subtitle" }
            ]
        },
        {
            category: "3D & VFX",
            effects: [
                { id: "vfx.camera",    name: "3D Camera" },
                { id: "vfx.dof",       name: "3D Depth of Field" },
                { id: "vfx.layerctl",  name: "3D Layer Controls" },
                { id: "vfx.lights",    name: "3D Lights" },
                { id: "vfx.motblur",   name: "3D Motion Blur" },
                { id: "vfx.orbitpart", name: "3D Orbit Particles" },
                { id: "vfx.particles", name: "3D Particle System" },
                { id: "vfx.raycast",   name: "3D Ray Cast" },
                { id: "vfx.reflect",   name: "3D Reflections" },
                { id: "vfx.shadows",   name: "3D Shadows" }
            ]
        },
        {
            category: "Color Grading",
            effects: [
                { id: "cgr.ascdcl",    name: "ASC CDL" },
                { id: "cgr.lookup",    name: "Color Lookup" },
                { id: "cgr.vibrance",  name: "Color Vibrance" },
                { id: "cgr.creative",  name: "Creative Looks" },
                { id: "cgr.filmlut",   name: "Film Emulation LUT" },
                { id: "cgr.grade",     name: "Grade Panel" },
                { id: "cgr.hdrsdr",    name: "HDR to SDR" },
                { id: "cgr.lutbrows",  name: "LUT Browser" },
                { id: "cgr.skin",      name: "Skin Tones Protect" },
                { id: "cgr.split",     name: "Split Tone" },
                { id: "cgr.tonecurve", name: "Tone Curve" },
                { id: "cgr.scopes",    name: "Video Scopes Overlay" },
                { id: "cgr.vector",    name: "Vectorscope Overlay" },
                { id: "cgr.waveform",  name: "Waveform Monitor" }
            ]
        }
    ]

    // -------------------------------------------------------------------------
    // Category filter tabs
    // -------------------------------------------------------------------------

    readonly property var categoryFilterTabs: [
        "All", "Blur", "Color", "Distort", "Generate",
        "Keying", "Simulation", "Stylize", "3D", "AI"
    ]

    // -------------------------------------------------------------------------
    // State
    // -------------------------------------------------------------------------

    property string searchText: ""
    property string activeCategoryFilter: "All"
    property bool showFavoritesOnly: false
    property var categoryExpanded: ({})
    property int totalVisible: 0

    // -------------------------------------------------------------------------
    // Flat list model rebuilt on state changes
    // -------------------------------------------------------------------------

    ListModel {
        id: flatModel
    }

    function rebuildModel() {
        flatModel.clear()
        let count = 0
        const q = searchText.toLowerCase().trim()
        const filter = activeCategoryFilter

        if (q.length > 0) {
            // Flat filtered list — no category headers
            for (let ci = 0; ci < effectsDb.length; ++ci) {
                const cat = effectsDb[ci]
                const catMatch = filter === "All" || cat.category.toLowerCase().indexOf(filter.toLowerCase()) >= 0
                if (!catMatch) continue
                for (let ei = 0; ei < cat.effects.length; ++ei) {
                    const fx = cat.effects[ei]
                    const nameMatch = fx.name.toLowerCase().indexOf(q) >= 0
                    const idMatch = fx.id.toLowerCase().indexOf(q) >= 0
                    const catNameMatch = cat.category.toLowerCase().indexOf(q) >= 0
                    if (nameMatch || idMatch || catNameMatch) {
                        const isFav = mainWindow && mainWindow.favoriteEffectIds
                            ? mainWindow.favoriteEffectIds.indexOf(fx.id) >= 0 : false
                        if (showFavoritesOnly && !isFav) continue
                        flatModel.append({
                            itemType: "effect",
                            itemCategory: cat.category,
                            itemName: fx.name,
                            itemId: fx.id,
                            itemExpanded: false
                        })
                        count++
                    }
                }
            }
        } else {
            // Tree view with optional category filter
            for (let ci = 0; ci < effectsDb.length; ++ci) {
                const cat = effectsDb[ci]
                const catMatch = filter === "All" || cat.category.toLowerCase().indexOf(filter.toLowerCase()) >= 0
                if (!catMatch) continue

                // Count favorites-eligible children
                let childCount = 0
                for (let ei = 0; ei < cat.effects.length; ++ei) {
                    const fx = cat.effects[ei]
                    const isFav = mainWindow && mainWindow.favoriteEffectIds
                        ? mainWindow.favoriteEffectIds.indexOf(fx.id) >= 0 : false
                    if (!showFavoritesOnly || isFav) childCount++
                }
                if (showFavoritesOnly && childCount === 0) continue

                const isExpanded = categoryExpanded.hasOwnProperty(cat.category)
                    ? categoryExpanded[cat.category] : true

                flatModel.append({
                    itemType: "category",
                    itemCategory: cat.category,
                    itemName: cat.category,
                    itemId: "",
                    itemExpanded: isExpanded,
                    itemCount: childCount
                })

                if (isExpanded) {
                    for (let ei = 0; ei < cat.effects.length; ++ei) {
                        const fx = cat.effects[ei]
                        const isFav = mainWindow && mainWindow.favoriteEffectIds
                            ? mainWindow.favoriteEffectIds.indexOf(fx.id) >= 0 : false
                        if (showFavoritesOnly && !isFav) continue
                        flatModel.append({
                            itemType: "effect",
                            itemCategory: cat.category,
                            itemName: fx.name,
                            itemId: fx.id,
                            itemExpanded: false
                        })
                        count++
                    }
                } else {
                    count += childCount
                }
            }
        }

        totalVisible = count
    }

    Component.onCompleted: rebuildModel()

    onSearchTextChanged:          rebuildModel()
    onActiveCategoryFilterChanged: rebuildModel()
    onShowFavoritesOnlyChanged:   rebuildModel()

    // -------------------------------------------------------------------------
    // Toast notification
    // -------------------------------------------------------------------------

    property string toastMessage: ""

    Rectangle {
        id: toastRect
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 16
        z: 100
        width: toastLabel.implicitWidth + 24
        height: 30
        radius: 6
        color: Qt.rgba(0.12, 0.12, 0.14, 0.96)
        border.color: theme.colors.borderSubtle
        border.width: 1
        opacity: 0
        visible: opacity > 0

        Label {
            id: toastLabel
            anchors.centerIn: parent
            text: root.toastMessage
            color: theme.colors.textPrimary
            font.pixelSize: 11
        }

        SequentialAnimation {
            id: toastAnim
            NumberAnimation { target: toastRect; property: "opacity"; to: 1; duration: 160; easing.type: Easing.OutQuad }
            PauseAnimation { duration: 1800 }
            NumberAnimation { target: toastRect; property: "opacity"; to: 0; duration: 300; easing.type: Easing.InQuad }
        }
    }

    function showToast(msg) {
        toastMessage = msg
        toastAnim.restart()
    }

    // -------------------------------------------------------------------------
    // Context menu
    // -------------------------------------------------------------------------

    property string contextEffectId: ""
    property string contextEffectName: ""
    property string contextEffectCategory: ""

    Menu {
        id: contextMenu
        background: Rectangle {
            implicitWidth: 180
            color: theme.colors.menuBarBackground
            border.color: theme.colors.borderColor
            border.width: 1
            radius: 6
        }

        MenuItem {
            text: "Apply"
            onTriggered: {
                if (mainWindow)
                    mainWindow.applyEffect(root.contextEffectId)
                root.showToast("Applied: " + root.contextEffectName)
            }
            contentItem: Text {
                text: parent.text
                color: theme.colors.textPrimary
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
            background: Rectangle {
                color: parent.hovered ? theme.colors.surfaceHigh : "transparent"
                radius: 4
            }
        }

        MenuItem {
            text: "Add to Favorites"
            onTriggered: {
                if (mainWindow)
                    mainWindow.toggleFavoriteEffect(root.contextEffectId)
                root.showToast("Favorited: " + root.contextEffectName)
            }
            contentItem: Text {
                text: parent.text
                color: theme.colors.textPrimary
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
            background: Rectangle {
                color: parent.hovered ? theme.colors.surfaceHigh : "transparent"
                radius: 4
            }
        }

        MenuItem {
            text: "Find in Timeline"
            onTriggered: {
                if (mainWindow)
                    mainWindow.findEffectInTimeline(root.contextEffectId)
                root.showToast("Searching timeline for " + root.contextEffectName)
            }
            contentItem: Text {
                text: parent.text
                color: theme.colors.textPrimary
                font.pixelSize: 12
                verticalAlignment: Text.AlignVCenter
                leftPadding: 10
            }
            background: Rectangle {
                color: parent.hovered ? theme.colors.surfaceHigh : "transparent"
                radius: 4
            }
        }
    }

    // -------------------------------------------------------------------------
    // Layout
    // -------------------------------------------------------------------------

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // -- Header bar -------------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: theme.colors.menuBarBackground

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 8
                spacing: 8

                Label {
                    text: qsTr("Effects & Presets")
                    color: theme.colors.textPrimary
                    font.pixelSize: theme.typography.heading
                    font.weight: Font.Bold
                }

                Label {
                    text: root.totalVisible + " effects"
                    color: theme.colors.textSecondary
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                // All toggle
                ToolButton {
                    id: btnAll
                    text: qsTr("All")
                    checkable: true
                    checked: !root.showFavoritesOnly
                    implicitHeight: 26
                    font.pixelSize: 11
                    ToolTip.text: qsTr("Show every registered effect")
                    ToolTip.visible: hovered
                    ToolTip.delay: 400
                    onClicked: root.showFavoritesOnly = false
                    background: Rectangle {
                        radius: 4
                        color: parent.checked ? Qt.alpha(theme.colors.accent, 0.22)
                                              : parent.hovered ? theme.colors.elevated : "transparent"
                        border.color: parent.checked ? theme.colors.edgeHighlight : theme.colors.borderSubtle
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.checked ? theme.colors.textPrimary : theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                // Favorites toggle
                ToolButton {
                    text: qsTr("Favorites")
                    checkable: true
                    checked: root.showFavoritesOnly
                    implicitHeight: 26
                    font.pixelSize: 11
                    ToolTip.text: qsTr("Effects you starred (saved in settings)")
                    ToolTip.visible: hovered
                    ToolTip.delay: 400
                    onClicked: root.showFavoritesOnly = true
                    background: Rectangle {
                        radius: 4
                        color: parent.checked ? Qt.alpha(theme.colors.accent, 0.22)
                                              : parent.hovered ? theme.colors.elevated : "transparent"
                        border.color: parent.checked ? theme.colors.edgeHighlight : theme.colors.borderSubtle
                        border.width: 1
                    }
                    contentItem: Text {
                        text: parent.text
                        font: parent.font
                        color: parent.checked ? theme.colors.textPrimary : theme.colors.textSecondary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderColor
            }
        }

        // -- Search field -----------------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: theme.colors.panelBackground

            TextField {
                id: searchField
                anchors.fill: parent
                anchors.margins: 6
                anchors.topMargin: 5
                anchors.bottomMargin: 5
                placeholderText: qsTr("Search effects, presets, transitions\u2026")
                color: theme.colors.textPrimary
                placeholderTextColor: theme.colors.textSecondary
                font.pixelSize: theme.typography.body
                onTextChanged: root.searchText = text
                background: Rectangle {
                    implicitHeight: 28
                    color: theme.colors.secondaryPanel
                    border.color: searchField.activeFocus ? theme.colors.edgeHighlight : theme.colors.borderColor
                    border.width: 1
                    radius: 5
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderSubtle
            }
        }

        // -- Category filter row ----------------------------------------------
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: theme.colors.panelBackground

            ScrollView {
                anchors.fill: parent
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                clip: true

                Row {
                    spacing: 4
                    height: 32
                    topPadding: 4
                    bottomPadding: 4

                    Repeater {
                        model: root.categoryFilterTabs

                        delegate: Rectangle {
                            required property string modelData
                            width: tabLabel.implicitWidth + 16
                            height: 24
                            radius: 4
                            color: root.activeCategoryFilter === modelData
                                   ? Qt.alpha(theme.colors.accent, 0.22)
                                   : tabMa.containsMouse ? theme.colors.elevated : "transparent"
                            border.color: root.activeCategoryFilter === modelData
                                          ? theme.colors.edgeHighlight : theme.colors.borderSubtle
                            border.width: 1

                            Label {
                                id: tabLabel
                                anchors.centerIn: parent
                                text: parent.modelData
                                font.pixelSize: 11
                                color: root.activeCategoryFilter === parent.modelData
                                       ? theme.colors.textPrimary : theme.colors.textSecondary
                            }

                            MouseArea {
                                id: tabMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.activeCategoryFilter = parent.modelData
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: theme.colors.borderSubtle
            }
        }

        // -- Main tree ListView -----------------------------------------------
        ListView {
            id: treeView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: flatModel
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            spacing: 0

            delegate: Loader {
                width: treeView.width
                required property string itemType
                required property string itemCategory
                required property string itemName
                required property string itemId
                required property bool   itemExpanded
                property int itemCount: model.itemCount !== undefined ? model.itemCount : 0
                property int modelIndex: index

                height: itemType === "category" ? 28 : 26

                sourceComponent: itemType === "category" ? categoryRowComp : effectRowComp

                property string delegateCategory: itemCategory
                property string delegateName:     itemName
                property string delegateId:       itemId
                property bool   delegateExpanded: itemExpanded
                property int    delegateCount:    itemCount
                property int    delegateIndex:    modelIndex
            }

            // Empty state
            Label {
                anchors.centerIn: parent
                visible: flatModel.count === 0
                text: root.showFavoritesOnly
                      ? "No favorites yet.\nStar an effect to save it here."
                      : "No effects match your search."
                horizontalAlignment: Text.AlignHCenter
                color: theme.colors.textDisabled
                font.pixelSize: theme.typography.caption
                wrapMode: Text.WordWrap
                width: parent.width - 40
            }
        }
    }

    // -------------------------------------------------------------------------
    // Category row component
    // -------------------------------------------------------------------------

    Component {
        id: categoryRowComp

        Rectangle {
            width: parent ? parent.width : 0
            height: 28
            color: catHover.containsMouse ? theme.colors.surfaceRaised : "transparent"

            readonly property color accent: root.categoryAccent(parent ? parent.delegateCategory : "")

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 5

                // Expand/collapse triangle
                Text {
                    text: (parent && parent.parent && parent.parent.delegateExpanded) ? "\u25BE" : "\u25B8"
                    color: theme.colors.textSecondary
                    font.pixelSize: 10
                    verticalAlignment: Text.AlignVCenter
                }

                // Category name
                Label {
                    text: parent && parent.parent ? parent.parent.delegateName.toUpperCase() : ""
                    color: theme.colors.textSecondary
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                    verticalAlignment: Text.AlignVCenter
                    Layout.fillWidth: true
                }

                // Count badge
                Rectangle {
                    width: countBadge.implicitWidth + 10
                    height: 16
                    radius: 8
                    color: Qt.alpha(accent, 0.30)

                    Label {
                        id: countBadge
                        anchors.centerIn: parent
                        text: parent && parent.parent && parent.parent.parent ? parent.parent.parent.delegateCount : ""
                        color: theme.colors.textPrimary
                        font.pixelSize: 9
                        font.weight: Font.Medium
                    }
                }
            }

            MouseArea {
                id: catHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (!parent || !parent.parent) return
                    const cat = parent.parent.delegateCategory
                    const wasExpanded = parent.parent.delegateExpanded
                    const expanded = root.categoryExpanded
                    expanded[cat] = !wasExpanded
                    root.categoryExpanded = expanded
                    root.rebuildModel()
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Effect row component
    // -------------------------------------------------------------------------

    Component {
        id: effectRowComp

        Rectangle {
            id: effectRow
            width: parent ? parent.width : 0
            height: 26
            color: fxHover.containsMouse ? theme.colors.surfaceHigh : "transparent"

            readonly property string fxCategory: parent ? parent.delegateCategory : ""
            readonly property string fxName:     parent ? parent.delegateName     : ""
            readonly property string fxId:       parent ? parent.delegateId       : ""
            readonly property color  accent:     root.categoryAccent(fxCategory)
            readonly property bool   isFav: mainWindow && mainWindow.favoriteEffectIds
                                            ? mainWindow.favoriteEffectIds.indexOf(fxId) >= 0 : false

            // Left accent strip
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 3
                color: Qt.alpha(accent, 0.70)
            }

            // Effect name label
            Label {
                anchors.left: parent.left
                anchors.right: starButton.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 24
                anchors.rightMargin: 4
                text: fxName
                color: theme.colors.textPrimary
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            // Favorite star
            Text {
                id: starButton
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: isFav ? "\u2605" : "\u2606"
                color: isFav ? theme.colors.accent : theme.colors.textDisabled
                font.pixelSize: 11
                visible: fxHover.containsMouse || isFav

                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -4
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (mainWindow)
                            mainWindow.toggleFavoriteEffect(fxId)
                        root.rebuildModel()
                    }
                }
            }

            MouseArea {
                id: fxHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onDoubleClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        if (mainWindow)
                            mainWindow.applyEffect(fxId)
                        root.showToast("Applied: " + fxName)
                    }
                }

                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton) {
                        root.contextEffectId       = fxId
                        root.contextEffectName     = fxName
                        root.contextEffectCategory = fxCategory
                        contextMenu.popup()
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Right edge border
    // -------------------------------------------------------------------------

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: theme.colors.borderColor
    }
}
