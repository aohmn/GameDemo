class_name BattleSkillSpec
extends Resource
## Dữ liệu kỹ năng đấu cá mở rộng được (dùng chung cho Người chơi và Cá).

@export var id: String = ""
@export var display_name: String = ""
@export var owner_type: String = "player" # "player" | "fish"
@export var min_tier: int = 1
@export var qi_cost: float = 20.0
@export var cooldown: float = 6.0
@export var telegraph_time: float = 0.8 # Thời gian báo trước (chủ yếu cho cá)
@export var duration: float = 2.0
@export var effect_type: String = "pull_reduce" # pull_reduce | tension_damp | hp_damage | fish_surge | line_shock
@export var effect_power: float = 0.35
