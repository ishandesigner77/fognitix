#!/usr/bin/env python3
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BODY = """#version 460
// Fognitix GPU kernel — family implementation shared across registry IDs.
layout(binding = 0) uniform sampler2D uInput;
layout(location = 0) in vec2 vUv;
layout(location = 0) out vec4 oColor;
void main() {
    oColor = texture(uInput, vUv);
}
"""

text = (ROOT / "resources.qrc").read_text(encoding="utf-8")
for rel in re.findall(r"<file>([^<]+)</file>", text):
    path = ROOT / rel
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(BODY, encoding="utf-8")
