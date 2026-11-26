shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Đá phiến lát đường/quảng trường: ô vuông, vữa giữa các viên, tông màu lệch theo viên, nhám hạt.
uniform vec4 base_color : source_color = vec4(0.74, 0.72, 0.67, 1.0);
uniform vec4 dark_color : source_color = vec4(0.5, 0.48, 0.44, 1.0);
uniform float tile_size = 1.1;

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 uv = face_uv(v_wp, normalize(v_wn)) / tile_size;
	vec2 id = floor(uv);
	vec2 f = fract(uv);
	vec3 col = mix(base_color.rgb, dark_color.rgb, h21(id) * 0.4);
	col *= 0.92 + fbm2(uv * 9.0) * 0.16;
	vec2 edge = min(f, 1.0 - f);
	float grout = 1.0 - smoothstep(0.0, 0.04, min(edge.x, edge.y));
	col = mix(col, dark_color.rgb * 0.8, grout * 0.7);
	ALBEDO = col;
	ROUGHNESS = 0.85;
}
