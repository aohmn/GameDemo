shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// Shader địa hình tự nhiên phong cách Genshin kết hợp Sea of Thieves.
// Hoàn toàn Procedural: không texture, không sampler2D, tối ưu di động.
// Phối hợp 3 chất liệu: Cát bờ biển, Thảm cỏ tiên hiệp, Vách đá bazan xếp tầng.

uniform vec4 sand_color : source_color = vec4(0.94, 0.85, 0.63, 1.0);
uniform vec4 sand_wet_color : source_color = vec4(0.78, 0.68, 0.48, 1.0);
uniform vec4 grass_color : source_color = vec4(0.26, 0.54, 0.22, 1.0);
uniform vec4 grass_bright : source_color = vec4(0.40, 0.68, 0.28, 1.0);
uniform vec4 grass_dry : source_color = vec4(0.58, 0.58, 0.28, 1.0);
uniform vec4 rock_color : source_color = vec4(0.50, 0.43, 0.36, 1.0);
uniform vec4 rock_dark : source_color = vec4(0.27, 0.23, 0.21, 1.0);

varying vec3 v_world_pos;
varying vec3 v_world_normal;

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

void vertex() {
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    v_world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

void fragment() {
    vec3 pos = v_world_pos;
    vec3 norm = normalize(v_world_normal);

    // Cát: gợn sóng gió, hạt li ti, vài vỏ sò sẫm, ẩm dần về phía nước
    float sand_noise = gnoise(pos.xz * 1.5) * 0.5 + 0.5;
    float ripple = sin((pos.x * 0.8 + pos.z * 0.45) * 6.0 + gnoise(pos.xz * 0.8) * 4.0);
    float grain = hash2(floor(pos.xz * 36.0)).x * 0.5 + 0.5;
    vec3 sand_col = mix(sand_color.rgb, sand_color.rgb * 0.9, sand_noise);
    sand_col *= 1.0 + ripple * 0.04;
    sand_col *= 0.95 + grain * 0.1;
    float shell = step(0.992, hash2(floor(pos.xz * 7.0)).y * 0.5 + 0.5) * smoothstep(0.3, 0.15, length(fract(pos.xz * 7.0) - 0.5));
    sand_col = mix(sand_col, sand_wet_color.rgb * 0.7, shell * 0.8);
    sand_col = mix(sand_wet_color.rgb, sand_col, smoothstep(-0.2, 0.3, pos.y));

    // Cỏ: mảng sáng tối lớn, vùng cỏ khô, sợi cỏ mảnh, lác đác hoa nhỏ
    float g_big = gnoise(pos.xz * 0.35) * 0.5 + 0.5;
    float g_mid = gnoise(pos.xz * 1.9) * 0.5 + 0.5;
    float blades = gnoise(vec2(pos.x * 13.0, pos.z * 2.6)) * 0.5 + 0.5;
    vec3 grass_col = mix(grass_color.rgb, grass_bright.rgb, g_mid);
    grass_col = mix(grass_col, grass_dry.rgb, smoothstep(0.62, 0.9, g_big) * 0.65);
    grass_col *= 0.88 + blades * 0.24;
    float flower = step(0.985, hash2(floor(pos.xz * 5.0)).x * 0.5 + 0.5) * smoothstep(0.26, 0.14, length(fract(pos.xz * 5.0) - 0.5));
    grass_col = mix(grass_col, vec3(0.95, 0.88, 0.55), flower * 0.8);

    // Đá: các tầng ngang theo độ cao, vệt xói mòn dọc, rêu mỏng ở chân vách
    float layer_id = floor(pos.y * 2.4);
    float layer_tone = hash2(vec2(layer_id, 4.0)).x * 0.5 + 0.5;
    float erosion = gnoise(vec2((pos.x + pos.z) * 2.2, pos.y * 0.5)) * 0.5 + 0.5;
    float rock_layer = clamp(layer_tone * 0.7 + erosion * 0.5, 0.0, 1.0);
    vec3 rock_col = mix(rock_color.rgb, rock_dark.rgb, rock_layer);
    rock_col *= 0.9 + (gnoise(pos.xz * 6.0 + pos.y * 3.0) * 0.5 + 0.5) * 0.2;
    float band = abs(fract(pos.y * 2.4) - 0.5);
    rock_col *= 0.82 + 0.18 * smoothstep(0.0, 0.08, 0.5 - band);
    rock_col = mix(rock_col, grass_color.rgb * 0.7, (1.0 - smoothstep(0.0, 0.6, pos.y)) * 0.25);

    // Phân tầng theo độ dốc: vách dốc là đá, mặt phẳng là cỏ/cát
    float slope = clamp(norm.y, 0.0, 1.0);
    float is_rock = 1.0 - smoothstep(0.55, 0.75, slope);

    // Phân tầng theo độ cao: bờ cát ven biển chuyển dần lên đồi cỏ
    float is_grass = smoothstep(0.15, 0.55, pos.y);

    vec3 ground_col = mix(sand_col, grass_col, is_grass);
    vec3 final_col = mix(ground_col, rock_col, is_rock);

    ALBEDO = final_col;
    ROUGHNESS = mix(0.7, 0.9, is_rock);
    SPECULAR = 0.2;
}
