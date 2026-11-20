extends Control

var _direction := Vector2.ZERO
var _touch_index := -1


func _ready() -> void:
    queue_redraw()


func get_direction() -> Vector2:
    return _direction


func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch

        if touch.pressed:
            if _touch_index == -1 and get_global_rect().has_point(
                touch.position
            ):
                _touch_index = touch.index
                _update_direction(touch.position)
                accept_event()
        elif touch.index == _touch_index:
            _touch_index = -1
            _direction = Vector2.ZERO
            queue_redraw()
            accept_event()

    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag

        if drag.index == _touch_index:
            _update_direction(drag.position)
            accept_event()


func _update_direction(screen_position: Vector2) -> void:
    var local_position := (
        get_global_transform_with_canvas().affine_inverse()
        * screen_position
    )

    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.42
    var offset := local_position - center

    if radius > 0.0:
        _direction = offset.limit_length(radius) / radius

    queue_redraw()


func _draw() -> void:
    var center := size * 0.5
    var radius := minf(size.x, size.y) * 0.42

    draw_circle(
        center,
        radius,
        Color(0.04, 0.06, 0.07, 0.38)
    )

    draw_arc(
        center,
        radius,
        0.0,
        TAU,
        48,
        Color(0.85, 0.88, 0.84, 0.65),
        3.0,
        true
    )

    draw_circle(
        center + _direction * radius * 0.58,
        radius * 0.30,
        Color(0.88, 0.90, 0.86, 0.72)
    )
