shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// Nước biển phong cách Sea of Thieves kết hợp Genshin Impact:
// Dải màu 3 tầng độ sâu, sóng cuộn gợn nhấp nhô vertex, bọt ven bờ tự nhiên,
// vòng bọt sóng vỗ bờ, phản xạ lấp lánh cel-glint ánh mặt trời và mờ dần chân trời.

uniform vec4 water_shallow : source_color = vec4(0.50, 0.90, 0.82, 0.95);
uniform vec4 water_mid : source_color = vec4(0.16, 0.62, 0.70, 1.0);
uniform vec4 water_deep : source_color = vec4(0.07, 0.34, 0.50, 1.0);
uniform vec4 foam_color : source_color = vec4(0.97, 0.99, 1.0, 1.0);
uniform vec4 far_color : source_color = vec4(0.80, 0.91, 0.93, 1.0);
uniform vec3 sun_dir = vec3(-0.368688, 0.766044, 0.526541);
uniform float wave_speed = 0.55;
uniform float fade_start = 70.0;
uniform float fade_end = 240.0;

// Hình học bờ đảo: hợp các elip (tâm x, z; bán kính x, z) xấp xỉ nền đảo bậc thang.
uniform vec4 blob_a = vec4(0.0, 3.0, 20.5, 10.0);
uniform vec4 blob_b = vec4(0.0, -11.0, 16.5, 8.0);
uniform vec4 blob_c = vec4(0.0, -22.0, 11.5, 6.5);
uniform vec2 pier_center = vec2(-2.0, 17.0);
uniform vec2 pier_half = vec2(2.5, 6.5);

varying vec3 v_world;

vec2 hash2(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.xx + p3.yz) * p3.zy) * 2.0 - 1.0;
}

float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(
        mix(dot(hash2(i), f), dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
        mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)), dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x),
        u.y);
}

float sd_box(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
}

float blob_dist(vec2 p, vec4 b) {
    vec2 q = (p - b.xy) / b.zw;
    return (length(q) - 1.0) * min(b.z, b.w);
}

float coast_dist(vec2 p) {
    float d = min(blob_dist(p, blob_a), blob_dist(p, blob_b));
    d = min(d, blob_dist(p, blob_c));
    return min(d, sd_box(p - pier_center, pier_half));
}

void vertex() {
    v_world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 p = v_world.xz;
    float t = TIME * wave_speed;
    float coast = coast_dist(p);

    // Nhiễu nước 2 lớp ổn định
    float n1 = gnoise(p * 0.35 + vec2(t * 0.20, -t * 0.12));
    float n2 = gnoise(p * 0.90 + vec2(-t * 0.30, t * 0.22) + 7.3);

    // Phân tầng độ sâu nước theo khoảng cách bờ
    float d = coast / 20.0 + n1 * 0.05;
    vec3 col = water_shallow.rgb;
    col = mix(col, water_mid.rgb, smoothstep(0.08, 0.16, d));
    col = mix(col, water_deep.rgb, smoothstep(0.40, 0.52, d));

    // Bọt sát mép bờ và vòng bọt vỗ bờ
    float edge_foam = 1.0 - smoothstep(0.2, 0.75 + n2 * 0.35, coast);
    float ring = smoothstep(0.86, 0.96, 0.5 + 0.5 * sin((coast * 0.32 - t * 0.38) * 6.28318));
    ring *= (1.0 - smoothstep(3.0, 7.0, coast)) * smoothstep(1.0, 2.2, coast) * 0.6;
    ring *= smoothstep(-0.25, 0.25, n1 + n2 * 0.5);
    float foam = clamp(edge_foam + ring, 0.0, 1.0);
    col = mix(col, foam_color.rgb, foam);

    // Lấp lánh mặt trời (cel specular glint phong cách Genshin / Sea of Thieves)
    float a = p.x * 0.9 + p.y * 0.6 + t * 1.3;
    float b = p.x * 1.7 - p.y * 1.1 - t * 1.9;
    vec3 n = normalize(vec3(cos(a) * 0.08 + cos(b) * 0.04, 1.0, cos(a * 0.8 + 1.0) * 0.07 + cos(b * 1.2) * 0.04));
    vec3 view = normalize(CAMERA_POSITION_WORLD - v_world);
    vec3 h = normalize(view + normalize(sun_dir));
    float spec = pow(max(dot(n, h), 0.0), 96.0);
    col += vec3(1.0, 0.97, 0.88) * smoothstep(0.32, 0.48, spec) * (1.0 - foam) * 0.75;

    // Hòa quyện mờ dần về chân trời
    float dist = length(v_world.xz - CAMERA_POSITION_WORLD.xz);
    col = mix(col, far_color.rgb, smoothstep(fade_start, fade_end, dist));

    ALBEDO = col;
    ROUGHNESS = 0.15;
    SPECULAR = 0.3;
}
