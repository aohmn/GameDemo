shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Bạch ngọc/đá cẩm thạch: nền sáng, vân mảnh uốn lượn, đường ghép tấm.
uniform vec4 base_color : source_color = vec4(0.92, 0.96, 0.94, 1.0);
uniform vec4 dark_color : source_color = vec4(0.62, 0.74, 0.72, 1.0);
uniform float panel = 1.6;

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 uv = face_uv(v_wp, normalize(v_wn));
	float warp = fbm2(uv * 1.6) * 4.0;
	float vein = abs(sin((uv.x * 1.3 + uv.y * 0.9) * 2.2 + warp));
	vein = 1.0 - smoothstep(0.0, 0.16, vein);
	vec3 col = mix(base_color.rgb, dark_color.rgb, vein * 0.55 + fbm2(uv * 3.0) * 0.12);
	vec2 f = fract(uv / panel);
	vec2 edge = min(f, 1.0 - f);
	col = mix(col, dark_color.rgb * 0.8, (1.0 - smoothstep(0.0, 0.012, min(edge.x, edge.y))) * 0.8);
	ALBEDO = col;
	ROUGHNESS = 0.35;
	SPECULAR = 0.6;
}
