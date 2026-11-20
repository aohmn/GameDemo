shader_type canvas_item;

uniform float world_seed = 7.0;
uniform float road_width = 0.035;
uniform float branch_width = 0.022;
uniform float canal_width = 0.025;
uniform float detail_scale = 24.0;
uniform vec2 viewport_size = vec2(720.0, 1280.0);

float hash(vec2 p) {
    p = fract(p * vec2(127.1, 311.7) + world_seed);
    p += dot(p, p + 34.5);
    return fract(p.x * p.y);
}

float noise_value(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(
        mix(a, b, f.x),
        mix(c, d, f.x),
        f.y
    );
}

void fragment() {
    vec2 uv = UV;
    float aspect = viewport_size.x / max(viewport_size.y, 1.0);
    vec2 noise_uv = vec2(uv.x * aspect, uv.y);

    float n1 = noise_value(noise_uv * detail_scale);
    float n2 = noise_value(noise_uv * detail_scale * 0.37 + vec2(12.4, 3.7));
    float n3 = noise_value(noise_uv * 6.0 + vec2(4.2, 18.0));

    float terrain_mix = n1 * 0.48 + n2 * 0.34 + n3 * 0.18;

    vec3 grass_dark = vec3(0.17, 0.34, 0.16);
    vec3 grass_mid = vec3(0.27, 0.48, 0.22);
    vec3 grass_light = vec3(0.43, 0.59, 0.29);
    vec3 soil = vec3(0.48, 0.39, 0.24);

    vec3 terrain = mix(
        grass_dark,
        grass_mid,
        smoothstep(0.22, 0.58, terrain_mix)
    );

    terrain = mix(
        terrain,
        grass_light,
        smoothstep(0.66, 0.86, terrain_mix) * 0.48
    );

    terrain = mix(
        terrain,
        soil,
        smoothstep(0.73, 0.88, n3) * 0.18
    );

    float road_center = 0.52
        + sin(uv.y * 7.0 + world_seed * 0.2) * 0.075
        + sin(uv.y * 15.0 + 1.3) * 0.018;

    float road_dist = abs(uv.x - road_center);

    float road_fill = 1.0 - smoothstep(
        road_width * 0.85,
        road_width,
        road_dist
    );

    float shoulder_fill = 1.0 - smoothstep(
        road_width,
        road_width * 1.65,
        road_dist
    );

    vec3 shoulder_color = vec3(0.46, 0.43, 0.34);
    vec3 road_color = vec3(0.24, 0.25, 0.24);

    terrain = mix(terrain, shoulder_color, shoulder_fill);
    terrain = mix(terrain, road_color, road_fill);

    float branch_center = 0.67 + sin(uv.x * 5.0 + 1.1) * 0.045;
    float branch_dist = abs(uv.y - branch_center);

    float branch_fill = 1.0 - smoothstep(
        branch_width * 0.85,
        branch_width,
        branch_dist
    );

    float branch_shoulder = 1.0 - smoothstep(
        branch_width,
        branch_width * 1.6,
        branch_dist
    );

    terrain = mix(terrain, shoulder_color, branch_shoulder);
    terrain = mix(terrain, road_color, branch_fill);

    float canal_center = 0.84 + sin(uv.x * 5.2 + 0.7) * 0.055;
    float canal_dist = abs(uv.y - canal_center);

    float canal_fill = 1.0 - smoothstep(
        canal_width * 0.82,
        canal_width,
        canal_dist
    );

    float canal_bank = 1.0 - smoothstep(
        canal_width,
        canal_width * 1.8,
        canal_dist
    );

    vec3 bank_color = vec3(0.37, 0.43, 0.29);
    vec3 water_color = vec3(0.12, 0.37, 0.49);

    terrain = mix(terrain, bank_color, canal_bank);
    terrain = mix(terrain, water_color, canal_fill);

    float ripple = noise_value(
        noise_uv * 95.0 + vec2(TIME * 0.04, TIME * 0.02)
    );

    terrain += water_color * (ripple - 0.5) * 0.045 * canal_fill;
    terrain += (n1 - 0.5) * 0.035;

    COLOR = vec4(terrain, 1.0);
}
