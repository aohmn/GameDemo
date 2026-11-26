extends Node3D

## Scene kiểm thử độc lập cho module modules/fishing/gameplay/.
## Kiểm tra FSM, giằng co, đứt dây, trốn thoát, thu phục, độ bền, kỹ năng, luật phẩm cấp.

const FishingControllerScript: Script = preload("res://modules/fishing/gameplay/fishing_controller.gd")
const FishingStateScript: Script = preload("res://modules/fishing/gameplay/core/fishing_state.gd")
const FishSpecScript: Script = preload("res://modules/fishing/data/fish_spec.gd")
const RodSpecScript: Script = preload("res://modules/fishing/data/rod_spec.gd")
const SpotSpecScript: Script = preload("res://modules/fishing/data/spot_spec.gd")

func _ready() -> void:
	print("=== BẮT ĐẦU KIỂM THỬ GAMEPLAY/FISHING ===")
	_run_all_tests()

var _failures: int = 0

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures += 1
		push_error("FAIL: " + message)

func _run_all_tests() -> void:
	_test_fsm_valid_transitions()
	_test_strike_early_failure()
	_test_strike_late_escaped()
	_test_successful_catch_flow()
	_test_line_break_condition()
	_test_slack_escape_condition()
	_test_equipment_durability()
	_test_skill_effects()
	_test_tier_gating()
	_test_no_fish_for_weak_rod()
	if _failures == 0:
		print("=== TẤT CẢ BÀI TEST GAMEPLAY/FISHING ĐỀU ĐẠT! ===")
	else:
		print("=== CÓ %d KIỂM TRA THẤT BẠI ===" % _failures)

## Chờ cá cắn câu (thời gian chờ có sàn 0,8 s nên không thể tick cố định).
func _wait_for_bite(ctrl: FishingController) -> void:
	for i in range(200):
		if ctrl.get_state_name() == "BITE":
			return
		ctrl.tick(0.1)

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
	var ctrl: FishingController = FishingControllerScript.new(123)
	_check(ctrl.get_state_name() == "IDLE", "Phải khởi đầu ở IDLE")
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()

	var ok: bool = ctrl.cast(spot, rod)
	_check(ok, "Thả câu phải thành công")
	_check(ctrl.get_state_name() == "WAITING", "Sau khi cast phải là WAITING")
	print("PASS: FSM khởi đầu và thả câu.")

func _test_strike_early_failure() -> void:
	var ctrl: FishingController = FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	ctrl.cast(spot, rod)

	var struck: bool = ctrl.strike()
	_check(not struck, "Giật cần khi WAITING phải thất bại")
	_check(ctrl.get_state_name() == "IDLE", "Sau khi thất bại phải về IDLE")
	print("PASS: Giật cần sớm (early) thất bại chính xác.")

func _test_strike_late_escaped() -> void:
	var ctrl: FishingController = FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	ctrl.cast(spot, rod)

	_wait_for_bite(ctrl)
	_check(ctrl.get_state_name() == "BITE", "Cá phải cắn câu")

	# Bỏ qua không giật trong 1.5 giây (cửa sổ 0.85s)
	ctrl.tick(1.5)
	_check(ctrl.get_state_name() == "IDLE", "Cá phải trốn thoát và về IDLE")
	print("PASS: Giật cần trễ (late) cá trốn thoát chính xác.")

func _test_successful_catch_flow() -> void:
	var ctrl: FishingController = FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var rec: Dictionary = {"caught": {}}
	ctrl.on_fish_caught = func(p: Dictionary) -> void: rec["caught"] = p

	ctrl.cast(spot, rod)
	_wait_for_bite(ctrl)
	_check(ctrl.get_state_name() == "BITE", "Phải ở BITE")

	var struck: bool = ctrl.strike()
	_check(struck, "Giật cần phải trúng")
	_check(ctrl.get_state_name() == "FIGHT", "Phải chuyển sang FIGHT")

	# Mô phỏng giữ dây trong vùng an toàn cho cá mệt
	# (bot giữ lực căng trong vùng an toàn: kéo khi dưới ngưỡng giữa, xả khi trên)
	for i in range(300):
		var mid: float = (ctrl.battle.tension_system.safe_min + ctrl.battle.tension_system.safe_max) * 0.5
		ctrl.reel(ctrl.battle.tension_system.current_tension < mid)
		ctrl.release(ctrl.battle.tension_system.current_tension > mid + 8.0)
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	var caught_payload: Dictionary = rec["caught"]
	_check(not caught_payload.is_empty(), "Phải phát payload bắt cá thành công")
	_check(caught_payload.get("fish_id") == "fish_ca_com", "Đúng loại cá đã câu")
	_check(caught_payload.has("qi_value"), "Payload phải chứa qi_value")
	print("PASS: Luồng câu cá thành công và thu hoạch phần thưởng.")

func _test_line_break_condition() -> void:
	var ctrl: FishingController = FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var rec: Dictionary = {"reason": ""}
	ctrl.on_fish_lost = func(p: Dictionary) -> void: rec["reason"] = str(p.get("reason"))

	ctrl.cast(spot, rod)
	_wait_for_bite(ctrl)
	ctrl.strike()

	# Kéo dây liên tục với lực cực mạnh
	ctrl.reel(true)
	ctrl.set_pull_strength_factor(1.5)
	for i in range(25):
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	_check(rec["reason"] == "line_break", "Lý do thất bại phải là đứt dây (line_break)")
	print("PASS: Đứt dây khi lực căng vượt ngưỡng max_tension.")

