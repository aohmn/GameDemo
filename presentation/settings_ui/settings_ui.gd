extends Control
## UI Cài đặt hiệu năng Android: bộ đếm FPS và 3 mức đồ họa (Thấp / Vừa / Cao).

const SAVE_PATH: String = "user://settings.cfg"
const SAVE_VERSION: int = 1

enum Quality { LOW = 0, MEDIUM = 1, HIGH = 2 }

var _quality: int = Quality.HIGH
var _show_fps: bool = false
var _fps_accum: float = 0.0
var _target_root: Node = null

var _btn_toggle: Button
var _fps_label: Label
var _panel: PanelContainer
var _btn_fps: Button
var _quality_btns: Array[Button] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_load_settings()
	_refresh_ui()
	call_deferred("apply_quality")


func set_target_root(root_node: Node) -> void:
	_target_root = root_node
	apply_quality()


func _process(delta: float) -> void:
	if not _show_fps or _fps_label == null:
		return
	_fps_accum += delta
	if _fps_accum >= 0.25:
		_fps_accum = 0.0
		_fps_label.text = "FPS: %d" % int(Engine.get_frames_per_second())


func _build_ui() -> void:
	_btn_toggle = Button.new()
	_btn_toggle.text = "Cài Đặt"
	_btn_toggle.position = Vector2(280.0, 12.0)
	_btn_toggle.custom_minimum_size = Vector2(92.0, 38.0)
	_btn_toggle.pressed.connect(_on_toggle_panel)
	add_child(_btn_toggle)

	_fps_label = Label.new()
	_fps_label.position = Vector2(382.0, 18.0)
	_fps_label.add_theme_font_size_override("font_size", 16)
	_fps_label.add_theme_color_override("font_color", Color(0.95, 0.95, 0.45))
	_fps_label.visible = false
	add_child(_fps_label)

	_panel = PanelContainer.new()
	_panel.position = Vector2(280.0, 56.0)
	_panel.custom_minimum_size = Vector2(260.0, 0.0)
	_panel.visible = false
	add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(vbox)

	var title := Label.new()
	title.text = "Cài Đặt Đồ Họa"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	_btn_fps = Button.new()
	_btn_fps.pressed.connect(_on_toggle_fps)
	vbox.add_child(_btn_fps)

	var q_label := Label.new()
	q_label.text = "Mức đồ họa:"
	vbox.add_child(q_label)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox)

	var names: Array[String] = ["Thấp", "Vừa", "Cao"]
	for i in range(3):
		var b := Button.new()
		b.text = names[i]
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var q_idx: int = i
		b.pressed.connect(func(): _set_quality(q_idx))
		hbox.add_child(b)
		_quality_btns.append(b)


func _on_toggle_panel() -> void:
	if _panel != null:
		_panel.visible = not _panel.visible


func _on_toggle_fps() -> void:
	_show_fps = not _show_fps
	_save_settings()
	_refresh_ui()


func _set_quality(q: int) -> void:
	_quality = clampi(q, Quality.LOW, Quality.HIGH)
	_save_settings()
	_refresh_ui()
	apply_quality()


func _refresh_ui() -> void:
	if _fps_label != null:
		_fps_label.visible = _show_fps
		if _show_fps:
			_fps_label.text = "FPS: %d" % int(Engine.get_frames_per_second())
	if _btn_fps != null:
		_btn_fps.text = "Hiện FPS: %s" % ("Bật" if _show_fps else "Tắt")
	for i in range(_quality_btns.size()):
		_quality_btns[i].disabled = (i == _quality)


func apply_quality() -> void:
	var root_node: Node = _target_root if _target_root != null else get_tree().current_scene
	if root_node == null:
		return
	for node in root_node.find_children("*", "", true, false):
		if node is DirectionalLight3D:
			var light := node as DirectionalLight3D
			light.shadow_enabled = (_quality != Quality.LOW)
			if _quality == Quality.MEDIUM:
				light.directional_shadow_max_distance = 35.0
			elif _quality == Quality.HIGH:
				light.directional_shadow_max_distance = 70.0
		elif node is WorldEnvironment:
			var env := (node as WorldEnvironment).environment
			if env != null:
				env.fog_enabled = (_quality != Quality.LOW)
				if _quality == Quality.MEDIUM:
					env.fog_density = 0.0018
				elif _quality == Quality.HIGH:
					env.fog_density = 0.0035
		elif node is MeshInstance3D and node.name.begins_with("MistLayer_"):
			var idx: int = int(node.name.trim_prefix("MistLayer_"))
			if _quality == Quality.LOW:
				(node as MeshInstance3D).visible = false
			elif _quality == Quality.MEDIUM:
				(node as MeshInstance3D).visible = (idx % 2 == 0)
			else:
				(node as MeshInstance3D).visible = true
		elif node is MultiMeshInstance3D:
			var mm_node := node as MultiMeshInstance3D
			if mm_node.multimesh != null:
				var total: int = mm_node.multimesh.instance_count
				if _quality == Quality.LOW:
					mm_node.multimesh.visible_instance_count = maxi(1, int(total * 0.35))
				elif _quality == Quality.MEDIUM:
					mm_node.multimesh.visible_instance_count = maxi(1, int(total * 0.65))
				else:
					mm_node.multimesh.visible_instance_count = -1


func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "version", SAVE_VERSION)
	cfg.set_value("graphics", "quality", _quality)
	cfg.set_value("graphics", "show_fps", _show_fps)
	cfg.save(SAVE_PATH)


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if int(cfg.get_value("meta", "version", 0)) != SAVE_VERSION:
		return
	_quality = clampi(int(cfg.get_value("graphics", "quality", Quality.HIGH)), Quality.LOW, Quality.HIGH)
	_show_fps = bool(cfg.get_value("graphics", "show_fps", false))
