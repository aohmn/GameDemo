shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Tán lá: mảng lá sáng tối theo cụm, chấm lá sáng, sáng dần lên phía trên.
uniform vec4 base_color : source_color = vec4(0.24, 0.62, 0.28, 1.0);
uniform vec4 dark_color : source_color = vec4(0.12, 0.38, 0.2, 1.0);

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec3 n = normalize(v_wn);
	vec2 uv = vec2(v_wp.x + v_wp.z * 0.7, v_wp.y * 1.3 + v_wp.z * 0.4);
	float clump = fbm2(uv * 2.6);
	vec3 col = mix(dark_color.rgb, base_color.rgb, 0.25 + clump * 0.9);
	float leaf = h21(floor(uv * 7.0));
	col = mix(col, base_color.rgb * 1.15, step(0.86, leaf) * 0.4);
	col *= 0.72 + 0.28 * clamp(n.y * 0.5 + 0.5, 0.0, 1.0);
	ALBEDO = col;
	ROUGHNESS = 0.85;
}
