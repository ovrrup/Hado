#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uIntensity;
uniform vec3 uColorA;
uniform vec3 uColorB;
uniform vec3 uColorC;

out vec4 fragColor;

float hash(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uResolution.xy;

    // Dynamic gradient mesh base
    float dist = distance(uv, vec2(0.5, 0.3));
    float blend1 = smoothstep(0.0, 0.85, uv.y + sin(uTime * 0.4) * 0.08);
    float blend2 = smoothstep(0.0, 1.0, dist);

    vec3 baseGradient = mix(uColorA, uColorB, blend1);
    baseGradient = mix(baseGradient, uColorC, blend2 * 0.55);

    // High frequency granular particles
    vec2 grainCoord = FlutterFragCoord().xy + vec2(sin(uTime * 8.0) * 70.0, cos(uTime * 8.0) * 70.0);
    float grain = (hash(grainCoord) - 0.5) * uIntensity;

    vec3 finalColor = clamp(baseGradient + vec3(grain), 0.0, 1.0);

    fragColor = vec4(finalColor, 1.0);
}
