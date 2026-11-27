shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Núi đá vôi tiên cảnh: vệt dọc do mưa xói, tầng ngang mảnh, rêu xanh trên gờ, nhạt dần theo độ cao (sương).
uniform vec4 base_color : source_color = vec4(0.50, 0.50, 0.47, 1.0);
uniform vec4 dark_color : source_color = vec4(0.30, 0.33, 0.34, 1.0);
uniform vec4 moss_color : source_color = vec4(0.30, 0.55, 0.30, 1.0);
uniform vec4 mist_color : source_color = vec4(0.82, 0.90, 0.92, 1.0);
uniform float mist_height = 26.0;

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(v_wn);
	float around = v_wp.x * 0.8 + v_wp.z * 0.8;
	float streak = fbm2(vec2(around * 1.3, v_wp.y * 0.18)) * 0.7 + fbm2(vec2(around * 4.0, v_wp.y * 0.5)) * 0.3;
	float strata = vnoise(vec2(v_wp.y * 2.2, around * 0.4));
	vec3 col = mix(dark_color.rgb, base_color.rgb, 0.25 + streak * 0.75);
	col *= 0.8 + strata * 0.4;
	float ledge = smoothstep(0.35, 0.8, n.y);
	float patch = fbm2(v_wp.xz * 1.4 + v_wp.y * 0.7);
	col = mix(col, moss_color.rgb * (0.7 + patch * 0.5), clamp(ledge * (0.5 + patch), 0.0, 1.0) * 0.85);
	col = mix(col, mist_color.rgb, smoothstep(0.0, mist_height, v_wp.y) * 0.25);
	ALBEDO = col;
	ROUGHNESS = 0.92;
}
