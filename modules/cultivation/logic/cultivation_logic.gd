class_name CultivationLogic
extends RefCounted

## Logic quản lý tu vi, cấp bậc cảnh giới và cơ chế đột phá (modules/cultivation/).
## Lưu trữ trạng thái tu vi vào user://cultivation.cfg bằng ConfigFile.

const SAVE_PATH: String = "user://cultivation.cfg"
const SECTION_CULTIVATION: String = "cultivation"
const SECTION_META: String = "meta"
const SAVE_VERSION: int = 1

var _current_realm_index: int = 0      # 0: Luyện Thể -> 11: Chân Tiên
var _current_layer: int = 1            # 1 đến 9
var _current_layer_exp: int = 0        # Tu vi tích lũy trong tầng hiện tại
var _total_exp: int = 0                # Tổng tu vi từ trước đến nay

var _realms: Array[Resource] = []      # Danh sách RealmSpec sắp xếp theo realm_index

var on_exp_gained: Callable
var on_layer_upgraded: Callable
var on_breakthrough_success: Callable
var on_breakthrough_failed: Callable


func _init() -> void:
	_load_default_realms()


func _load_default_realms() -> void:
	var realm_files: Array[String] = [
		"res://modules/cultivation/data/resources/realm_luyen_the.tres",
		"res://modules/cultivation/data/resources/realm_tu_khi.tres",
		"res://modules/cultivation/data/resources/realm_khai_mach.tres",
		"res://modules/cultivation/data/resources/realm_truc_co.tres",
		"res://modules/cultivation/data/resources/realm_kim_dan.tres",
		"res://modules/cultivation/data/resources/realm_nguyen_anh.tres",
		"res://modules/cultivation/data/resources/realm_hoa_than.tres",
		"res://modules/cultivation/data/resources/realm_luyen_hu.tres",
		"res://modules/cultivation/data/resources/realm_hop_the.tres",
		"res://modules/cultivation/data/resources/realm_dai_thua.tres",
		"res://modules/cultivation/data/resources/realm_do_kiep.tres",
		"res://modules/cultivation/data/resources/realm_chan_tien.tres",
	]
	_realms.clear()
	for p in realm_files:
		if ResourceLoader.exists(p):
			var r: Resource = load(p) as Resource
			if r != null:
				_realms.append(r)


func get_current_realm_index() -> int:
	return _current_realm_index


func get_current_layer() -> int:
	return _current_layer


func get_current_layer_exp() -> int:
	return _current_layer_exp


func get_total_exp() -> int:
	return _total_exp


func get_current_realm_spec() -> Resource:
	if _current_realm_index >= 0 and _current_realm_index < _realms.size():
		return _realms[_current_realm_index]
	return null


func get_realm_spec_by_index(idx: int) -> Resource:
	if idx >= 0 and idx < _realms.size():
		return _realms[idx]
	return null


func get_current_realm_name() -> String:
	var r: Resource = get_current_realm_spec()
	return str(r.get("display_name")) if r != null else ""


## Tu vi cần để lên tầng tiếp theo (hoặc đạt ngưỡng đột phá nếu đang ở tầng 9).
func get_required_layer_exp() -> int:
	var r: Resource = get_current_realm_spec()
	if r == null:
		return 999999999
	var reqs: Array = r.get("layer_exp_requirements") as Array
	var idx: int = _current_layer - 1
	if idx >= 0 and idx < reqs.size():
		return int(reqs[idx])
	return 999999999


## Kiểm tra xem có đang ở đỉnh phong (tầng 9 và đã đầy tu vi tầng 9) hay không.
func is_at_peak_layer() -> bool:
	return _current_layer >= 9 and _current_layer_exp >= get_required_layer_exp()


## Kiểm tra điều kiện đột phá lên đại cảnh giới tiếp theo.
func can_breakthrough() -> bool:
	if _current_realm_index >= _realms.size() - 1:
		return false # Đã đạt Chân Tiên đỉnh phong, cảnh giới cao nhất
	return is_at_peak_layer()


