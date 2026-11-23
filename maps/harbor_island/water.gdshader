shader_type spatial;
render_mode cull_back, depth_draw_always, diffuse_burley, specular_schlick_ggx;

// 1. Bảng màu đại dương nhiệt đới chân thực
uniform vec4 water_shallow : source_color = vec4(0.24, 0.82, 0.80, 0.72);
uniform vec4 water_mid : source_color = vec4(0.10, 0.48, 0.68, 0.88);
uniform vec4 water_deep : source_color = vec4(0.03, 0.16, 0.38, 0.98);
uniform vec4 foam_color : source_color = vec4(0.96, 0.98, 1.0, 0.90);
uniform vec4 sun_specular_color : source_color = vec4(1.0, 0.96, 0.88, 1.0);

// Hướng ánh sáng mặt trời khớp với TropicalSun trong map (rotation -50, -35)
uniform vec3 sun_dir = vec3(0.46, 0.77, 0.44);

// 2. Tham số thời gian và sóng
uniform float wave_speed = 0.55;

varying vec3 v_world_pos;
varying vec3 v_normal;

// Các hàm Noise procedural không texture: Hash, Gradient Noise và Domain Warping
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float gnoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(
        mix(dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
            dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
        mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
            dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x),
        u.y
    );
}

// FBM 4 bát độ (octaves) cho mặt sóng biến thiên tự nhiên
float fbm4(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    mat2 rot = mat2(vec2(0.80, 0.60), vec2(-0.60, 0.80));
    for (int i = 0; i < 4; i++) {
        v += a * gnoise(p);
        p = rot * p * 2.02;
        a *= 0.5;
    }
    return v;
}

// Domain-warped Noise phá vỡ mọi pattern tuần hoàn
float warped_noise(vec2 p, float time_val) {
    vec2 q = vec2(
        fbm4(p + vec2(0.0, 0.0) + vec2(time_val * 0.15, time_val * 0.08)),
        fbm4(p + vec2(5.2, 1.3) + vec2(-time_val * 0.11, time_val * 0.13))
    );

    vec2 r = vec2(
        fbm4(p + 3.8 * q + vec2(1.7, 9.2) + vec2(time_val * 0.06, -time_val * 0.09)),
        fbm4(p + 3.8 * q + vec2(8.3, 2.8) + vec2(-time_val * 0.07, time_val * 0.05))
    );

    return fbm4(p + 3.5 * r);
}

// Hàm tính SDF hình học bờ biển thực tế của map:
// - Bãi cát đảo: Hình hộp bo góc (round box) tâm (0, 4), nửa kích thước (22, 19), bo góc R=5.5
// - Núi đá che chắn vịnh hai bên: 2 khối trụ tâm (-18, -4) và (18, -4)
// - Cầu tàu bến cảng: hộp (x: -2, z: 16.5)
float sd_box(vec2 p, vec2 b) {
    vec2 d = abs(p) - b;
    return length(max(d, vec2(0.0))) + min(max(d.x, d.y), 0.0);
}

float get_coastline_dist(vec2 p) {
    // 1. Khoảng cách tới bãi cát đảo chính (bo tròn tự nhiên)
    float d_beach = sd_box(p - vec2(0.0, 4.0), vec2(16.5, 13.5)) - 5.5;

    // 2. Núi đá phía Tây và phía Đông tạo sườn bờ đá
    float d_cliff_w = length(p - vec2(-17.0, -5.0)) - 6.5;
    float d_cliff_e = length(p - vec2(17.0, -5.0)) - 6.5;

    // 3. Cầu tàu gỗ vươn ra biển
    float d_pier = sd_box(p - vec2(-2.0, 16.5), vec2(2.5, 6.5));

    float d_coast = min(d_beach, min(d_cliff_w, d_cliff_e));
    d_coast = min(d_coast, d_pier);

    return d_coast;
}

