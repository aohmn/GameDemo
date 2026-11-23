shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx, depth_draw_opaque;

uniform vec4 base_color : source_color = vec4(0.42, 0.45, 0.40, 1.0);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.82;
uniform float surface_detail : hint_range(0.0, 0.12) = 0.025;
uniform float fresnel_strength : hint_range(0.0, 0.15) = 0.035;
uniform float transparency_alpha : hint_range(0.0, 1.0) = 1.0;

varying vec3 world_position;

float hash_position(vec3 p) {
    p = fract(p * 0.3183099 + vec3(0.1, 0.2, 0.3));
    p *= 17.0;
    return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float broad_variation = hash_position(floor(world_position * 1.7));
    float fine_variation = hash_position(floor(world_position * 13.0));
    float variation = (broad_variation - 0.5) * 0.045
        + (fine_variation - 0.5) * surface_detail;

    vec3 normal_view = normalize(NORMAL);
    float rim = pow(1.0 - max(dot(normal_view, VIEW), 0.0), 3.0);

    ALBEDO = max(base_color.rgb * (1.0 + variation), vec3(0.0));
    ALPHA = transparency_alpha;
    ROUGHNESS = roughness_value;
    METALLIC = 0.0;
    SPECULAR = 0.28;
    EMISSION = base_color.rgb * rim * fresnel_strength * 0.12;
}
