class_name FishAI
extends RefCounted

## Trí tuệ nhân tạo (Hành vi) của cá khi đấu sức:
## Mô phỏng hành vi phản kháng từng đợt, bơi bứt tốc, đổi hướng và nhử dây.

enum BehaviorMode {
	TIRED,    # Cá đang mệt, ít giãy
	NORMAL,   # Bơi kháng cự đều đặn
	RUSH,     # Đợt bứt tốc giãy mạnh (Surge)
	REST      # Cá tạm nghỉ/thăm dò, dây dễ chùng
}

var current_mode: int = BehaviorMode.NORMAL
var mode_timer: float = 0.0
var rng: RandomNumberGenerator


func _init(random_gen: RandomNumberGenerator) -> void:
	rng = random_gen


## Cập nhật hành vi và trả về lực giật kéo tức thời (pull force)
func update_pull_force(fish_data: FishData, fight_time: float, delta: float) -> float:
	mode_timer -= delta
	if mode_timer <= 0.0:
		_switch_mode(fish_data)

	var base_pull := fish_data.strength * 0.6
	var pulse := maxf(0.0, sin(fight_time * (TAU / (1.2 / maxf(0.5, fish_data.swim_speed)))))

	match current_mode:
		BehaviorMode.RUSH:
			# Đợt bứt phá mãnh liệt, cá kéo căng hết cỡ
			return base_pull * (1.8 + pulse * fish_data.resistance)
		BehaviorMode.NORMAL:
			# Kháng cự nhịp nhàng
			return base_pull * (1.0 + pulse * 0.8)
		BehaviorMode.REST:
			# Cá ngừng kéo đột ngột khiến dây dễ bị chùng
			return base_pull * 0.2
		BehaviorMode.TIRED:
			# Thể lực cạn kiệt, cá yếu sức
			return base_pull * 0.4
		_:
			return base_pull


func _switch_mode(fish_data: FishData) -> void:
	var roll := rng.randf()
	if roll < 0.25:
		current_mode = BehaviorMode.RUSH
		mode_timer = rng.randf_range(1.0, 2.5)
	elif roll < 0.55:
		current_mode = BehaviorMode.NORMAL
		mode_timer = rng.randf_range(2.0, 4.0)
	elif roll < 0.85:
		current_mode = BehaviorMode.REST
		mode_timer = rng.randf_range(1.0, 2.0)
	else:
		current_mode = BehaviorMode.TIRED
		mode_timer = rng.randf_range(1.5, 3.0)
