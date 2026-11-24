shader_type spatial;
render_mode cull_back, depth_draw_opaque;

// Shader địa hình tự nhiên phong cách Genshin kết hợp Sea of Thieves.
// Hoàn toàn Procedural: không texture, không sampler2D, tối ưu di động.
// Phối hợp 3 chất liệu: Cát bờ biển, Thảm cỏ tiên hiệp, Vách đá bazan xếp tầng.

uniform vec4 sand_color : source_color = vec4(0.94, 0.85, 0.63, 1.0);
uniform vec4 sand_wet_color : source_color = vec4(0.78, 0.68, 0.48, 1.0);
uniform vec4 grass_color : source_color = vec4(0.32, 0.72, 0.27, 1.0);
uniform vec4 grass_bright : source_color = vec4(0.42, 0.82, 0.35, 1.0);
uniform vec4 rock_color : source_color = vec4(0.42, 0.38, 0.35, 1.0);
uniform vec4 rock_dark : source_color = vec4(0.28, 0.25, 0.23, 1.0);

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

    // Nhiễu cát: gợn sóng gió nhẹ
    float sand_noise = gnoise(pos.xz * 1.5) * 0.5 + 0.5;
    vec3 sand_col = mix(sand_color.rgb, sand_color.rgb * 0.92, sand_noise);
    // Cát ẩm sát nước
    sand_col = mix(sand_wet_color.rgb, sand_col, smoothstep(-0.2, 0.3, pos.y));

    // Nhiễu thảm cỏ: biến thiên sáng tối theo mảng lớn
    float grass_noise = gnoise(pos.xz * 0.4) * 0.5 + 0.5;
    vec3 grass_col = mix(grass_color.rgb, grass_bright.rgb, grass_noise);

    // Vân vách đá xếp tầng theo trục thẳng đứng
    float rock_layer = gnoise(vec2(pos.y * 1.8, (pos.x + pos.z) * 0.3)) * 0.5 + 0.5;
    vec3 rock_col = mix(rock_color.rgb, rock_dark.rgb, rock_layer);

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
