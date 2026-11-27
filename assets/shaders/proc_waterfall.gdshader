shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Thác nước: dải bọt chảy xuống, mép mờ, đục dần ở chân thác.
uniform vec4 base_color : source_color = vec4(0.88, 0.97, 1.0, 1.0);
uniform vec4 dark_color : source_color = vec4(0.5, 0.78, 0.9, 1.0);
uniform float speed = 1.4;

varying vec3 v_local;

void vertex() {
	v_local = VERTEX;
}

void fragment() {
	float x = UV.x;
	float flow = fbm2(vec2(x * 9.0, v_local.y * 0.6 + TIME * speed));
	float streak = vnoise(vec2(x * 26.0, v_local.y * 0.25 + TIME * speed * 1.7));
	float edge = smoothstep(0.0, 0.22, x) * smoothstep(0.0, 0.22, 1.0 - x);
	float a = clamp((0.45 + flow * 0.6) * edge, 0.0, 1.0);
	ALBEDO = mix(dark_color.rgb, base_color.rgb, 0.35 + streak * 0.65);
	ALPHA = a * 0.85;
}
