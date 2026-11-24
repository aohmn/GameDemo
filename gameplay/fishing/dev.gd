extends Node3D

## Scene kiểm thử độc lập cho module gameplay/fishing/.
## Kiểm tra toàn diện luồng câu cá, FSM 8 trạng thái, giằng co, đứt dây, trốn thoát và thu phục.

const FishingControllerScript: Script = preload("res://gameplay/fishing/fishing_controller.gd")
const FishingStateScript: Script = preload("res://gameplay/fishing/core/fishing_state.gd")

var controller: FishingController
var test_log: Array[String] = []


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
	print("=== TẤT CẢ BÀI TEST GAMEPLAY/FISHING ĐỀU ĐẠT! ===")


func _create_mock_spot() -> Resource:
	var spot := Resource.new()
	spot.set("id", "spot_test")
	spot.set("min_wait_time", 0.1)
	spot.set("max_wait_time", 0.2)
	var fish := Resource.new()
	fish.set("id", "fish_ca_com")
	fish.set("display_name", "Cá Cơm")
	fish.set("tier", 1)
	fish.set("rarity", 1)
	fish.set("strength", 20.0)
	fish.set("pull_force", 15.0)
	fish.set("min_weight_g", 50)
	fish.set("max_weight_g", 120)
	spot.set("fish_table", [{"fish": fish, "weight": 100}])
	return spot


func _create_mock_rod() -> Resource:
	var rod := Resource.new()
	rod.set("id", "rod_test")
	rod.set("display_name", "Cần Thử Nghiệm")
	rod.set("max_tension", 100.0)
	rod.set("safe_tension_min", 30.0)
	rod.set("safe_tension_max", 70.0)
	rod.set("reel_speed", 50.0)
	rod.set("release_speed", 40.0)
	rod.set("fatigue_rate", 25.0)
	return rod


func _test_fsm_valid_transitions() -> void:
	var ctrl := FishingControllerScript.new(123)
	assert(ctrl.get_state_name() == "IDLE", "Phải khởi đầu ở IDLE")
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()

	var ok := ctrl.cast(spot, rod)
	assert(ok, "Thả câu phải thành công")
	assert(ctrl.get_state_name() == "WAITING", "Sau khi cast phải là WAITING")
	print("PASS: FSM khởi đầu và thả câu.")


func _test_strike_early_failure() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	ctrl.cast(spot, rod)

	var struck := ctrl.strike()
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
	ctrl.on_fish_caught = func(p: Dictionary): caught_payload = p

	ctrl.cast(spot, rod)
	ctrl.tick(0.3)
	assert(ctrl.get_state_name() == "BITE", "Phải ở BITE")

	var struck := ctrl.strike()
	assert(struck, "Giật cần phải trúng")
	assert(ctrl.get_state_name() == "FIGHTING", "Phải chuyển sang FIGHTING")

	# Mô phỏng giữ dây trong vùng an toàn trong vài giây cho cá mệt
	for i in range(30):
		ctrl.tick(0.1)
		if ctrl.get_state_name() == "IDLE":
			break

	assert(not caught_payload.is_empty(), "Phải phát payload bắt cá thành công")
	assert(caught_payload.get("fish_id") == "fish_ca_com", "Đúng loại cá đã câu")
	print("PASS: Luồng câu cá thành công và thu hoạch phần thưởng.")


func _test_line_break_condition() -> void:
	var ctrl := FishingControllerScript.new(123)
	var spot := _create_mock_spot()
	var rod := _create_mock_rod()
	var lost_reason := ""
	ctrl.on_fish_lost = func(p: Dictionary): lost_reason = str(p.get("reason"))

	ctrl.cast(spot, rod)
	ctrl.tick(0.3)
	ctrl.strike()

	# Kéo dây liên tục với lực cực mạnh (pull factor 1.5)
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
	ctrl.on_fish_lost = func(p: Dictionary): lost_reason = str(p.get("reason"))

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
