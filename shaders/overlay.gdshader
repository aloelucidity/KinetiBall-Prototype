shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

vec3 overlay(vec3 base, vec3 blend){
	vec3 limit = step(0.5, base);
	return mix(2.0 * base * blend, 1.0 - 2.0 * (1.0 - base) * (1.0 - blend), limit);
}

void fragment(){
	vec4 base = texture(screen_texture, SCREEN_UV);
	vec4 input = texture(TEXTURE, UV);
	COLOR.rgb = overlay(input.rgb, base.rgb);
	COLOR *= modulate;
}
