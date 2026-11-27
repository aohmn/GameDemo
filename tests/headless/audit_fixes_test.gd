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
	_test_reel_drag_system()
	_test_fish_ai_upgrade()
	_test_battle_skills()
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
	spec.set("max_tension_bonus", 15.0)
	var line_obj = line_script.from_resource(spec)
	_assert_true("FishingLine.from_resource giữ đúng tier", line_obj.tier == 3)
	_assert_true("FishingLine.from_resource giữ đúng max_tension_bonus = 15", is_equal_approx(line_obj.max_tension_bonus, 15.0))
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


func _test_reel_drag_system() -> void:
	var rd := preload("res://modules/fishing/gameplay/battle/reel_drag_system.gd").new()
	rd.reset(15.0)
	rd.set_drag(0.5) # brake_force = 20.0
	var slip_res: Dictionary = rd.update(false, 32.0, 35.0, 0.7, 1.0)
	_assert_true("Cá kéo vượt lực hãm -> dây bị kéo ra", float(slip_res.get("line_distance", 0.0)) > 15.0)
	var dist_before: float = float(slip_res.get("line_distance", 0.0))
	var reel_res: Dictionary = rd.update(true, 10.0, 35.0, 0.3, 1.0)
	_assert_true("Giữ thu dây khi lực kéo < lực hãm -> thu dây vào", float(reel_res.get("line_distance", 99.0)) < dist_before)
	_assert_true("Độ giãn dây > 0 khi có lực căng", float(reel_res.get("line_stretch", 0.0)) > 0.0)


func _test_fish_ai_upgrade() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	var fd := preload("res://modules/fishing/gameplay/fish/fish_data.gd").new()
	fd.strength = 40.0
	fd.stamina = 100.0
	fd.max_hp = 120.0
	var ai := preload("res://modules/fishing/gameplay/fish/fish_ai.gd").new(rng)
	var normal_res: Dictionary = ai.update_behavior(fd, 0.5, 120.0, 100.0, 50.0, 0.2)
	var tired_res: Dictionary = ai.update_behavior(fd, 0.5, 120.0, 10.0, 50.0, 0.2)
	_assert_true("Sức thấp làm cá yếu đi", float(tired_res.get("pull_force", 999.0)) < float(normal_res.get("pull_force", 0.0)))
	var ko_res: Dictionary = ai.update_behavior(fd, 0.5, 0.0, 10.0, 50.0, 0.2)
	_assert_true("HP về 0 cá mất khả năng chiến đấu", is_zero_approx(float(ko_res.get("pull_force", 1.0))) and int(ko_res.get("swim_dir", 1)) == 0)


func _test_battle_skills() -> void:
	var spec_script := preload("res://modules/fishing/gameplay/skills/battle_skill_spec.gd")
	var runner := preload("res://modules/fishing/gameplay/skills/battle_skill_runner.gd").new()

	var p_skill := spec_script.new()
	p_skill.id = "skill_toa_ngu"
	p_skill.owner_type = "player"
	p_skill.qi_cost = 25.0
	p_skill.cooldown = 5.0
	p_skill.duration = 2.0
	p_skill.effect_type = "pull_reduce"
	p_skill.effect_power = 0.4

	var r1: Dictionary = runner.try_cast(p_skill, 60.0)
	_assert_true("Kỹ năng người chơi tiêu hao linh lực", bool(r1.get("ok", false)) and is_equal_approx(float(r1.get("qi_left", 0.0)), 35.0))
	_assert_true("Kỹ năng người chơi áp dụng hiệu ứng", is_equal_approx(runner.get_effect_multiplier("pull_reduce"), 0.4))
	var r2: Dictionary = runner.try_cast(p_skill, 35.0)
	_assert_true("Kỹ năng đang hồi chiêu không thể dùng lại", not bool(r2.get("ok", true)) and str(r2.get("reason", "")) == "cooldown")

	var f_skill := spec_script.new()
	f_skill.id = "skill_ca_vay_duoi"
	f_skill.owner_type = "fish"
	f_skill.qi_cost = 30.0
	f_skill.telegraph_time = 0.5
	f_skill.effect_type = "fish_surge"
	f_skill.effect_power = 0.6
	var rf: Dictionary = runner.try_cast(f_skill, 40.0)
	_assert_true("Kỹ năng cá vào trạng thái báo trước", bool(rf.get("ok", false)) and runner.is_telegraphing())
	runner.tick(0.6)
	_assert_true("Kỹ năng cá kích hoạt sau thời gian báo trước", not runner.is_telegraphing() and is_equal_approx(runner.get_effect_multiplier("fish_surge"), 0.6))
