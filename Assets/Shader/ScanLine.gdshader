shader_type canvas_item;

// 扫描线颜色（默认白色）
uniform vec4 scanline_color: source_color = vec4(1.0, 1.0, 1.0, 0.5);
// 扫描线间隔（单位：像素）
uniform float scanline_spacing: hint_range(2.0, 20.0) = 4.0;
// 扫描线宽度（0.0-1.0的比例）
uniform float scanline_width: hint_range(0.1, 1.0) = 0.5;
// 边缘柔化程度
uniform float edge_softness: hint_range(0.0, 1.0) = 0.25;

void fragment() {
    // 获取屏幕UV坐标
    vec2 uv = FRAGCOORD.xy;

    // 创建扫描线模式
    float line_pos = fract(uv.y / scanline_spacing);
    float scanline = smoothstep(
        scanline_width + edge_softness,
        scanline_width - edge_softness,
        abs(line_pos - 0.5) * 2.0
    );

    // 混合颜色（保持背景透明）
    COLOR = vec4(scanline_color.rgb, scanline * scanline_color.a);
}