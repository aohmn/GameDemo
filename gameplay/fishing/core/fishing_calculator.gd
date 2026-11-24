class_name FishingCalculator
extends RefCounted

## Tách biệt toàn bộ phép tính toán vật lý, lực căng, độ mỏi và xác suất:
## Giúp nhà thiết kế dễ dàng cân bằng game sau này mà không đụng chạm logic điều khiển.


## Tính toán lực căng dây thay đổi trong 1 tick delta
static func calculate_tension_delta(
	is_reeling: bool,
	is_releasing: bool,
	reel_speed: float,
	release_speed: float,
	fish_pull: float,
	player_factor: float,
	delta: float
) -> float:
	var delta_tension: float = 0.0

	if is_reeling and not is_releasing:
		delta_tension += (reel_speed * player_factor) * delta
	elif is_releasing and not is_reeling:
		delta_tension -= release_speed * delta
	else:
		# Dây chùng tự nhiên nhẹ
		delta_tension -= (release_speed * 0.25) * delta

	# Lực kéo từ cá
	delta_tension += fish_pull * delta
	return delta_tension


## Tính lượng tiêu hao thể lực của cá khi lực căng trong vùng an toàn
static func calculate_fish_stamina_drain(
	tension: float,
	safe_min: float,
	safe_max: float,
	fatigue_rate: float,
	fish_tenacity: float, # Độ lì của cá: càng cao càng lâu mệt
	delta: float
) -> float:
	if tension >= safe_min and tension <= safe_max:
		var efficiency: float = 1.0
		# Nếu giữ lực căng ở chính giữa vùng an toàn, hiệu suất làm mỏi cá cao nhất
		var center := (safe_min + safe_max) * 0.5
		var half_range := (safe_max - safe_min) * 0.5
		if half_range > 0.0:
			var dev := absf(tension - center) / half_range
			efficiency = 1.2 - (dev * 0.4)
		var tenacity_modifier := 1.0 / maxf(0.5, fish_tenacity)
		return fatigue_rate * efficiency * tenacity_modifier * delta

	# Khi dây ngoài vùng an toàn (quá chùng hoặc quá căng), cá hồi sức nhẹ
	return - (fatigue_rate * 0.15) * delta


## Tính độ hao mòn độ bền của dây câu khi chịu lực căng cao
static func calculate_line_wear(
	tension: float,
	max_tension: float,
	safe_max: float,
	delta: float
) -> float:
	if tension > safe_max:
		var over := (tension - safe_max) / maxf(1.0, max_tension - safe_max)
		return over * 15.0 * delta
	return 0.5 * delta # Hao mòn bình thường


## Tính thời gian chờ cá cắn câu dựa trên mồi, điểm câu và độ hiếm cá
static func calculate_wait_time(
	min_wait: float,
	max_wait: float,
	rarity: int,
	bait_attraction: float,
	rng: RandomNumberGenerator
) -> float:
	var base := rng.randf_range(min_wait, max_wait)
	var rarity_delay := float(rarity - 1) * 0.6
	var attraction_discount := clampf(bait_attraction * 0.2, 0.0, 3.0)
	return maxf(0.8, base + rarity_delay - attraction_discount)
