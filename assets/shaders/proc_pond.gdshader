shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Mặt ao: xanh ngọc, gợn sóng nhỏ trôi, lấp lánh nhẹ.
uniform vec4 base_color : source_color = vec4(0.2, 0.64, 0.62, 1.0);
uniform vec4 dark_color : source_color = vec4(0.1, 0.4, 0.42, 1.0);

varying vec3 v_wp;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec2 p = v_wp.xz;
	float r1 = fbm2(p * 2.2 + vec2(TIME * 0.2, TIME * 0.12));
	float r2 = fbm2(p * 4.5 - vec2(TIME * 0.15, TIME * 0.1));
	vec3 col = mix(dark_color.rgb, base_color.rgb, 0.4 + r1 * 0.6);
	col += vec3(0.6, 0.85, 0.85) * smoothstep(0.8, 0.95, r2) * 0.25;
	ALBEDO = col;
	ROUGHNESS = 0.3;
	SPECULAR = 0.25;
}
