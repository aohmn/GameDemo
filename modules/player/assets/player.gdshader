shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

uniform vec4 outline_color : source_color = vec4(0.18, 0.14, 0.11, 1.0);
uniform vec4 skin_color : source_color = vec4(0.91, 0.71, 0.55, 1.0);
uniform vec4 shirt_color : source_color = vec4(0.30, 0.57, 0.63, 1.0);
uniform vec4 pants_color : source_color = vec4(0.22, 0.29, 0.38, 1.0);
uniform vec4 shoes_color : source_color = vec4(0.27, 0.21, 0.18, 1.0);

uniform float outline_width = 0.035;
uniform float walk_phase = 0.0;
uniform float moving = 0.0;
uniform int facing = 0;
uniform bool flip_horizontal = false;

float sd_round_box(vec2 p, vec2 half_size, float radius) {
    vec2 q = abs(p) - half_size + vec2(radius);
    return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

float fill_shape(float d) {
    return 1.0 - smoothstep(-0.006, 0.006, d);
}

void fragment() {
    vec2 p = vec2(UV.x - 0.5, 0.5 - UV.y) * vec2(1.0, 1.75);
    if (flip_horizontal) {
        p.x = -p.x;
    }

    float swing_a = sin(walk_phase) * 0.075 * moving;
    float swing_b = sin(walk_phase + 3.14159) * 0.075 * moving;

    float head = length(p - vec2(0.0, 0.55)) - 0.225;
    float body = sd_round_box(p - vec2(0.0, 0.035), vec2(0.225, 0.32), 0.10);
    float arm_a = sd_round_box(p - vec2(-0.255, swing_a * 0.35), vec2(0.085, 0.245), 0.075);
    float arm_b = sd_round_box(p - vec2(0.255, swing_b * 0.35), vec2(0.085, 0.245), 0.075);
    float leg_a = sd_round_box(p - vec2(-0.115, -0.49 + swing_a), vec2(0.085, 0.245), 0.065);
    float leg_b = sd_round_box(p - vec2(0.115, -0.49 + swing_b), vec2(0.085, 0.245), 0.065);
    float shoe_a = sd_round_box(p - vec2(-0.12, -0.765 + swing_a), vec2(0.105, 0.065), 0.045);
    float shoe_b = sd_round_box(p - vec2(0.12, -0.765 + swing_b), vec2(0.105, 0.065), 0.045);

    float d = min(head, min(body, min(arm_a, min(arm_b, min(leg_a, min(leg_b, min(shoe_a, shoe_b)))))));
    float outer = fill_shape(d);
    float inner = fill_shape(d + outline_width);

    vec3 color_value = outline_color.rgb;
    if (head < 0.0) {
        color_value = skin_color.rgb;
        if (facing == 1) {
            color_value = shirt_color.rgb * 0.65;
        }
    } else if (body < 0.0 || arm_a < 0.0 || arm_b < 0.0) {
        color_value = shirt_color.rgb;
    } else if (leg_a < 0.0 || leg_b < 0.0) {
        color_value = pants_color.rgb;
    } else if (shoe_a < 0.0 || shoe_b < 0.0) {
        color_value = shoes_color.rgb;
    }

    if (facing == 0 && head < -0.02) {
        float eye_a = length(p - vec2(-0.075, 0.57)) - 0.018;
        float eye_b = length(p - vec2(0.075, 0.57)) - 0.018;
        if (eye_a < 0.0 || eye_b < 0.0) {
            color_value = outline_color.rgb;
        }
    }

    ALBEDO = mix(outline_color.rgb, color_value, inner);
    ALPHA = outer;
}
