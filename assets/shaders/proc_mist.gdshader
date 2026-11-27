shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Tấm sương mây trôi: alpha theo nhiễu, mờ dần ở mép tấm, trôi chậm theo thời gian.
uniform vec4 base_color : source_color = vec4(0.93, 0.97, 0.98, 1.0);
uniform vec4 dark_color : source_color = vec4(0.8, 0.9, 0.93, 1.0);
uniform float density = 0.55;
uniform float drift = 0.05;

varying vec3 v_wp;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_wp.xz * 0.09 + vec2(TIME * drift, TIME * drift * 0.4);
	float n = fbm2(p) * 0.65 + fbm2(p * 2.7 + 3.1) * 0.35;
	vec2 c = UV * 2.0 - 1.0;
	float edge = 1.0 - smoothstep(0.55, 1.0, length(c));
	ALBEDO = mix(dark_color.rgb, base_color.rgb, n);
	ALPHA = clamp((n - 0.25) * 1.8, 0.0, 1.0) * edge * density;
}
