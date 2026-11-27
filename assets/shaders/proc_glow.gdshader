shader_type spatial;
render_mode unshaded, cull_back;

// Vật phát sáng (đèn lồng, linh châu, ngọn lửa): sáng nhấp nháy nhẹ theo thời gian.
uniform vec4 base_color : source_color = vec4(1.0, 0.7, 0.3, 1.0);
uniform vec4 dark_color : source_color = vec4(0.5, 0.3, 0.1, 1.0);
uniform float pulse_speed = 1.6;

void fragment() {
	float pulse = 0.88 + 0.12 * sin(TIME * pulse_speed + (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).x * 1.7);
	float rim = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.0);
	ALBEDO = mix(base_color.rgb, vec3(1.0), rim * 0.35) * pulse;
}
