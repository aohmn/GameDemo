shader_type spatial;
render_mode cull_back, depth_draw_opaque;
#include "res://assets/shaders/proc_common.gdshaderinc"

// Mái ngói: các hàng ngói so le, rìa dưới mỗi viên đổ bóng, mỗi viên lệch tông một chút.
uniform vec4 base_color : source_color = vec4(0.25, 0.30, 0.38, 1.0);
uniform vec4 dark_color : source_color = vec4(0.15, 0.18, 0.24, 1.0);
uniform float rows_per_meter = 3.2;
uniform float tile_width = 0.42;
uniform bool radial = false;

varying vec3 v_wp;
varying vec3 v_local;

void vertex() {
	v_wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_local = VERTEX;
}

void fragment() {
	float row_f = v_wp.y * rows_per_meter;
	float row = floor(row_f);
	float along = radial ? atan(v_local.x, v_local.z) * 2.2 : v_local.z;
	float col_f = along / tile_width + 0.5 * mod(row, 2.0);
	vec2 id = vec2(floor(col_f), row);
	vec2 f = vec2(fract(col_f), fract(row_f));
	vec3 col = mix(base_color.rgb, dark_color.rgb, h21(id) * 0.55);
	col *= 0.7 + 0.3 * smoothstep(0.0, 0.7, f.y);
	float seam = (1.0 - smoothstep(0.0, 0.07, f.x)) + (1.0 - smoothstep(0.0, 0.07, 1.0 - f.x));
	col = mix(col, dark_color.rgb * 0.55, clamp(seam, 0.0, 1.0) * 0.8);
	ALBEDO = col;
	ROUGHNESS = 0.7;
	METALLIC = 0.05;
}
