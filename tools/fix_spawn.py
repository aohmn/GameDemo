#!/usr/bin/env python3
"""Spawn theo cổng: đi qua cổng nào thì xuất hiện ngay cạnh cổng đối diện.
Chạy lại nhiều lần vẫn an toàn."""
import re
from pathlib import Path


def edit(path, fn, label):
    p = Path(path)
    t = p.read_text(encoding="utf-8")
    t2 = fn(t)
    if t2 == t:
        print("bỏ qua (đã đúng):", label)
    else:
        p.write_text(t2, encoding="utf-8")
        print("đã sửa:", label)


def must(t, old, new, label):
    assert t.count(old) == 1, "không tìm thấy đúng 1 chỗ: " + label
    return t.replace(old, new)


# 1. TransitionBuilder: truyền thêm dest_spawn khi đi vào cổng
def tb(t):
    if "dest_spawn" in t:
        return t
    return must(t, 'on_enter.bind(spec["dest_scene"])',
                'on_enter.bind(spec["dest_scene"], str(spec.get("dest_spawn", "")))', "TransitionBuilder bind")


edit("world/map/content/transitions/transition_builder.gd", tb, "transition_builder.gd: dest_spawn")


# 2. MapArea: gửi spawn_id trong event, và tự chọn điểm xuất hiện theo spawn_id
def ma(t):
    if "SPAWN_META" in t:
        return t
    t = must(t, "var _transitioning := false\n",
             'const SPAWN_META: StringName = &"spawn_id"\n\nvar _transitioning := false\n', "MapArea const")
    t = must(t, "\tplayer.global_position = get_entry_point()\n",
             "\tvar spawn_position := _resolve_spawn_point()\n\tplayer.global_position = spawn_position\n", "MapArea spawn pos")
    t = must(t, '\tprint("[World] Spawn: ", name, " at ", get_entry_point())\n',
             '\tprint("[World] Spawn: ", name, " at ", spawn_position)\n', "MapArea print")
    t = must(t, "func _apply_spawn() -> void:",
             "## Điểm xuất hiện theo spawn_id do Bootstrap gắn vào map; thiếu thì dùng entry mặc định.\n"
             "func _resolve_spawn_point() -> Vector3:\n"
             "\tvar spawn_id: String = str(get_meta(SPAWN_META, \"\"))\n"
             "\tif spawn_id.is_empty():\n\t\treturn get_entry_point()\n"
             "\tvar points: Dictionary = get_spawn_points()\n"
             "\tif points.has(spawn_id):\n\t\treturn points[spawn_id]\n"
             "\tpush_warning(\"[World] %s không có spawn point '%s'; dùng entry mặc định.\" % [name, spawn_id])\n"
             "\treturn get_entry_point()\n\n\nfunc _apply_spawn() -> void:", "MapArea resolve")
    t = must(t, "func _on_transition_entered(body: Node3D, dest_scene: String) -> void:",
             'func _on_transition_entered(body: Node3D, dest_scene: String, dest_spawn: String = "") -> void:', "MapArea signature")
    t = must(t, '\t\t"scene_path": dest_scene\n', '\t\t"scene_path": dest_scene,\n\t\t"spawn_id": dest_spawn,\n', "MapArea payload")
    return t


edit("world/map/areas/map_area.gd", ma, "map_area.gd: spawn theo spawn_id")


# 3. Bootstrap: chuyển spawn_id từ event sang map mới trước khi map vào cây
def bt(t):
    if "spawn_id" in t:
        return t
    t = must(t, '\tcall_deferred("_change_map", scene_path)\n',
             '\tcall_deferred("_change_map", scene_path, str(payload.get("spawn_id", "")))\n', "boot call_deferred")
    t = must(t, "func _change_map(scene_path: String) -> void:",
             'func _change_map(scene_path: String, spawn_id: String = "") -> void:', "boot _change_map")
    t = must(t, "\t_show_map(map_scene)\n\n\n## ", "\t_show_map(map_scene, spawn_id)\n\n\n## ", "boot _show_map call")
    t = must(t, "func _show_map(map_scene: PackedScene) -> void:",
             'func _show_map(map_scene: PackedScene, spawn_id: String = "") -> void:', "boot _show_map sig")
    t = must(t, "\t_attach_player_visual(_shared)\n\t_attach_npc_director(map_instance, _shared)\n",
             "\tif not spawn_id.is_empty():\n\t\tmap_instance.set_meta(&\"spawn_id\", spawn_id)\n"
             "\t_attach_player_visual(_shared)\n\t_attach_npc_director(map_instance, _shared)\n", "boot set_meta")
    return t


edit("core/bootstrap/boot.gd", bt, "boot.gd: truyền spawn_id")


# 4. Hub: cổng sang hồ + điểm xuất hiện khi từ hồ về (ngoài vùng cổng, cách 1.65 m)
def hub(t):
    if "from_lake" in t:
        return t
    t = must(t, '"dest_scene": "res://world/map/scenes/fishing_lake_map.tscn",',
             '"dest_scene": "res://world/map/scenes/fishing_lake_map.tscn",\n\t\t\t"dest_spawn": "from_hub",', "hub dest_spawn")
    t = must(t, 'return {"hub_entry": Vector3(0.0, 0.05, -8.0)}',
             'return {\n\t\t"hub_entry": Vector3(0.0, 0.05, -8.0),\n\t\t"from_lake": Vector3(0.0, 0.05, 8.5),\n\t}', "hub spawn points")
    return t


edit("world/map/areas/hub_map_area.gd", hub, "hub_map_area.gd: from_lake + dest_spawn")


# 5. Hồ: cổng về hub + điểm xuất hiện khi từ hub sang (ngoài vùng cổng, cách 2.6 m)
def lake(t):
    if "from_hub" in t:
        return t
    t = must(t, '"dest_scene": "res://world/map/scenes/hub_map.tscn",',
             '"dest_scene": "res://world/map/scenes/hub_map.tscn",\n\t\t\t"dest_spawn": "from_lake",', "lake dest_spawn")
    t = must(t, 'return {"lake_entry": Vector3(0.0, 0.05, 22.0)}',
             'return {\n\t\t"lake_entry": Vector3(0.0, 0.05, 22.0),\n\t\t"from_hub": Vector3(0.0, 0.05, 37.5),\n\t}', "lake spawn points")
    return t


edit("world/map/areas/fishing_lake_map_area.gd", lake, "fishing_lake_map_area.gd: from_hub + dest_spawn")
