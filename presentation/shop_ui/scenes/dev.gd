extends Control

## Scene dev kiểm thử độc lập cho Shop UI (không preload chéo module).

const SHOP_UI_PATH: String = "res://presentation/shop_ui/shop_ui.tscn"
const SHOP_API_PATH: String = "res://modules/shop/api/shop_api.gd"
const ECONOMY_API_PATH: String = "res://modules/economy/api/economy_api.gd"
const CULTIVATION_API_PATH: String = "res://modules/cultivation/api/cultivation_api.gd"

var _shop_api: RefCounted
var _economy_api: RefCounted
var _cultivation_api: RefCounted
var _shop_ui: Control


func _ready() -> void:
	_shop_api = _load_new(SHOP_API_PATH)
	_economy_api = _load_new(ECONOMY_API_PATH)
	_cultivation_api = _load_new(CULTIVATION_API_PATH)
	if _economy_api != null:
		_economy_api.call("add_funds", 2000, "dev_seed")

	if ResourceLoader.exists(SHOP_UI_PATH):
		var scene := load(SHOP_UI_PATH) as PackedScene
		if scene != null:
			_shop_ui = scene.instantiate() as Control
			add_child(_shop_ui)
			_shop_ui.call("setup", _shop_api, _economy_api, _cultivation_api)
			_shop_ui.call("set_near_shop", true)
			_shop_ui.call("set_open", true)


func _load_new(path: String) -> RefCounted:
	if not ResourceLoader.exists(path):
		return null
	var s: Script = load(path) as Script
	return s.new() as RefCounted if s != null else null
