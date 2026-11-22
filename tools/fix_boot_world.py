#!/usr/bin/env python3
"""Sửa lỗi nặng sau refactor map hub: Player rơi xuyên sàn, màn hình đen,
nhân vật 3D đè sprite, đường nhiễu sọc. Chạy lại nhiều lần vẫn an toàn."""
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


# 1. script phải là dòng thuộc tính riêng, không được nằm trong dòng tiêu đề node
for scene in ["world/map/scenes/hub_map.tscn", "world/map/scenes/fishing_lake_map.tscn"]:
    edit(scene, lambda t: re.sub(r'(\[node name="[^"]+" type="Node3D") script=ExtResource\("1_area"\)\]',
                                 r'\1]\nscript = ExtResource("1_area")', t), scene)

# 2. const phải khai báo kiểu Array[Dictionary] để truyền vào build()
edit("world/map/areas/fishing_lake_map_area.gd",
     lambda t: t.replace("const LAKE_GROUND_SPECS := [", "const LAKE_GROUND_SPECS: Array[Dictionary] = ["),
     "fishing_lake_map_area.gd: kiểu LAKE_GROUND_SPECS")


# 3. ánh sáng + môi trường dùng chung (mất sau refactor map mới)
def add_light(t):
    if "WorldEnvironment" in t:
        return t
    assert t.count('[node name="SharedMap" type="Node3D"]\n') == 1
    m = re.search(r"load_steps=(\d+)", t)
    t = t.replace(m.group(0), "load_steps=%d" % (int(m.group(1)) + 1), 1)
    sub = ('[sub_resource type="Environment" id="Environment_world"]\n'
           'background_mode = 1\nbackground_color = Color(0.52, 0.72, 0.86, 1)\n'
           'ambient_light_source = 2\nambient_light_color = Color(0.82, 0.86, 0.92, 1)\n'
           'ambient_light_energy = 0.82\ntonemap_mode = 2\nfog_enabled = true\n'
           'fog_light_color = Color(0.66, 0.76, 0.81, 1)\nfog_density = 0.0018\n\n')
    first_sub = t.index("[sub_resource")
    t = t[:first_sub] + sub + t[first_sub:]
    node = '[node name="SharedMap" type="Node3D"]\n'
    nodes = (node + '\n[node name="WorldEnvironment" type="WorldEnvironment" parent="."]\n'
             'environment = SubResource("Environment_world")\n\n'
             '[node name="Sun" type="DirectionalLight3D" parent="."]\n'
             'rotation_degrees = Vector3(-52, -32, 0)\nlight_color = Color(1, 0.93, 0.82, 1)\n'
             'light_energy = 1.25\nshadow_enabled = true\ndirectional_shadow_max_distance = 85.0\n')
    return t.replace(node, nodes)


edit("world/map/scenes/shared/shared_map.tscn", add_light, "shared_map.tscn: WorldEnvironment + Sun")


# 4. gắn sprite TRƯỚC khi SharedMap vào cây để VisualRoot tự ẩn
def attach_first(t):
    if "Gắn sprite TRƯỚC" in t:
        return t
    old = "\t_shared = SHARED_SCENE.instantiate()\n\tadd_child(_shared)\n"
    assert t.count(old) == 1, "boot.gd: không thấy _add_shared_systems"
    return t.replace(old, "\t_shared = SHARED_SCENE.instantiate()\n"
                          "\t# Gắn sprite TRƯỚC khi vào cây để VisualRoot thấy Visual trong _ready và tự ẩn.\n"
                          "\t_attach_player_visual(_shared)\n\tadd_child(_shared)\n")


edit("core/bootstrap/boot.gd", attach_first, "boot.gd: gắn sprite trước add_child")


# 5. mặt đường hub trùng độ cao với nền (top = 0) gây nhiễu sọc; nền hub cháy sáng
def hub(t):
    t = t.replace('"position": Vector3(0.0, -0.05, -9.0)', '"position": Vector3(0.0, 0.0, -9.0)')
    t = t.replace('"position": Vector3(0.0, -0.05, 5.0)', '"position": Vector3(0.0, 0.0, 5.0)')
    t = t.replace('"color": Color(0.6, 0.58, 0.5)', '"color": Color(0.36, 0.50, 0.30)')
    return t


edit("world/map/areas/hub_map_area.gd", hub, "hub_map_area.gd: độ cao đường + màu nền")
