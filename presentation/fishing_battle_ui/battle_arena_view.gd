extends Control
## Hiển thị vùng nước, cá, hướng bơi, cần câu và dây câu bằng vector thuần.

var fish_pos_norm: float = 0.5 # 0.0 (trái) -> 1.0 (phải)
var fish_depth_norm: float = 0.45 # 0.2 (gần mặt nước) -> 0.85 (đáy)
var fish_swim_dir: int = 1 # -1: trái, 0: đứng yên, 1: phải
var rod_steer: float = 0.0 # -1.0 (trái) -> 1.0 (phải)
var tension_ratio: float = 0.2 # 0.0 -> 1.0


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 1.0 or h <= 1.0:
		return

	# Vùng nước
	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.05, 0.14, 0.22, 0.92), true)
	draw_rect(Rect2(0.0, 0.0, w, h * 0.18), Color(0.10, 0.26, 0.38, 0.85), true)
	draw_line(Vector2(0.0, h * 0.18), Vector2(w, h * 0.18), Color(0.45, 0.78, 0.95, 0.8), 2.0)

	# Cần câu (ở phía trên giữa, nghiêng theo rod_steer)
	var rod_base := Vector2(w * 0.5, 16.0)
	var rod_tip := Vector2(w * 0.5 + rod_steer * (w * 0.16), h * 0.16)
	draw_line(rod_base, rod_tip, Color(0.76, 0.58, 0.32, 1.0), 5.0)

	# Vị trí cá trong vùng nước
	var fx: float = clampf(fish_pos_norm, 0.08, 0.92) * w
	var fy: float = clampf(fish_depth_norm, 0.25, 0.85) * h
	var fish_pos := Vector2(fx, fy)

	# Dây câu nối đầu cần tới cá (màu theo lực căng)
	var line_col := Color(0.85, 0.95, 1.0, 0.9)
	if tension_ratio > 0.8:
		line_col = Color(0.95, 0.25, 0.25, 1.0)
	elif tension_ratio > 0.55:
		line_col = Color(0.95, 0.75, 0.25, 1.0)
	draw_line(rod_tip, fish_pos, line_col, 2.0)

	# Thân cá & đuôi
	var dir_sign: float = -1.0 if fish_swim_dir < 0 else 1.0
	draw_circle(fish_pos, 16.0, Color(0.28, 0.76, 0.88, 1.0))
	var tail := PackedVector2Array([
		fish_pos + Vector2(-dir_sign * 14.0, 0.0),
		fish_pos + Vector2(-dir_sign * 28.0, -10.0),
		fish_pos + Vector2(-dir_sign * 28.0, 10.0),
	])
	draw_colored_polygon(tail, Color(0.18, 0.58, 0.72, 1.0))

	# Mũi tên hướng bơi của cá
	if fish_swim_dir != 0:
		var arrow_start := fish_pos + Vector2(dir_sign * 22.0, 0.0)
		var arrow_end := fish_pos + Vector2(dir_sign * 44.0, 0.0)
		draw_line(arrow_start, arrow_end, Color(1.0, 0.85, 0.3, 1.0), 3.0)
		draw_line(arrow_end, arrow_end + Vector2(-dir_sign * 8.0, -6.0), Color(1.0, 0.85, 0.3, 1.0), 3.0)
		draw_line(arrow_end, arrow_end + Vector2(-dir_sign * 8.0, 6.0), Color(1.0, 0.85, 0.3, 1.0), 3.0)
