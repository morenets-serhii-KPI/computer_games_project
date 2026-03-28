shader_type canvas_item;

uniform vec4 color_top : source_color = vec4(0.90, 0.78, 0.55, 1.0);
uniform vec4 color_bottom : source_color = vec4(0.95, 0.55, 0.22, 1.0);

void fragment() {
    COLOR = mix(color_top, color_bottom, UV.y);
}