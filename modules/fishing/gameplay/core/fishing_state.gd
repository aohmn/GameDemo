class_name FishingState
extends RefCounted

## Định nghĩa 8 trạng thái hữu hạn chuẩn của hệ thống câu cá (FSM).
## Tương thích và đồng bộ 100% giữa Controller, Presentation (UI, Rig) và EventBus.

enum State {
	IDLE,      # Chưa câu / Sẵn sàng
	CASTING,   # Quăng cần
	WAITING,   # Chờ cá cắn câu
	BITE,      # Cá cắn câu (cửa sổ giật cần)
	FIGHT,     # Đấu sức giằng co với cá (tên quy chuẩn FIGHT để đồng bộ EventBus/UI/Rig)
	CAUGHT,    # Thu phục cá thành công
	ESCAPED,   # Cá trốn thoát (giật trễ, tuột lưỡi do chùng dây)
	FAILED     # Thất bại (đứt dây, gãy cần, giật quá sớm, hủy câu)
}

const STATE_NAMES: Dictionary = {
	State.IDLE: "IDLE",
	State.CASTING: "CASTING",
	State.WAITING: "WAITING",
	State.BITE: "BITE",
	State.FIGHT: "FIGHT",
	State.CAUGHT: "CAUGHT",
	State.ESCAPED: "ESCAPED",
	State.FAILED: "FAILED"
}


static func get_state_name(state: int) -> String:
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
			return to_state == State.FIGHT or to_state == State.ESCAPED or to_state == State.FAILED
		State.FIGHT:
			return to_state == State.CAUGHT or to_state == State.ESCAPED or to_state == State.FAILED
		State.CAUGHT, State.ESCAPED, State.FAILED:
			return to_state == State.IDLE
		_:
			return false
