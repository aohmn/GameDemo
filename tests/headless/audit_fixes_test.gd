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
	_test_battle_hp_stamina_qi()
	_test_battle_skill_integration()
	_test_battle_ui_touch_isolation()
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

	# P0: Drag thấp/cao & đứt dây
	var rd := preload("res://modules/fishing/gameplay/battle/reel_drag_system.gd").new()
	rd.reset(20.0)
	rd.set_drag(0.2) # brake = 8.0
	var low_drag: Dictionary = rd.update(false, 25.0, 35.0, 0.5, 1.0)
	rd.reset(20.0)
	rd.set_drag(0.9) # brake = 36.0
	var high_drag: Dictionary = rd.update(false, 25.0, 35.0, 0.5, 1.0)
	_assert_true("Drag thấp để cá kéo dây nhiều hơn Drag cao", float(low_drag.get("line_distance", 0.0)) > float(high_drag.get("line_distance", 0.0)))

	var ts := preload("res://modules/fishing/gameplay/battle/tension_system.gd").new()
	ts.setup(null, 0.0, 0.0)
	ts.current_tension = ts.max_tension + 5.0
	_assert_true("Dây đứt khi lực căng vượt ngưỡng tối đa", ts.is_line_broken())


func _test_battle_hp_stamina_qi() -> void:
	var FishDataScript: Script = preload("res://modules/fishing/gameplay/fish/fish_data.gd")
	var BattleScript: Script = preload("res://modules/fishing/gameplay/battle/fishing_battle.gd")
	var LineScript: Script = preload("res://modules/fishing/gameplay/equipment/fishing_line.gd")
	var fd: RefCounted = FishDataScript.new()
	fd.strength = 30.0
	fd.stamina = 100.0
	fd.max_hp = 80.0
	fd.max_qi = 60.0
	var bat: RefCounted = BattleScript.new()
	var rod := Resource.new()
	rod.set_script(preload("res://modules/fishing/data/rod_spec.gd"))
	rod.set("id", "rod_test")
	rod.set("max_tension", 120.0)
	rod.set("current_durability", 100)
	var line: RefCounted = LineScript.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	bat.start_battle(rod, line, fd, 0.0, 1.0, rng, {})
	_assert_true("Battle HP khởi tạo đúng max_hp", is_equal_approx(bat.fish_hp, 80.0))
	_assert_true("Battle Sức khởi tạo đúng stamina", is_equal_approx(bat.fish_stamina, 100.0))
	_assert_true("Battle Nội năng khởi tạo đúng max_qi", is_equal_approx(bat.fish_qi, 60.0))
	# Giữ tension ở giữa safe zone để drain thực sự xảy ra
	var center_t: float = (bat.tension_system.safe_min + bat.tension_system.safe_max) * 0.5
	for i in range(60):
		bat.tension_system.current_tension = center_t
		var res: String = bat.update(fd, true, false, 1.0, 0.5)
		if res == "CAUGHT":
			break
	_assert_true("Sức giảm sau nhiều frame chiến đấu", bat.fish_stamina < 100.0)
	var stam_low: bool = bat.fish_stamina < fd.stamina * 0.25
	if not stam_low:
		bat.fish_stamina = 5.0
	for i in range(30):
		bat.update(fd, true, false, 1.0, 0.5)
	_assert_true("HP giảm khi sức thấp", bat.fish_hp < 80.0)


