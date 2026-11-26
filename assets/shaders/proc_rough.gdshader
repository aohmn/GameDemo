shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Đá thô (lò, kè đá): nhiễu hai tầng, khe nứt tối, vệt rêu nhẹ ở chân.
uniform vec4 base_color : source_color = vec4(0.35, 0.32, 0.30, 1.0);
uniform vec4 dark_color : source_color = vec4(0.2, 0.18, 0.17, 1.0);

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 uv = face_uv(v_wp, normalize(v_wn));
	float n = fbm2(uv * 3.0) * 0.6 + fbm2(uv * 11.0) * 0.4;
	vec3 col = mix(dark_color.rgb, base_color.rgb, 0.35 + n * 0.8);
	float crack = abs(vnoise(uv * 4.0) - 0.5);
	col = mix(col, dark_color.rgb * 0.5, (1.0 - smoothstep(0.0, 0.035, crack)) * 0.6);
	ALBEDO = col;
	ROUGHNESS = 0.95;
}