// Đỉnh vertex: sóng nhấp nhô đa hướng, triệt tiêu sọc thẳng
void vertex() {
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec2 p = v_world_pos.xz;
    float t = TIME * wave_speed;

    // Sóng cơ sở nhấp nhô mềm
    float s1 = sin(p.x * 0.22 + p.y * 0.16 + t * 0.85);
    float s2 = cos(-p.x * 0.18 + p.y * 0.27 + t * 0.63);
    float s3 = sin(p.x * 0.35 - p.y * 0.21 + t * 1.12);

    float wave_height = (s1 * 0.022 + s2 * 0.017 + s3 * 0.011);

    VERTEX.y += wave_height;
    v_normal = NORMAL;
}

void fragment() {
    vec2 p = v_world_pos.xz;
    float t = TIME * wave_speed;

    // 1. Độ sâu biển dựa trên hình học bờ biển thực tế
    float coast_dist = get_coastline_dist(p);

    // Chuyển màu nước 3 tầng: Nông sát bờ -> Vùng chuyển tiếp -> Biển sâu
    float depth_trans = clamp(coast_dist / 14.0, 0.0, 1.0);
    vec4 water_color;
    if (depth_trans < 0.35) {
        float f = depth_trans / 0.35;
        water_color = mix(water_shallow, water_mid, smoothstep(0.0, 1.0, f));
    } else {
        float f = (depth_trans - 0.35) / 0.65;
        water_color = mix(water_mid, water_deep, smoothstep(0.0, 1.0, f));
    }

    // 2. Hệ pháp tuyến sóng đa thang (Multi-scale Normal) bằng Domain-Warped Noise
    float e = 0.15;
    float h_c = warped_noise(p * 0.48, t * 1.1);
    float h_x = warped_noise((p + vec2(e, 0.0)) * 0.48, t * 1.1);
    float h_z = warped_noise((p + vec2(0.0, e)) * 0.48, t * 1.1);

    vec3 n_fbm = vec3((h_c - h_x) / e, 1.0, (h_c - h_z) / e);

    // Gợn sóng lăn tăn vi mô (capillary ripples) tần số cao
    float micro1 = sin(p.x * 1.8 + p.y * 1.2 + t * 2.2);
    float micro2 = cos(-p.x * 1.4 + p.y * 2.1 - t * 1.8);
    vec3 n_micro = vec3(micro1 * 0.04, 1.0, micro2 * 0.04);

    vec3 surf_normal = normalize(n_fbm * 0.5 + n_micro * 0.5);
    NORMAL = surf_normal;

    // 3. Bọt biển hữu cơ bám theo đường bờ thực tế
    float foam_band = 1.0 - smoothstep(0.0, 1.6, abs(coast_dist - 0.4));
    float foam_noise = warped_noise(p * 0.85 + vec2(t * 0.25, -t * 0.18), t * 0.5);
    float foam_mask = foam_band * smoothstep(0.12, 0.45, foam_noise);

    // 4. Quang học bề mặt: Fresnel, phản chiếu mặt trời và bầu trời
    vec3 view_dir = normalize(VIEW);
    float fresnel = pow(1.0 - max(dot(view_dir, NORMAL), 0.0), 4.5);

    // Specular mặt trời thực tế (Blinn-Phong)
    vec3 light_dir = normalize(sun_dir);
    vec3 half_v = normalize(view_dir + light_dir);
    float n_dot_h = max(dot(NORMAL, half_v), 0.0);
    float sun_spec = pow(n_dot_h, 128.0) * 1.2;
    float sun_glint = pow(n_dot_h, 512.0) * 2.5;

    // Hòa trộn màu bề mặt và bọt biển mềm
    vec3 albedo_base = mix(water_color.rgb, foam_color.rgb, foam_mask * 0.65);
    // Tán xạ ánh sáng xanh ngọc ở sườn sóng
    albedo_base += water_shallow.rgb * (fresnel * 0.22);
    // Điểm nhấn lấp lánh phản chiếu mặt trời
    albedo_base += sun_specular_color.rgb * (sun_spec + sun_glint);

    ALBEDO = albedo_base;
    ROUGHNESS = mix(0.06, 0.35, foam_mask);
    METALLIC = 0.02;
    SPECULAR = 0.85;
    ALPHA = mix(water_color.a, foam_color.a, foam_mask);
}
