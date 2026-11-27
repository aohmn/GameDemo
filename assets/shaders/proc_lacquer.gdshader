shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Sơn son bóng (cột, xà, cổng): đỏ đậm, vệt sáng dọc, vân gỗ mờ dưới lớp sơn, hơi bóng.
uniform vec4 base_color : source_color = vec4(0.62, 0.14, 0.10, 1.0);
uniform vec4 dark_color : source_color = vec4(0.32, 0.06, 0.05, 1.0);

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	float across = v_wp.x + v_wp.z;
	float grain = fbm2(vec2(across * 18.0, v_wp.y * 0.9));
	vec3 col = mix(dark_color.rgb, base_color.rgb, 0.6 + grain * 0.4);
	float wear = fbm2(vec2(across * 3.0, v_wp.y * 2.2)) ;
	col *= 0.93 + wear * 0.12;
	ALBEDO = col;
	ROUGHNESS = 0.32;
	SPECULAR = 0.65;
}
