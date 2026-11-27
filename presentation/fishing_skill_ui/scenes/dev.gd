extends Control

const SKILL_UI_PATH: String = "res://presentation/fishing_skill_ui/fishing_skill_ui.tscn"
const FISHING_API_PATH: String = "res://modules/fishing/api/fishing_api.gd"

var _fishing_api: RefCounted
var _ui: Control


func _ready() -> void:
	if ResourceLoader.exists(FISHING_API_PATH):
		var s: Script = load(FISHING_API_PATH) as Script
		if s != null:
			_fishing_api = s.new() as RefCounted
			_fishing_api.call("set_realm_provider", func() -> int: return 2)
	if ResourceLoader.exists(SKILL_UI_PATH):
		var scene := load(SKILL_UI_PATH) as PackedScene
		if scene != null:
			_ui = scene.instantiate() as Control
			add_child(_ui)
			_ui.call("setup", _fishing_api)
			_ui.call("set_open", true)
