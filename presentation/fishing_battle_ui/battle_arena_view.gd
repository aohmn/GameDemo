extends Control
## Vùng mô phỏng cá, cần câu cong, dây câu căng/chùng bằng vector thuần (không texture).

var fish_pos_norm: float = 0.5
var fish_depth_norm: float = 0.45
var fish_swim_dir: int = 1
var rod_steer: float = 0.0
var rod_bend: float = 0.0
var tension_ratio: float = 0.2
var line_stretch: float = 0.0
var fish_telegraphing: bool = false


func _draw() -> void:
	var w: float = size.x
	var h: float = size.y
	if w <= 1.0 or h <= 1.0:
		return
	_draw_water(w, h)
	var fish_pos: Vector2 = _draw_fish(w, h)
	var rod_tip: Vector2 = _draw_rod(w, h)
	_draw_line(rod_tip, fish_pos)


func _draw_water(w: float, h: float) -> void:
	draw_rect(Rect2(0.0, 0.0, w, h), Color(0.04, 0.10, 0.18, 0.95), true)
	draw_rect(Rect2(0.0, 0.0, w, h * 0.15), Color(0.08, 0.20, 0.30, 0.85), true)
	draw_line(Vector2(0.0, h * 0.15), Vector2(w, h * 0.15), Color(0.35, 0.65, 0.85, 0.7), 1.5)
	for i in range(4):
		var yy: float = h * (0.3 + float(i) * 0.18)
		draw_line(Vector2(0.0, yy), Vector2(w, yy), Color(0.12, 0.25, 0.35, 0.25), 1.0)


func _draw_fish(w: float, h: float) -> Vector2:
	var fx: float = clampf(fish_pos_norm, 0.08, 0.92) * w
	var fy: float = clampf(fish_depth_norm, 0.20, 0.85) * h
	var pos := Vector2(fx, fy)
	var dir_s: float = -1.0 if fish_swim_dir < 0 else 1.0
	var body_col := Color(0.25, 0.70, 0.82, 1.0)
	if fish_telegraphing:
		body_col = Color(0.95, 0.35, 0.20, 1.0)
	# Thân cá (elip dẹt)
	var body: PackedVector2Array = PackedVector2Array()
	for a in range(0, 361, 15):
		var rad: float = deg_to_rad(float(a))
		body.append(pos + Vector2(cos(rad) * 20.0 * dir_s, sin(rad) * 11.0))
	draw_colored_polygon(body, body_col)
	# Đuôi
	var tail := PackedVector2Array([
		pos + Vector2(-dir_s * 18.0, 0.0),
		pos + Vector2(-dir_s * 34.0, -12.0),
		pos + Vector2(-dir_s * 34.0, 12.0),
	])
	draw_colored_polygon(tail, body_col.darkened(0.25))
	# Vây lưng
	var fin := PackedVector2Array([
		pos + Vector2(-dir_s * 4.0, -10.0),
		pos + Vector2(dir_s * 6.0, -10.0),
		pos + Vector2(0.0, -18.0),
	])
	draw_colored_polygon(fin, body_col.darkened(0.15))
	# Mắt
	draw_circle(pos + Vector2(dir_s * 12.0, -3.0), 3.0, Color(1.0, 1.0, 1.0, 0.95))
	draw_circle(pos + Vector2(dir_s * 12.0, -3.0), 1.5, Color(0.1, 0.1, 0.1, 1.0))
	# Mũi tên hướng bơi
	if fish_swim_dir != 0:
		var a_s := pos + Vector2(dir_s * 28.0, 0.0)
		var a_e := pos + Vector2(dir_s * 48.0, 0.0)
		var arr_col := Color(1.0, 0.85, 0.3, 0.9)
		draw_line(a_s, a_e, arr_col, 2.5)
		draw_line(a_e, a_e + Vector2(-dir_s * 8.0, -5.0), arr_col, 2.5)
		draw_line(a_e, a_e + Vector2(-dir_s * 8.0, 5.0), arr_col, 2.5)
	return pos


func _draw_rod(w: float, h: float) -> Vector2:
	var base := Vector2(w * 0.5, 8.0)
	var bend_offset: float = rod_bend * h * 0.08
	var steer_x: float = rod_steer * w * 0.18
	var mid := Vector2(w * 0.5 + steer_x * 0.5, 8.0 + (h * 0.07) + bend_offset * 0.5)
	var tip := Vector2(w * 0.5 + steer_x, h * 0.14 + bend_offset)
	# Thân cần (2 đoạn Bezier đơn giản)
	var rod_col := Color(0.72, 0.52, 0.28, 1.0)
	draw_line(base, mid, rod_col, 5.0)
	draw_line(mid, tip, rod_col.lightened(0.15), 3.5)
	# Máy câu (hình tròn nhỏ)
	var reel_pos := base + Vector2(0.0, 12.0)
	draw_circle(reel_pos, 7.0, Color(0.55, 0.55, 0.60, 1.0))
	draw_circle(reel_pos, 4.0, Color(0.40, 0.40, 0.45, 1.0))
	return tip


func _draw_line(rod_tip: Vector2, fish_pos: Vector2) -> void:
	var col := Color(0.80, 0.90, 1.0, 0.85)
	var thickness: float = 1.5
	if tension_ratio > 0.85:
		col = Color(0.95, 0.20, 0.20, 1.0)
		thickness = 2.5
	elif tension_ratio > 0.6:
		col = Color(0.95, 0.70, 0.20, 1.0)
		thickness = 2.0
	elif tension_ratio < 0.15:
		col = Color(0.50, 0.65, 0.75, 0.5)
		thickness = 1.0
	# Dây cong khi chùng, thẳng khi căng
	if tension_ratio < 0.3:
		var sag: float = (0.3 - tension_ratio) * 80.0
		var mid := (rod_tip + fish_pos) * 0.5 + Vector2(0.0, sag)
		var pts: PackedVector2Array = PackedVector2Array()
		for t in range(0, 11):
			var f: float = float(t) / 10.0
			var p: Vector2 = rod_tip * (1.0 - f) * (1.0 - f) + mid * 2.0 * (1.0 - f) * f + fish_pos * f * f
			pts.append(p)
		for i in range(pts.size() - 1):
			draw_line(pts[i], pts[i + 1], col, thickness)
	else:
		draw_line(rod_tip, fish_pos, col, thickness)
