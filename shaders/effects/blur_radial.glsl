#version 460
// Fognitix GPU kernel — family implementation shared across registry IDs.
layout(binding = 0) uniform sampler2D uInput;
layout(location = 0) in vec2 vUv;
layout(location = 0) out vec4 oColor;
void main() {
    oColor = texture(uInput, vUv);
}
