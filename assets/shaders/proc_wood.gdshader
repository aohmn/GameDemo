shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Gỗ có vân dọc (thân cây, cột, thùng, tường gỗ).
uniform vec4 base_color : source_color = vec4(0.55, 0.38, 0.24, 1.0);
uniform vec4 dark_color : source_color = vec4(0.40, 0.26, 0.16, 1.0);

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(v_wn);
	vec2 uv = face_uv(v_wp, n);
	float across = abs(n.y) > 0.7 ? uv.x + uv.y : uv.x * 1.0 + uv.y * 0.0 + v_wp.z * 0.7;
	float rings = fbm2(vec2(across * 9.0, v_wp.y * 0.8));
	float streak = vnoise(vec2(across * 26.0, v_wp.y * 1.5));
	vec3 col = mix(dark_color.rgb, base_color.rgb, 0.35 + rings * 0.65);
	col *= 0.9 + streak * 0.2;
	float board = abs(fract(across / 0.55) - 0.5);
	col = mix(col, dark_color.rgb * 0.5, (1.0 - smoothstep(0.0, 0.02, 0.5 - board)) * 0.7);
	ALBEDO = col;
	ROUGHNESS = 0.88;
}
