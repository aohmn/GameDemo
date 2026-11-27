extends RefCounted
## Nạp tài nguyên mặc định và phát EventBus cho FishingAPI.


static func load_defaults(api: RefCounted) -> void:
	var r_paths: Array[String] = [
		"res://modules/fishing/data/resources/rod_truc_nhiem.tres",
		"res://modules/fishing/data/resources/rod_carbon_bien_sau.tres",
	]
	for p in r_paths:
		if ResourceLoader.exists(p):
			api.call("register_rod", load(p))

	var s_paths: Array[String] = [
		"res://modules/fishing/data/resources/spot_cau_tau_ben_cang.tres",
		"res://modules/fishing/data/resources/spot_ho_linh_ngu.tres",
	]
	for p in s_paths:
		if ResourceLoader.exists(p):
			api.call("register_spot", load(p))


static func emit_event(event_name: String, payload: Dictionary) -> void:
	var main_loop: MainLoop = Engine.get_main_loop()
	if main_loop is SceneTree:
		var st := main_loop as SceneTree
		if st.root != null and st.root.has_node("EventBus"):
			var eb: Node = st.root.get_node("EventBus")
			if eb != null and eb.has_method("emit_event"):
				eb.call("emit_event", event_name, payload)
