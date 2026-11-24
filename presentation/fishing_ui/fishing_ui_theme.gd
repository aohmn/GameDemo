class_name FishingUITheme
extends RefCounted

## Utility tạo stylebox và theme cho Fishing UI theo phong cách Genshin x Sea of Thieves.
## Tuân thủ quy chuẩn không texture, dùng hoàn toàn toán học màu và StyleBoxFlat.

static func make_box(bg: Color, bdr: Color, bw: int, r: int, px: float = 12.0, py: float = 8.0) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = bdr
	s.set_border_width_all(bw)
	s.set_corner_radius_all(r)
	s.content_margin_left = px
	s.content_margin_right = px
	s.content_margin_top = py
	s.content_margin_bottom = py
	return s


static func make_btn(txt: String, sz: Vector2, pos: Vector2, col: Color) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.custom_minimum_size = sz
	btn.position = pos
	btn.add_theme_stylebox_override("normal", make_box(col, Color(0.85, 0.70, 0.28, 0.8), 2, 8, 8.0, 6.0))
	btn.add_theme_stylebox_override("pressed", make_box(col.lightened(0.2), Color(0.95, 0.90, 0.5), 2, 8, 8.0, 6.0))
	btn.add_theme_stylebox_override("disabled", make_box(Color(0.2, 0.22, 0.25, 0.6), Color(0.4, 0.4, 0.4, 0.4), 1, 8, 8.0, 6.0))
	btn.add_theme_font_size_override("font_size", 14)
	return btn


static func build_top_panel() -> Dictionary:
	var top_panel := PanelContainer.new()
	top_panel.anchor_left = 0.5
	top_panel.anchor_right = 0.5
	top_panel.offset_left = -220.0
	top_panel.offset_top = 10.0
	top_panel.offset_right = 220.0
	top_panel.offset_bottom = 145.0
	top_panel.add_theme_stylebox_override("panel", make_box(Color(0.04, 0.12, 0.16, 0.88), Color(0.85, 0.70, 0.28, 0.85), 2, 8))

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	top_panel.add_child(vbox)

	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)

	var badge_p := PanelContainer.new()
	badge_p.add_theme_stylebox_override("panel", make_box(Color(0.12, 0.32, 0.36, 0.95), Color(0.36, 0.88, 0.82), 1, 4, 6.0, 2.0))
	top_row.add_child(badge_p)

	var badge_lbl := Label.new()
	badge_lbl.text = "SẴN SÀNG"
	badge_lbl.add_theme_font_size_override("font_size", 12)
	badge_lbl.add_theme_color_override("font_color", Color(0.95, 0.98, 0.96))
	badge_p.add_child(badge_lbl)

	var sub_lbl := Label.new()
	sub_lbl.text = "Hướng ra mặt nước để bắt đầu"
	sub_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sub_lbl.add_theme_font_size_override("font_size", 11)
	sub_lbl.add_theme_color_override("font_color", Color(0.75, 0.88, 0.88))
	top_row.add_child(sub_lbl)

	var alert_lbl := Label.new()
	alert_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	alert_lbl.add_theme_font_size_override("font_size", 12)
	alert_lbl.add_theme_color_override("font_color", Color(0.94, 0.85, 0.63))
	vbox.add_child(alert_lbl)

	var prog_bar := ProgressBar.new()
	prog_bar.max_value = 100.0
	prog_bar.show_percentage = false
	prog_bar.custom_minimum_size = Vector2(0.0, 8.0)
	prog_bar.add_theme_stylebox_override("background", make_box(Color(0.02, 0.06, 0.08, 0.8), Color.TRANSPARENT, 0, 4))
	prog_bar.add_theme_stylebox_override("fill", make_box(Color(0.18, 0.65, 0.55), Color.TRANSPARENT, 0, 4))
	vbox.add_child(prog_bar)

	var tens_bar := ProgressBar.new()
	tens_bar.max_value = 100.0
	tens_bar.value = 40.0
	tens_bar.show_percentage = false
	tens_bar.custom_minimum_size = Vector2(0.0, 10.0)
	tens_bar.add_theme_stylebox_override("background", make_box(Color(0.02, 0.06, 0.08, 0.8), Color.TRANSPARENT, 0, 4))
	tens_bar.add_theme_stylebox_override("fill", make_box(Color(0.85, 0.70, 0.28), Color.TRANSPARENT, 0, 4))
	vbox.add_child(tens_bar)

	var bot_row := HBoxContainer.new()
	vbox.add_child(bot_row)

	var tens_txt := Label.new()
	tens_txt.text = "Lực căng: 0/100"
	tens_txt.add_theme_font_size_override("font_size", 10)
	tens_txt.add_theme_color_override("font_color", Color(0.75, 0.85, 0.9))
	bot_row.add_child(tens_txt)

	var dur_lbl := Label.new()
	dur_lbl.text = "Cần: 100% | Dây: 100%"
	dur_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dur_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	dur_lbl.add_theme_font_size_override("font_size", 10)
	dur_lbl.add_theme_color_override("font_color", Color(0.65, 0.85, 0.75))
	bot_row.add_child(dur_lbl)

	return {
		"panel": top_panel,
		"badge": badge_lbl,
		"sub": sub_lbl,
		"alert": alert_lbl,
		"progress": prog_bar,
		"tension": tens_bar,
		"tension_text": tens_txt,
		"durability": dur_lbl
	}