## Nhận tu vi (từ câu cá, luyện hóa linh đan...).
func add_exp(amount: int, reason: String = "absorb") -> void:
	if amount <= 0:
		return
	_total_exp += amount
	_current_layer_exp += amount

	# Tự động lên tầng nếu không phải đang ở ngưỡng đột phá tầng 9
	while _current_layer < 9 and _current_layer_exp >= get_required_layer_exp():
		var req: int = get_required_layer_exp()
		_current_layer_exp -= req
		var old_l: int = _current_layer
		_current_layer += 1
		if on_layer_upgraded.is_valid():
			on_layer_upgraded.call({
				"realm_index": _current_realm_index,
				"realm_name": get_current_realm_name(),
				"old_layer": old_l,
				"new_layer": _current_layer
			})

	# Nếu đã ở tầng 9, tu vi tích lũy tối đa dừng ở ngưỡng required để chờ đột phá
	if _current_layer >= 9:
		var req_peak: int = get_required_layer_exp()
		_current_layer_exp = mini(_current_layer_exp, req_peak)

	if on_exp_gained.is_valid():
		on_exp_gained.call({
			"amount_change": amount,
			"current_exp": _current_layer_exp,
			"total_exp": _total_exp,
			"reason": reason
		})


## Thực hiện đột phá đại cảnh giới.
func breakthrough() -> Dictionary:
	if not can_breakthrough():
		var fail_reason: String = "Chưa đạt điều kiện đột phá"
		if _current_realm_index >= _realms.size() - 1:
			fail_reason = "Đã đạt cảnh giới tối cao (Chân Tiên viên mãn)"
		elif not is_at_peak_layer():
			fail_reason = "Tu vi chưa viên mãn tại tầng 9"
		if on_breakthrough_failed.is_valid():
			on_breakthrough_failed.call({
				"realm_index": _current_realm_index,
				"realm_name": get_current_realm_name(),
				"reason": fail_reason
			})
		return {"success": false, "reason": fail_reason}

	var old_r_idx: int = _current_realm_index
	_current_realm_index += 1
	_current_layer = 1
	_current_layer_exp = 0

	var new_name: String = get_current_realm_name()
	if on_breakthrough_success.is_valid():
		on_breakthrough_success.call({
			"old_realm_index": old_r_idx,
			"new_realm_index": _current_realm_index,
			"new_realm_name": new_name
		})

	return {
		"success": true,
		"new_realm_index": _current_realm_index,
		"new_realm_name": new_name,
		"reason": "ok"
	}


func get_cultivation_info() -> Dictionary:
	return {
		"realm_index": _current_realm_index,
		"realm_name": get_current_realm_name(),
		"layer": _current_layer,
		"layer_exp": _current_layer_exp,
		"required_exp": get_required_layer_exp(),
		"total_exp": _total_exp,
		"can_breakthrough": can_breakthrough()
	}


func save_to_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	config.set_value(SECTION_META, "version", SAVE_VERSION)
	config.set_value(SECTION_CULTIVATION, "realm_index", _current_realm_index)
	config.set_value(SECTION_CULTIVATION, "layer", _current_layer)
	config.set_value(SECTION_CULTIVATION, "layer_exp", _current_layer_exp)
	config.set_value(SECTION_CULTIVATION, "total_exp", _total_exp)

	var err: Error = config.save(path)
	if err != OK:
		push_error("Lỗi khi lưu cultivation vào %s: mã %d" % [path, err])
		return false
	return true


func load_from_disk(custom_path: String = "") -> bool:
	var path: String = SAVE_PATH if custom_path.is_empty() else custom_path
	var config := ConfigFile.new()
	var err: Error = config.load(path)
	if err != OK:
		return false

	var save_ver: int = int(config.get_value(SECTION_META, "version", 0))
	if save_ver <= 0 or save_ver > SAVE_VERSION:
		push_warning("Cultivation: Phiên bản save không hỗ trợ (%d)" % save_ver)
		return false

	var r_idx: int = int(config.get_value(SECTION_CULTIVATION, "realm_index", 0))
	var lay: int = int(config.get_value(SECTION_CULTIVATION, "layer", 1))
	var l_exp: int = int(config.get_value(SECTION_CULTIVATION, "layer_exp", 0))
	var t_exp: int = int(config.get_value(SECTION_CULTIVATION, "total_exp", 0))

	# Kiểm tra tính hợp lệ của dữ liệu tải về
	_current_realm_index = clampi(r_idx, 0, maxi(0, _realms.size() - 1))
	_current_layer = clampi(lay, 1, 9)
	_current_layer_exp = maxi(0, l_exp)
	_total_exp = maxi(0, t_exp)

	return true
