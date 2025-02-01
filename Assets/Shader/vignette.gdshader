shader_type canvas_item;

uniform float inner_radius = 0.1;
uniform float outer_radius = 1.0;
uniform float vignette_strength = 1.0;
uniform float dither_strength = 0.03;
uniform float opacity = 1.0; // New parameter for opacity
uniform vec4 vignette_color : source_color;

void fragment() {
    float dist = distance(UV, vec2(0.5));

    float vignette = smoothstep(inner_radius, outer_radius, dist) * vignette_strength;
    float dither = fract(sin(dot(UV, vec2(12.9898, 78.233))) * 43758.5453123) * dither_strength;

    // Combine vignette and dither with opacity control
    float alpha = clamp(vignette + dither, 0.0, 1.0) * opacity;

    COLOR = vec4(vignette_color.rgb, alpha);
}
