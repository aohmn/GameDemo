shader_type spatial;
render_mode cull_back, depth_draw_always, diffuse_burley, specular_schlick_ggx;

uniform vec4 shallow_color : source_color = vec4(0.20, 0.78, 0.80, 0.75);
uniform vec4 deep_color : source_color = vec4(0.05, 0.18, 0.44, 0.95);
uniform vec4 foam_color : source_color = vec4(0.94, 0.98, 1.0, 0.92);

uniform vec2 island_center = vec2(0.0, 4.0);
uniform float shallow_radius = 21.0;
uniform float deep_radius = 37.0;

uniform float wave_speed = 0.65;

varying vec3 v_world_pos;

// 4 lớp sóng bất đối xứng, tần số vô tỉ (không bội số), khác hướng để triệt tiêu pattern sọc
void vertex() {
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec2 p = v_world_pos.xz;
    float t = TIME * wave_speed;

    float w1 = sin(p.x * 0.23 + p.y * 0.17 + t * 0.85) * 0.016;
    float w2 = cos(-p.x * 0.19 + p.y * 0.29 + t * 0.62) * 0.013;
    float w3 = sin(p.x * 0.37 - p.y * 0.21 + t * 1.15) * 0.009;
    float w4 = cos(p.x * 0.13 + p.y * 0.43 - t * 0.47) * 0.007;

    VERTEX.y += (w1 + w2 + w3 + w4);
}

// 2D Hash & Value Noise nhẹ nhàng, không texture, không sampler2D
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float a = dot(hash2(i), f);
    float b = dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

void fragment() {
    vec2 p = v_world_pos.xz;
    float t = TIME * wave_speed;

    // 1. Khoảng cách tới đảo bãi cát (hình oval mềm, có chút biến thiên tự nhiên)
    vec2 offset = p - island_center;
    offset.y *= 1.14;
    float dist = length(offset);

    // 2. Chuyển màu nước nông (xanh ngọc sáng trong) -> nước sâu (xanh lam đậm)
    float depth_factor = clamp((dist - shallow_radius) / (deep_radius - shallow_radius), 0.0, 1.0);
    depth_factor = smoothstep(0.0, 1.0, depth_factor);
    vec4 water_color = mix(shallow_color, deep_color, depth_factor);

    // 3. Gợn nước đa hướng, đa pha: không song song, không chu kỳ đơn điệu
    // Lớp 1: Gợn lăn tăn nhẹ hướng chéo Đông-Bắc
    float r1 = sin(p.x * 1.15 + p.y * 0.85 + t * 1.1);
    float r1_dx = 1.15 * cos(p.x * 1.15 + p.y * 0.85 + t * 1.1);
    float r1_dz = 0.85 * cos(p.x * 1.15 + p.y * 0.85 + t * 1.1);

    // Lớp 2: Gợn hướng Tây-Bắc với tần số khác
    float r2 = cos(-p.x * 0.92 + p.y * 1.38 + t * 0.82);
    float r2_dx = 0.92 * sin(-p.x * 0.92 + p.y * 1.38 + t * 0.82);
    float r2_dz = -1.38 * sin(-p.x * 0.92 + p.y * 1.38 + t * 0.82);

    // Lớp 3: Nhiễu 2D noise trôi chậm phá vỡ mọi quy luật hình học
    vec2 drift = vec2(t * 0.12, -t * 0.08);
    float n1 = noise2d(p * 0.45 + drift);
    float n2 = noise2d(p * 0.95 - drift * 1.3);

    // Tính toán pháp tuyến bề mặt mặt nước (NORMAL) mềm mại, tự nhiên
    float normal_x = -(r1_dx * 0.022 + r2_dx * 0.018 + (n1 - n2) * 0.035);
    float normal_z = -(r1_dz * 0.022 + r2_dz * 0.018 + (n2 + n1) * 0.035);
    NORMAL = normalize(vec3(normal_x, 1.0, normal_z));

    // 4. Bọt trắng rất tinh tế ven mép cát (được điều biến bởi sóng và nhiễu)
    float shore_in = smoothstep(shallow_radius - 1.2, shallow_radius + 0.1, dist);
    float shore_out = 1.0 - smoothstep(shallow_radius + 0.1, shallow_radius + 1.4, dist);
    float shore_band = shore_in * shore_out;

    float foam_pattern = (n1 * 0.6 + n2 * 0.4) + (r1 + r2) * 0.15;
    float foam_mask = shore_band * smoothstep(0.15, 0.48, foam_pattern);

    // 5. Màu sắc, chiều sâu quang học và phản chiếu ánh sáng tự nhiên
    vec3 final_albedo = mix(water_color.rgb, foam_color.rgb, foam_mask * 0.65);

    ALBEDO = final_albedo;
    ROUGHNESS = mix(0.08, 0.32, foam_mask);
    METALLIC = 0.02;
    SPECULAR = 0.7;
    ALPHA = mix(water_color.a, foam_color.a, foam_mask);
}
