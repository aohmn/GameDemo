extends SceneTree
## Test: lưu trạng thái, tải lại, kiểm tra toàn bộ còn nguyên.
var main: Node = null
var sub: SubViewport
var f := 0
var passed := 0
var failed := 0
var phase := 0

func _check(label: String, got: Variant, expected: Variant) -> void:
	if str(got) == str(expected):
		passed += 1
		print("  PASS: ", label, " = ", got)
	else:
		failed += 1
		print("  FAIL: ", label, " got=", got, " expected=", expected)

const BackupHelper: Script = preload("res://tests/headless/save_backup_helper.gd")

func _initialize() -> void:
	BackupHelper.backup_user_saves()
	sub = SubViewport.new()
	sub.size = Vector2i(1280, 576)
	sub.handle_input_locally = true
	sub.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(sub)
	main = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
	sub.add_child(main)

func _physics_process(_d: float) -> bool:
	f += 1
	if main == null or not is_instance_valid(main):
		if phase == 2 and f >= 40:
			main = (load("res://scenes/boot/main.tscn") as PackedScene).instantiate()
			sub.add_child(main)
			phase = 3
		return false

	if phase == 0 and f == 5:
		print("=== SAVE ROUNDTRIP TEST ===")
		print("1. Thiết lập trạng thái ban đầu...")
		var inv: RefCounted = main.get("_inventory_api") as RefCounted
		var eco: RefCounted = main.get("_economy_api") as RefCounted
		var cult: RefCounted = main.get("_cultivation_api") as RefCounted
		inv.call("add_fish", "fish_ca_com", 150)
		inv.call("add_fish", "fish_ca_com", 160)
		inv.call("add_fish", "fish_ca_doi", 200)
		eco.call("add_funds", 500)
		cult.call("add_exp", 300, "test")
		print("  Cá cơm=", inv.call("get_fish_info", "fish_ca_com"))
		print("  Cá đối=", inv.call("get_fish_info", "fish_ca_doi"))
		print("  Số dư=", eco.call("get_balance"))
		print("  Tu vi=", cult.call("get_total_exp"))
		phase = 1

	if phase == 1 and f >= 15:
		print("2. Lưu toàn bộ...")
		var sm: RefCounted = main.get("_save_manager") as RefCounted
		if sm != null:
			sm.call("save_all")
			print("  Đã lưu qua save_manager")
		else:
			print("  FAIL: không tìm thấy _save_manager")
			failed += 1
		phase = 2

	if phase == 2 and f >= 25:
		print("3. Hủy và tải lại...")
		var old: Node = main
		main = null
		old.queue_free()

	if phase == 3 and f >= 55:
		print("4. Kiểm tra trạng thái sau khi tải:")
		var inv: RefCounted = main.get("_inventory_api") as RefCounted
		var eco: RefCounted = main.get("_economy_api") as RefCounted
		var cult: RefCounted = main.get("_cultivation_api") as RefCounted

		var ca_com: Dictionary = inv.call("get_fish_info", "fish_ca_com") as Dictionary
		var ca_doi: Dictionary = inv.call("get_fish_info", "fish_ca_doi") as Dictionary
		_check("cá cơm count", ca_com.get("count", 0), 2)
		_check("cá đối count", ca_doi.get("count", 0), 1)
		_check("số dư", eco.call("get_balance"), 500)

		var exp_val: int = int(cult.call("get_total_exp"))
		if exp_val >= 300:
			passed += 1
			print("  PASS: tu vi >= 300, got=", exp_val)
		else:
			failed += 1
			print("  FAIL: tu vi >= 300, got=", exp_val)

		print("")
		print("=== KẾT QUẢ: ", passed, " passed, ", failed, " failed ===")
		if failed == 0:
			print("SAVE ROUNDTRIP: ALL PASS")
		else:
			print("SAVE ROUNDTRIP: FAILED")
		BackupHelper.restore_user_saves()
		quit()

	return false
