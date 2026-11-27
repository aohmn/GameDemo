class_name BattleSkillRunner
extends RefCounted
## Bộ chạy kỹ năng theo dữ liệu (không hardcode từng kỹ năng vào FishingBattle).

var _cooldowns: Dictionary = {} # skill_id -> float
var _active_effects: Array[Dictionary] = []
var _telegraph: Dictionary = {} # {spec, remaining}


func reset() -> void:
	_cooldowns.clear()
	_active_effects.clear()
	_telegraph.clear()


func tick(delta: float) -> Dictionary:
	for k in _cooldowns.keys():
		_cooldowns[k] = maxf(0.0, float(_cooldowns[k]) - delta)

	var fired_spec: Resource = null
	if not _telegraph.is_empty():
		_telegraph["remaining"] = float(_telegraph["remaining"]) - delta
		if float(_telegraph["remaining"]) <= 0.0:
			fired_spec = _telegraph["spec"] as Resource
			_telegraph.clear()
			_activate_effect(fired_spec)

	var kept: Array[Dictionary] = []
	for eff in _active_effects:
		eff["remaining"] = float(eff["remaining"]) - delta
		if float(eff["remaining"]) > 0.0:
			kept.append(eff)
	_active_effects = kept
	return {"fired_spec": fired_spec}


func try_cast(spec: Resource, current_qi: float) -> Dictionary:
	if spec == null:
		return {"ok": false, "reason": "null_spec", "qi_left": current_qi}
	var s_id: String = str(spec.get("id"))
	if float(_cooldowns.get(s_id, 0.0)) > 0.0:
		return {"ok": false, "reason": "cooldown", "qi_left": current_qi}
	var cost: float = float(spec.get("qi_cost")) if "qi_cost" in spec else 0.0
	if current_qi < cost:
		return {"ok": false, "reason": "no_qi", "qi_left": current_qi}

	var cd: float = float(spec.get("cooldown")) if "cooldown" in spec else 5.0
	_cooldowns[s_id] = cd
	var tele: float = float(spec.get("telegraph_time")) if "telegraph_time" in spec else 0.0
	if tele > 0.0 and str(spec.get("owner_type")) == "fish":
		_telegraph = {"spec": spec, "remaining": tele}
	else:
		_activate_effect(spec)
	return {"ok": true, "qi_left": current_qi - cost, "telegraph": tele > 0.0 and str(spec.get("owner_type")) == "fish"}


func get_effect_multiplier(effect_type: String) -> float:
	var total: float = 0.0
	for eff in _active_effects:
		if str(eff.get("type", "")) == effect_type:
			total += float(eff.get("power", 0.0))
	return total


func is_telegraphing() -> bool:
	return not _telegraph.is_empty()


func _activate_effect(spec: Resource) -> void:
	var dur: float = float(spec.get("duration")) if "duration" in spec else 2.0
	_active_effects.append({
		"id": str(spec.get("id")),
		"type": str(spec.get("effect_type")),
		"power": float(spec.get("effect_power")),
		"remaining": dur,
	})
