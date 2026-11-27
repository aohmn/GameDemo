extends SceneTree
## Kiểm thử xác minh các lỗi đã sửa trong đợt Fix Bug.

var _passed: int = 0
var _failed: int = 0


func _assert_true(label: String, cond: bool) -> void:
	if cond:
		_passed += 1
		print("  PASS: ", label)
	else:
		_failed += 1
		print("  FAIL: ", label)


func _initialize() -> void:
	print("=== AUDIT FIXES TEST ===")
	_test_fishing_data_and_spawner()
	_test_equipment_slot_type()
	_test_crafting_active_save()
	_test_map_manager_lock()
	_test_fishing_line_and_durability()
	print("=== KẾT QUẢ: %d passed, %d failed ===" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _test_fishing_data_and_spawner() -> void:
	var fd := preload("res://modules/fishing/gameplay/core/fishing_data.gd").new()
	_assert_true("FishingData có rod_resource", "rod_resource" in fd)

	var spawner := preload("res://modules/fishing/gameplay/fish/fish_spawner.gd")
	var spot_res: Resource = Resource.new()
	spot_res.set_script(preload("res://modules/fishing/data/spot_spec.gd"))
	spot_res.set("water_type", "ho")

	var fish_sea: Resource = Resource.new()
	fish_sea.set_script(preload("res://modules/fishing/data/fish_spec.gd"))
	fish_sea.set("id", "test_sea")
	fish_sea.set("habitat_water_type", "bien")
	fish_sea.set("tier", 0)

	spot_res.set("fish_table", [{"fish": fish_sea, "weight": 100}])
	var rng := RandomNumberGenerator.new()
	var picked: Resource = spawner.spawn_fish_for_spot(spot_res, 0, rng, 99, "ngay", "nang")
	_assert_true("FishSpawner lọc bỏ cá khác habitat_water_type", picked == null)


func _test_equipment_slot_type() -> void:
	var eq := preload("res://modules/equipment/logic/equipment_logic.gd").new()
	var bait := Resource.new()
	bait.set_script(preload("res://modules/equipment/data/equipment_item_spec.gd"))
	bait.set("id", "test_bait")
	bait.set("slot_type", "bait")
	eq.register_item_spec(bait)
	_assert_true("Equipment từ chối lắp bait vào slot rod", not eq.equip_item("rod", "test_bait", 5))
	_assert_true("Equipment cho phép lắp bait vào slot bait", eq.equip_item("bait", "test_bait", 5))


func _test_crafting_active_save() -> void:
	var craft := preload("res://modules/crafting/logic/crafting_logic.gd").new()
	var rec := Resource.new()
	rec.set_script(preload("res://modules/crafting/data/recipe_spec.gd"))
	rec.set("id", "test_timed")
	rec.set("craft_duration", 10.0)
	rec.set("output_item_id", "rod_truc_nhiem")
	rec.set("output_count", 1)
	craft.register_recipe(rec)
	var start_res: Dictionary = craft.start_craft("test_timed", 0)
	_assert_true("Crafting bắt đầu chế tạo theo thời gian", bool(start_res.get("success", false)) and not bool(start_res.get("completed_now", true)))
	var tmp_path: String = "user://test_crafting_audit.cfg"
	_assert_true("Crafting lưu được tiến trình", craft.save_to_disk(tmp_path))

	var craft2 := preload("res://modules/crafting/logic/crafting_logic.gd").new()
	_assert_true("Crafting tải lại được tiến trình", craft2.load_from_disk(tmp_path))
	var info: Dictionary = craft2.get_active_craft_info()
	_assert_true("Crafting khôi phục đúng recipe_id đang chạy", str(info.get("recipe_id", "")) == "test_timed")


func _test_map_manager_lock() -> void:
	var mm := preload("res://scenes/boot/map_manager.gd").new()
	var mdef := Resource.new()
	mdef.set_script(preload("res://core/contracts/map_definition.gd"))
	mdef.set("id", "locked_map")
	mdef.set("scene_path", "res://maps/harbor_island/map.tscn")
	mdef.set("is_unlocked_by_default", false)
	mdef.set("required_realm_level", 3)
	mm.register_map_definition(mdef)
	_assert_true("MapManager chặn chuyển map khi chưa mở khóa / thiếu cảnh giới", not mm.load_map("locked_map", 0))
	mm.free()


func _test_fishing_line_and_durability() -> void:
	var line_script := preload("res://modules/fishing/gameplay/equipment/fishing_line.gd")
	var spec := Resource.new()
	spec.set_script(preload("res://modules/equipment/data/equipment_item_spec.gd"))
	spec.set("id", "line_vip_001")
	spec.set("display_name", "Dây Huyền Thiết")
	spec.set("slot_type", "line")
	spec.set("tier", 3)
	spec.set("durability", 40.0)
	var line_obj = line_script.from_resource(spec)
	_assert_true("FishingLine.from_resource giữ đúng tier", line_obj.tier == 3)
	_assert_true("FishingLine.from_resource giữ đúng độ bền 40", is_equal_approx(line_obj.current_durability, 40.0))

	var eq := preload("res://modules/equipment/logic/equipment_logic.gd").new()
	eq.register_item_spec(spec)
	eq.equip_item("line", "line_vip_001", 5)
	eq.consume_durability("line", 12.5)
	_assert_true("EquipmentLogic giảm độ bền đúng lượng", is_equal_approx(eq.get_item_durability("line_vip_001"), 27.5))
	var eq_path: String = "user://test_eq_line_durability.cfg"
	_assert_true("EquipmentLogic lưu được độ bền", eq.save_to_disk(eq_path))
	var eq2 := preload("res://modules/equipment/logic/equipment_logic.gd").new()
	eq2.register_item_spec(spec)
	_assert_true("EquipmentLogic tải lại giữ đúng độ bền", eq2.load_from_disk(eq_path) and is_equal_approx(eq2.get_item_durability("line_vip_001"), 27.5))