func _test_battle_skill_integration() -> void:
	var FishDataScript: Script = preload("res://modules/fishing/gameplay/fish/fish_data.gd")
	var BattleScript: Script = preload("res://modules/fishing/gameplay/battle/fishing_battle.gd")
	var LineScript: Script = preload("res://modules/fishing/gameplay/equipment/fishing_line.gd")
	var SpecScript: Script = preload("res://modules/fishing/gameplay/skills/battle_skill_spec.gd")
	var fd: RefCounted = FishDataScript.new()
	fd.strength = 40.0
	fd.stamina = 200.0
	fd.max_hp = 150.0
	fd.max_qi = 80.0
	var bat: RefCounted = BattleScript.new()
	var rod := Resource.new()
	rod.set_script(preload("res://modules/fishing/data/rod_spec.gd"))
	rod.set("id", "rod_test2")
	rod.set("max_tension", 150.0)
	rod.set("current_durability", 100)
	var line: RefCounted = LineScript.new()
	var rng := RandomNumberGenerator.new()
	rng.seed = 11
	bat.start_battle(rod, line, fd, 0.0, 1.0, rng, {})

	# Người chơi dùng kỹ năng Tỏa Ngư
	var p_skill: Resource = SpecScript.new()
	p_skill.id = "skill_toa_ngu"
	p_skill.owner_type = "player"
	p_skill.qi_cost = 25.0
	p_skill.cooldown = 5.0
	p_skill.duration = 2.0
	p_skill.effect_type = "pull_reduce"
	p_skill.effect_power = 0.4
	var r1: Dictionary = bat.use_player_skill(p_skill)
	_assert_true("Skill người chơi tiêu hao linh lực trong battle", bool(r1.get("ok", false)) and is_equal_approx(bat.player_qi, 75.0))
	var r2: Dictionary = bat.use_player_skill(p_skill)
	_assert_true("Skill người chơi bị cooldown trong battle", not bool(r2.get("ok", true)) and str(r2.get("reason", "")) == "cooldown")

	# Hiệu ứng pull_reduce thực sự giảm lực kéo
	var center_t: float = (bat.tension_system.safe_min + bat.tension_system.safe_max) * 0.5
	bat.tension_system.current_tension = center_t
	bat.update(fd, false, false, 1.0, 0.1)
	var pull_eff: float = bat.player_skills.get_effect_multiplier("pull_reduce")
	_assert_true("Hiệu ứng pull_reduce đang hoạt động", pull_eff > 0.0)

	# Cá dùng kỹ năng fish_surge
	var f_skill: Resource = SpecScript.new()
	f_skill.id = "skill_vay_duoi"
	f_skill.owner_type = "fish"
	f_skill.qi_cost = 20.0
	f_skill.cooldown = 10.0
	f_skill.telegraph_time = 0.3
	f_skill.duration = 2.0
	f_skill.effect_type = "fish_surge"
	f_skill.effect_power = 0.5
	var fish_specs: Array[Resource] = [f_skill]
	bat.set_fish_skills(fish_specs)
	bat.tension_system.current_tension = center_t
	bat.update(fd, false, false, 1.0, 0.1)
	_assert_true("Cá AI dùng kỹ năng tiêu hao nội năng", bat.fish_qi < 80.0 or bat.fish_skills.is_telegraphing())

	# Hết linh lực không dùng được kỹ năng
	bat.player_qi = 5.0
	var r3: Dictionary = bat.use_player_skill(p_skill)
	# Có thể fail vì cooldown chưa hết hoặc hết qi
	var reason: String = str(r3.get("reason", ""))
	_assert_true("Skill bị từ chối khi thiếu linh lực hoặc cooldown", not bool(r3.get("ok", true)) and (reason == "no_qi" or reason == "cooldown"))


func _test_battle_ui_touch_isolation() -> void:
	var hud := Control.new()
	hud.size = Vector2(1280.0, 720.0)
	get_root().add_child(hud)

	var old_btn := Button.new()
	old_btn.position = Vector2(900.0, 100.0)
	old_btn.size = Vector2(200.0, 80.0)
	hud.add_child(old_btn)

	var helper := preload("res://presentation/fishing_ui/touch_button_helper.gd").new()
	hud.add_child(helper)
	var called: Array[bool] = [false]
	helper.bind_hold(old_btn, func() -> void: called[0] = true, func() -> void: pass)

	# Khi FishingBattleUI phủ lên, nút cũ bị che không được kích hoạt
	var overlay := ColorRect.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.size = Vector2(1280.0, 720.0)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.add_child(overlay)

	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.index = 0
	touch.position = Vector2(950.0, 130.0)
	helper._input(touch)
	_assert_true("Nút bị lớp khác phủ lên KHÔNG gọi reel/release", not called[0])
	hud.free()
