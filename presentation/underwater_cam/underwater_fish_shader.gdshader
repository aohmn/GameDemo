shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform float swim_time = 0.0;
uniform float swim_speed = 1.0;
uniform float alert_level = 0.0;
uniform vec3 body_color : source_color = vec3(0.16, 0.52, 0.68);
uniform vec3 belly_color : source_color = vec3(0.75, 0.88, 0.92);
uniform vec3 fin_color : source_color = vec3(0.92, 0.55, 0.25);
uniform float is_fin = 0.0;

varying float v_body_x;
varying float v_body_y;

void vertex() {
	v_body_x = VERTEX.x;
	v_body_y = VERTEX.y;
	// Uốn thân và đuôi theo hình sin dọc trục X (đầu ở +X, đuôi ở -X)
	float tail_factor = clamp((0.35 - VERTEX.x) * 1.1, 0.0, 1.5);
	float wave = sin(swim_time * (3.5 + swim_speed * 4.0) - VERTEX.x * 4.5);
	VERTEX.z += wave * tail_factor * (0.045 + swim_speed * 0.035);
}

void fragment() {
	// Phân biệt màu vây và thân
	float belly_mask = smoothstep(-0.18, 0.15, -v_body_y);
	vec3 base_col = mix(body_color, belly_color, belly_mask * 0.75);

	// Vân vảy toán học nhẹ (không dùng texture)
	float scale_pat = sin(v_body_x * 28.0) * sin(v_body_y * 28.0);
	base_col += vec3(0.05, 0.08, 0.1) * smoothstep(0.3, 0.9, scale_pat);

	// Vây có màu riêng
	base_col = mix(base_col, fin_color, is_fin);

	// Nhấp nháy nhẹ khi cá tung chiêu / cảnh báo
	vec3 alert_tint = vec3(1.0, 0.35, 0.2);
	base_col = mix(base_col, alert_tint, alert_level * 0.45);

	ALBEDO = base_col;
	ROUGHNESS = mix(0.32, 0.55, is_fin);
	METALLIC = 0.15;
}
