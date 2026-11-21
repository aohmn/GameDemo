class_name PlayerSprite
extends AnimatedSprite3D
## Hiển thị Player bằng sprite HD-2D (billboard) trong thế giới 3D.
## Chỉ lo phần hình ảnh: nhận vận tốc trên mặt phẳng, chọn hướng và animation.
## Không chứa logic gameplay (AGENTS §10). Xem docs/decisions/0001-player-sprite.md.

## Phải khớp FEET_MARGIN trong tools/build_player_atlas.py.
const FEET_MARGIN_PX: int = 6
const MOVE_THRESHOLD: float = 0.3
const REFERENCE_SPEED: float = 5.0
const AXIS_SWITCH_RATIO: float = 1.25

enum Facing { DOWN, UP, LEFT, RIGHT }

## Chiều cao nhân vật trong ảnh (px) do tools/build_player_atlas.py in ra.
@export var character_height_px: float = 120.0
@export var world_height_m: float = 1.75
## Nâng sprite lên để chân không chìm vào mặt đường. Map hiện có mặt đường cao 0.14-0.17 m
## nhưng không có collision, trong khi Player đứng ở độ cao 0. Sửa gốc ở world/map, rồi đặt về 0.
@export var ground_clearance_m: float = 0.12

var _facing: Facing = Facing.DOWN
var _moving: bool = false


func _ready() -> void:
    billboard = BaseMaterial3D.BILLBOARD_ENABLED
    texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR
    alpha_cut = SpriteBase3D.ALPHA_CUT_OPAQUE_PREPASS
    shaded = false
    centered = true
    pixel_size = world_height_m / character_height_px
    _apply_feet_offset()
    _refresh_animation()


## planar_velocity: x = trục X thế giới (phải màn hình), y = trục Z (hướng về camera).
func set_motion(planar_velocity: Vector2) -> void:
    var speed: float = planar_velocity.length()
    _moving = speed > MOVE_THRESHOLD
    if _moving:
        _facing = _pick_facing(planar_velocity)
        speed_scale = clampf(speed / REFERENCE_SPEED, 0.6, 1.4)
    else:
        speed_scale = 1.0
    _refresh_animation()


func get_facing() -> Facing:
    return _facing


func is_moving() -> bool:
    return _moving


func _apply_feet_offset() -> void:
    if sprite_frames == null or not sprite_frames.has_animation(&"idle_down"):
        push_warning("PlayerSprite: thiếu sprite_frames hoặc animation idle_down.")
        return
    var cell: Vector2 = sprite_frames.get_frame_texture(&"idle_down", 0).get_size()
    # Chân nhân vật nằm cách đáy ô FEET_MARGIN_PX, đặt chân ngay gốc node.
    offset = Vector2(0.0, cell.y * 0.5 - float(FEET_MARGIN_PX) + ground_clearance_m / pixel_size)


func _pick_facing(velocity_2d: Vector2) -> Facing:
    var horizontal: float = absf(velocity_2d.x)
    var vertical: float = absf(velocity_2d.y)
    var was_horizontal: bool = _facing == Facing.LEFT or _facing == Facing.RIGHT
    var use_horizontal: bool
    if was_horizontal:
        use_horizontal = horizontal * AXIS_SWITCH_RATIO >= vertical
    else:
        use_horizontal = horizontal > vertical * AXIS_SWITCH_RATIO
    if use_horizontal:
        return Facing.RIGHT if velocity_2d.x > 0.0 else Facing.LEFT
    return Facing.DOWN if velocity_2d.y > 0.0 else Facing.UP


func _refresh_animation() -> void:
    if sprite_frames == null:
        return
    var direction_name: String = "left"
    match _facing:
        Facing.DOWN:
            direction_name = "down"
        Facing.UP:
            direction_name = "up"
        _:
            direction_name = "left"
    var wanted: StringName = StringName(("walk_" if _moving else "idle_") + direction_name)
    if not sprite_frames.has_animation(wanted):
        push_warning("PlayerSprite: thiếu animation %s" % wanted)
        return
    flip_h = _facing == Facing.RIGHT
    if animation != wanted:
        play(wanted)
    elif not is_playing():
        play(wanted)
