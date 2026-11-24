extends Node3D

## Scene kiểm thử độc lập cho module gameplay/fishing/.
## Dùng typed Resources (FishSpec, RodSpec, SpotSpec) thay vì Resource.set() tuỳ ý.
## Kiểm tra FSM, giằng co, đứt dây, trốn thoát, thu phục, độ bền trang bị, kỹ năng.

const FishingControllerScript: Script = preload("res://gameplay/fishing/fishing_controller.gd")
const FishingStateScript: Script = preload("res://gameplay/fishing/core/fishing_state.gd")
const FishSpecScript: Script = preload("res://modules/fishing/data/fish_spec.gd")
const RodSpecScript: Script = preload("res://modules/fishing/data/rod_spec.gd")
const SpotSpecScript: Script = preload("res://modules/fishing/data/spot_spec.gd")


func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ GAMEPLAY/FISHING ===")
	_run_all_tests()


func _run_all_tests() -> void:
	_test_fsm_valid_transitions()
	_test_strike_early_failure()
	_test_strike_late_escaped()
	_test_successful_catch_flow()
	_test_line_break_condition()
	_test_slack_escape_condition()
	_test_equipment_durability()
	_test_skill_effects()
	print("=== TẤT CẢ BÀI TEST GAMEPLAY/FISHING ĐỀU ĐẠT! ===")


func _create_mock_spot() -> SpotSpec:
	var spot := SpotSpec.new()
	spot.id = "spot_test"
	spot.display_name = "Điểm Thử Nghiệm"
	spot.min_wait_time = 0.1
	spot.max_wait_time = 0.2

	var fish := FishSpec.new()
	fish.id = "fish_ca_com"
	fish.display_name = "Cá Cơm"
	fish.tier = FishSpec.FishTier.PHAM_NGU
	fish.rarity = 1
	fish.strength = 20.0
	fish.pull_force = 15.0
	fish.min_weight_g = 50
	fish.max_weight_g = 120
	fish.spirit_qi = 10

	spot.fish_table = [{"fish": fish, "weight": 100}]
	return spot


func _create_mock_rod() -> RodSpec:
	var rod := RodSpec.new()
	rod.id = "rod_test"
	rod.display_name = "Cần Thử Nghiệm"
	rod.max_tension = 100.0
	rod.safe_tension_min = 30.0
	rod.safe_tension_max = 70.0
	rod.reel_speed = 50.0
	rod.release_speed = 40.0
	rod.fatigue_rate = 25.0
	rod.max_durability = 100
	rod.current_durability = 100
	rod.control_power = 1.0
	return rod


func _test_fsm_valid_transitions() -> void:
	var ctrl := FishingControllerScript.new(123)
	assert(ctrl.get_state_name() == "IDLE", "Phải khởi đầu ở IDLE")
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()

	var ok: bool = ctrl.cast(spot, rod)
	assert(ok, "Thả câu phải thành công")
	assert(ctrl.get_state_name() == "WAITING", "Sau khi cast phải là WAITING")
	print("PASS: FSM khởi đầu và thả câu.")


func _test_strike_early_failure() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	ctrl.cast(spot, rod)

	var struck: bool = ctrl.strike()
	assert(not struck, "Giật cần khi WAITING phải thất bại")
	assert(ctrl.get_state_name() == "IDLE", "Sau khi thất bại phải về IDLE")
	print("PASS: Giật cần sớm (early) thất bại chính xác.")


func _test_strike_late_escaped() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	ctrl.cast(spot, rod)

	# Chờ cá cắn câu
	ctrl.tick(0.3)
	assert(ctrl.get_state_name() == "BITE", "Cá phải cắn câu")

	# Bỏ qua không giật trong 1.5 giây (cửa sổ 0.85s)
	ctrl.tick(1.5)
	assert(ctrl.get_state_name() == "IDLE", "Cá phải trốn thoát và về IDLE")
	print("PASS: Giật cần trễ (late) cá trốn thoát chính xác.")


