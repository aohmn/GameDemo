// Hàm dùng chung cho shader vật liệu procedural (không texture, không sampler2D).

float h21(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h21(i), h21(i + vec2(1.0, 0.0)), f.x),
			mix(h21(i + vec2(0.0, 1.0)), h21(i + vec2(1.0, 1.0)), f.x), f.y);
}

float fbm2(vec2 p) {
	return vnoise(p) * 0.6 + vnoise(p * 2.13 + 7.3) * 0.4;
}

// Toạ độ bề mặt theo trục trội của pháp tuyến: mặt trên dùng XZ, mặt bên dùng ZY hoặc XY.
vec2 face_uv(vec3 wp, vec3 n) {
	vec3 a = abs(n);
	if (a.y >= a.x && a.y >= a.z) {
		return wp.xz;
	}
	if (a.x >= a.z) {
		return vec2(wp.z, wp.y);
	}
	return vec2(wp.x, wp.y);
}
