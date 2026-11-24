class_name FishingState
extends RefCounted

## Định nghĩa 8 trạng thái hữu hạn của máy trạng thái câu cá (FSM).
## Tuân thủ mục 4 TASK 11: Ngăn chặn nhảy cóc trạng thái hoặc gọi tắt kết quả.

enum State {
	IDLE,      # Chưa câu
	CASTING,   # Thả câu
	WAITING,   # Chờ cá cắn câu
	BITE,      # Cá cắn câu (cửa sổ giật cần)
	FIGHTING,  # Đấu sức giằng co với cá
	CAUGHT,    # Thu phục cá thành công
	ESCAPED,   # Cá trốn thoát (giật trễ, tuột lưỡi, dây chùng)
	FAILED     # Thất bại (đứt dây, gãy cần, giật quá sớm, hủy câu)
}

const STATE_NAMES: Dictionary = {
	State.IDLE: "IDLE",
	State.CASTING: "CASTING",
	State.WAITING: "WAITING",
	State.BITE: "BITE",
	State.FIGHTING: "FIGHTING",
	State.CAUGHT: "CAUGHT",
	State.ESCAPED: "ESCAPED",
	State.FAILED: "FAILED"
}


static func get_name(state: int) -> String:
	return str(STATE_NAMES.get(state, "UNKNOWN"))


## Kiểm tra tính hợp lệ của việc chuyển trạng thái để chống gian lận/nhảy cóc
static func can_transition(from_state: int, to_state: int) -> bool:
	match from_state:
		State.IDLE:
			return to_state == State.CASTING
		State.CASTING:
			return to_state == State.WAITING or to_state == State.FAILED
		State.WAITING:
			return to_state == State.BITE or to_state == State.FAILED or to_state == State.ESCAPED
		State.BITE:
			return to_state == State.FIGHTING or to_state == State.ESCAPED or to_state == State.FAILED
		State.FIGHTING:
			return to_state == State.CAUGHT or to_state == State.ESCAPED or to_state == State.FAILED
		State.CAUGHT, State.ESCAPED, State.FAILED:
			return to_state == State.IDLE
		_:
			return false