func _test_successful_catch_flow() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var caught_payload: Dictionary = {}
	ctrl.on_fish_caught = func(p: Dictionary) -> void: caught_payload = p

	ctrl.cast(spot, rod)
	ctrl.tick(0.3)
	assert(ctrl.get_state_name() == "BITE", "Phải ở BITE")

	var struck: bool = ctrl.strike()
	assert(struck, "Giật cần phải trúng")
	assert(ctrl.get_state_name() == "FIGHT", "Phải chuyển sang FIGHT")

	# Mô phỏng giữ dây trong vùng an toàn cho cá mệt
	for i in range(30):
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	assert(not caught_payload.is_empty(), "Phải phát payload bắt cá thành công")
	assert(caught_payload.get("fish_id") == "fish_ca_com", "Đúng loại cá đã câu")
	assert(caught_payload.has("qi_value"), "Payload phải chứa qi_value")
	print("PASS: Luồng câu cá thành công và thu hoạch phần thưởng.")


func _test_line_break_condition() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var lost_reason := ""
	ctrl.on_fish_lost = func(p: Dictionary) -> void: lost_reason = str(p.get("reason"))

	ctrl.cast(spot, rod)
	ctrl.tick(0.3)
	ctrl.strike()

	# Kéo dây liên tục với lực cực mạnh
	ctrl.reel(true)
	ctrl.set_pull_strength_factor(1.5)
	for i in range(25):
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	assert(lost_reason == "line_break", "Lý do thất bại phải là đứt dây (line_break)")
	print("PASS: Đứt dây khi lực căng vượt ngưỡng max_tension.")


func _test_slack_escape_condition() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var lost_reason := ""
	ctrl.on_fish_lost = func(p: Dictionary) -> void: lost_reason = str(p.get("reason"))

	ctrl.cast(spot, rod)
	ctrl.tick(0.3)
	ctrl.strike()

	# Xả dây liên tục khiến dây chùng quá 3.5s
	ctrl.release(true)
	for i in range(45):
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	assert(lost_reason == "slack", "Lý do thất bại phải là tuột lưỡi do chùng dây (slack)")
	print("PASS: Cá trốn thoát khi để dây quá chùng.")


func _test_equipment_durability() -> void:
	var ctrl := FishingControllerScript.new(42)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	rod.current_durability = 50

	ctrl.cast(spot, rod)
	ctrl.tick(0.3)
	ctrl.strike()

	# Giằng co vài giây rồi kiểm tra độ bền có giảm
	ctrl.reel(true)
	ctrl.tick(0.5)
	ctrl.reel(false)
	ctrl.tick(0.5)

	var line_dur: float = ctrl.battle.line_durability
	var rod_dur: float = ctrl.battle.rod_durability
	assert(line_dur < 100.0, "Độ bền dây phải giảm sau giằng co")
	assert(rod_dur < 50.0, "Độ bền cần phải giảm từ giá trị khởi tạo 50")
	print("PASS: Độ bền trang bị giảm theo diễn biến giằng co.")


func _test_skill_effects() -> void:
	var ctrl := FishingControllerScript.new(99)

	# Mở khóa kỹ năng
	ctrl.skills.unlock_skill(FishingSkill.SkillType.THINH_THUY)
	ctrl.skills.unlock_skill(FishingSkill.SkillType.NGU_CAU)
	ctrl.skills.unlock_skill(FishingSkill.SkillType.TOA_NGU)
	ctrl.skills.unlock_skill(FishingSkill.SkillType.THU_LINH)

	# Kiểm tra giá trị kỹ năng
	var bite_bonus: float = ctrl.skills.get_bite_window_bonus()
	assert(bite_bonus > 0.0, "Thính Thủy phải tăng cửa sổ giật cần")

	var safe_bonus: float = ctrl.skills.get_safe_zone_bonus()
	assert(safe_bonus > 0.0, "Ngự Câu phải mở rộng vùng an toàn")

	ctrl.skills.reset_session_skills()
	var pull_reduce: float = ctrl.skills.get_fish_pull_reduction()
	assert(pull_reduce < 1.0, "Tỏa Ngư phải giảm lực kéo cá")

	var qi_mult: float = ctrl.skills.get_qi_multiplier()
	assert(qi_mult > 1.0, "Thu Linh phải tăng linh khí nhận được")

	print("PASS: Kỹ năng câu cá có tác dụng gameplay cụ thể.")