func _test_slack_escape_condition() -> void:
	var ctrl: FishingController = FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var rec: Dictionary = {"reason": ""}
	ctrl.on_fish_lost = func(p: Dictionary) -> void: rec["reason"] = str(p.get("reason"))

	ctrl.cast(spot, rod)
	_wait_for_bite(ctrl)
	ctrl.strike()

	# Xả dây liên tục khiến dây chùng quá 3.5s
	ctrl.release(true)
	for i in range(100):
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	_check(rec["reason"] == "slack", "Lý do thất bại phải là tuột lưỡi do chùng dây (slack)")
	print("PASS: Cá trốn thoát khi để dây quá chùng.")

func _test_equipment_durability() -> void:
	var ctrl: FishingController = FishingControllerScript.new(42)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	rod.current_durability = 50

	ctrl.cast(spot, rod)
	_wait_for_bite(ctrl)
	ctrl.strike()

	# Giằng co vài giây rồi kiểm tra độ bền có giảm
	ctrl.reel(true)
	ctrl.tick(0.5)
	ctrl.reel(false)
	ctrl.tick(0.5)

	var line_dur: float = ctrl.battle.line_durability
	var rod_dur: float = ctrl.battle.rod_durability
	_check(line_dur < 100.0, "Độ bền dây phải giảm sau giằng co")
	_check(rod_dur < 50.0, "Độ bền cần phải giảm từ giá trị khởi tạo 50")
	print("PASS: Độ bền trang bị giảm theo diễn biến giằng co.")

func _test_skill_effects() -> void:
	var ctrl: FishingController = FishingControllerScript.new(99)

	# Mở khóa kỹ năng
	ctrl.skills.unlock_skill(FishingSkill.SkillType.THINH_THUY)
	ctrl.skills.unlock_skill(FishingSkill.SkillType.NGU_CAU)
	ctrl.skills.unlock_skill(FishingSkill.SkillType.TOA_NGU)
	ctrl.skills.unlock_skill(FishingSkill.SkillType.THU_LINH)

	# Kiểm tra giá trị kỹ năng
	var bite_bonus: float = ctrl.skills.get_bite_window_bonus()
	_check(bite_bonus > 0.0, "Thính Thủy phải tăng cửa sổ giật cần")

	var safe_bonus: float = ctrl.skills.get_safe_zone_bonus()
	_check(safe_bonus > 0.0, "Ngự Câu phải mở rộng vùng an toàn")

	ctrl.skills.reset_session_skills()
	var pull_reduce: float = ctrl.skills.get_fish_pull_reduction()
	_check(pull_reduce < 1.0, "Tỏa Ngư phải giảm lực kéo cá")

	var qi_mult: float = ctrl.skills.get_qi_multiplier()
	_check(qi_mult > 1.0, "Thu Linh phải tăng linh khí nhận được")

	print("PASS: Kỹ năng câu cá có tác dụng gameplay cụ thể.")

func _make_fish(fish_id: String, tier: int) -> FishSpec:
	var fish := FishSpec.new()
	fish.id = fish_id
	fish.tier = tier as FishSpec.FishTier
	fish.strength = 20.0
	return fish

func _spot_with(fishes: Array) -> SpotSpec:
	var spot := SpotSpec.new()
	spot.id = "spot_tier_test"
	spot.min_wait_time = 0.1
	spot.max_wait_time = 0.2
	for f in fishes:
		spot.fish_table.append({"fish": f, "weight": 100})
	return spot

func _test_tier_gating() -> void:
	var spot := _spot_with([_make_fish("fish_pham", 0), _make_fish("fish_tien", 3)])
	var weak_rod := _create_mock_rod()          # phẩm 0 -> chỉ câu được cá phẩm <= 1
	var strong_rod := _create_mock_rod()
	strong_rod.tier = 3 as RodSpec.ArtifactTier # câu được cá phẩm <= 4
	var weak_got_high: bool = false
	var strong_got_high: bool = false
	for seed_val in range(40):
		var c1: FishingController = FishingControllerScript.new(seed_val)
		c1.cast(spot, weak_rod)
		if c1.current_fish != null and c1.current_fish.id == "fish_tien":
			weak_got_high = true
		var c2: FishingController = FishingControllerScript.new(seed_val)
		c2.cast(spot, strong_rod)
		if c2.current_fish != null and c2.current_fish.id == "fish_tien":
			strong_got_high = true
	_check(not weak_got_high, "Cần phẩm thấp không được câu cá Tiên ngư")
	_check(strong_got_high, "Cần phẩm cao phải câu được cá Tiên ngư")
	print("PASS: Luật phẩm cấp cần câu và cá.")

func _test_no_fish_for_weak_rod() -> void:
	var spot := _spot_with([_make_fish("fish_than", 4)])
	var ctrl: FishingController = FishingControllerScript.new(1)
	var ok: bool = ctrl.cast(spot, _create_mock_rod())
	_check(not ok, "Không có cá hợp phẩm cấp thì không được thả cần")
	_check(ctrl.get_state_name() == "IDLE", "Thả cần bị từ chối phải giữ IDLE")
	print("PASS: Điểm câu chỉ có cá quá phẩm cấp thì từ chối thả cần.")
