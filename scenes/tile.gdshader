shader_type canvas_item;

uniform float corner_radius : hint_range(0.0, 1.0) = 0.1;

void fragment() {
    vec2 size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 pos = UV;
    
    // Центрирование координат
    vec2 rect_pos = abs(pos - 0.5) * 2.0;
    
    // Создание скругления
    vec2 corner = max(rect_pos - (1.0 - corner_radius), 0.0);
    float dist = length(corner);
    
    // Обрезка (discard)
    if (dist > corner_radius) {
        discard;
    }
}
