shader_type canvas_item;

void fragment() {
    vec2 uv = UV;

    vec3 bg = vec3(0.2, 0.6, 1.0);
    float border = 0.01;

    // вертикальні лінії (3 слоти)
    float lines = step(0.333, uv.x) - step(0.666, uv.x);

    bool is_border =
        uv.x < border || uv.x > 1.0 - border ||
        uv.y < border || uv.y > 1.0 - border;

    if (is_border) {
        COLOR = vec4(1.0, 0.2, 0.2, 0.9);
    } else if (abs(uv.x - 0.333) < 0.005 || abs(uv.x - 0.666) < 0.005) {
        COLOR = vec4(1.0, 1.0, 0.0, 0.8); // жовті роздільники
    } else {
        COLOR = vec4(bg, 0.12);
    }
	}