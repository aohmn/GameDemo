shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Ván gỗ lát sàn: ván dọc theo trục Z, khe giữa các ván, mối nối so le, vân gỗ và đầu đinh.
uniform vec4 base_color : source_color = vec4(0.60, 0.44, 0.28, 1.0);
uniform vec4 dark_color : source_color = vec4(0.40, 0.26, 0.16, 1.0);
uniform float plank_width = 0.5;
uniform float plank_length = 2.4;

varying vec3 v_wp;
varying vec3 v_wn;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
	vec2 uv = face_uv(v_wp, normalize(v_wn));
	float row = floor(uv.x / plank_width);
	float off = h21(vec2(row, 3.0)) * plank_length;
	float seg = floor((uv.y + off) / plank_length);
	vec2 f = vec2(fract(uv.x / plank_width), fract((uv.y + off) / plank_length));
	float tone = h21(vec2(row, seg));
	vec3 col = mix(base_color.rgb, dark_color.rgb, tone * 0.65);
	float grain = fbm2(vec2(uv.x * 14.0, uv.y * 1.1 + row * 5.0));
	col *= 0.86 + grain * 0.26;
	float gap = (1.0 - smoothstep(0.0, 0.05, f.x)) + (1.0 - smoothstep(0.0, 0.05, 1.0 - f.x));
	gap += (1.0 - smoothstep(0.0, 0.012, f.y)) * 0.8;
	col = mix(col, dark_color.rgb * 0.45, clamp(gap, 0.0, 1.0));
	ALBEDO = col;
	ROUGHNESS = 0.9;
}
