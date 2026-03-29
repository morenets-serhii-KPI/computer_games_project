shader_type canvas_item;

uniform float hover = 0.0;
uniform float pressed = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);

	// затемнення
	float darken = hover * 0.2 + pressed * 0.35;

	color.rgb *= (1.0 - darken);

	COLOR = color;
}