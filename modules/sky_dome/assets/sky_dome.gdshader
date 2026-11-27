shader_type spatial;
render_mode unshaded, cull_front, depth_draw_never;

uniform vec4 sky_top_color : source_color = vec4(0.12, 0.42, 0.78, 1.0);
uniform vec4 sky_horizon_color : source_color = vec4(0.55, 0.78, 0.92, 1.0);
uniform vec4 ground_color : source_color = vec4(0.20, 0.52, 0.65, 1.0);
uniform vec4 sun_color : source_color = vec4(1.0, 0.95, 0.82, 1.0);
uniform vec4 cloud_color : source_color = vec4(0.98, 0.98, 1.0, 1.0);

// Hướng TỚI mặt trời; đồng bộ với SUN_DIRECTION của map harbor_island.
uniform vec3 sun_direction = vec3(-0.368688, 0.766044, 0.526541);
uniform float sun_size = 0.04;
uniform float sun_blur = 0.015;
uniform float cloud_coverage = 0.45;
uniform float cloud_speed = 0.012;

// Hàm hash procedural 2D nhẹ không cần texture
vec2 hash2(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

// 2D Perlin-like Value Noise không vòng lặp nặng
float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float n00 = dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0));
    float n10 = dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float n01 = dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float n11 = dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    return mix(mix(n00, n10, u.x), mix(n01, n11, u.x), u.y);
}

// FBM 2 tầng nhẹ nhàng cho mobile
float fbm(vec2 p) {
    float v = 0.0;
    v += 0.65 * noise2d(p);
    v += 0.35 * noise2d(p * 2.1 + vec2(1.2, 3.4));
    return v * 0.5 + 0.5;
}

varying vec3 v_world_normal;

void vertex() {
    v_world_normal = normalize(VERTEX);
}

void fragment() {
    vec3 dir = normalize(v_world_normal);

    // 1. Gradient bầu trời nhiệt đới
    float h = clamp(dir.y, -0.2, 1.0);
    vec3 sky;
    if (h >= 0.0) {
        float factor = pow(1.0 - h, 1.8);
        sky = mix(sky_top_color.rgb, sky_horizon_color.rgb, factor);
    } else {
        float factor = clamp(-h * 5.0, 0.0, 1.0);
        sky = mix(sky_horizon_color.rgb, ground_color.rgb, factor);
    }

    // 2. Vùng sáng chân trời
    float horizon_glow = pow(1.0 - abs(dir.y), 6.0) * 0.25;
    sky += sky_horizon_color.rgb * horizon_glow;

    // 3. Mặt trời procedural (ẩn mượt khi xuống dưới đường chân trời ban đêm)
    vec3 sun_dir_norm = normalize(sun_direction);
    float sun_vis = smoothstep(-0.08, 0.12, sun_dir_norm.y);
    float sun_angle = acos(clamp(dot(dir, sun_dir_norm), -1.0, 1.0));
    float sun_disc = (1.0 - smoothstep(sun_size, sun_size + sun_blur, sun_angle)) * sun_vis;
    float sun_halo = pow(max(dot(dir, sun_dir_norm), 0.0), 128.0) * 0.4 * sun_vis;
    vec3 final_color = sky + sun_color.rgb * (sun_disc + sun_halo);

    // 4. Mây procedural trên vòm trời (chỉ sinh khi dir.y > 0.08)
    if (dir.y > 0.08) {
        vec2 sky_uv = (dir.xz / (dir.y + 0.25)) * 1.8;
        vec2 cloud_uv = sky_uv + vec2(TIME * cloud_speed, TIME * cloud_speed * 0.4);
        float cloud_val = fbm(cloud_uv);

        float cloud_mask = smoothstep(1.0 - cloud_coverage, 1.0 - cloud_coverage + 0.25, cloud_val);
        float fade = smoothstep(0.08, 0.35, dir.y);
        cloud_mask *= fade;

        final_color = mix(final_color, cloud_color.rgb, cloud_mask * 0.75);
    }

    ALBEDO = final_color;
}
