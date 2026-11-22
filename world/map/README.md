# World Map — Bản đồ mở

## 1. Mục tiêu

Bản đồ mở gồm:
- **Bản đồ trung tâm (hub)** — `scenes/hub_map.tscn`, 40×40m, chỉ đường đi và lối chuyển vào các khu vực.
- **Khu vực** — scene độc lập, mỗi khu vực là một bản đồ (hồ câu: `scenes/fishing_lake_map.tscn`).
- **Hệ thống chung** — `scenes/shared/shared_map.tscn` (Player, Camera, HUD, Joystick) độc lập với nội dung từng map.

## 2. Cấu trúc

```
world/map/
├── scenes/
│   ├── shared/shared_map.tscn      # Player, HUD, Joystick, minimap (hệ thống chung)
│   ├── hub_map.tscn                # Bản đồ trung tâm: nền + đường + lối chuyển
│   └── fishing_lake_map.tscn       # Hồ câu
├── areas/
│   ├── map_area.gd                 # MapArea: spawn, recovery, transition, road points
│   ├── hub_map_area.gd             # Bản đồ trung tâm: nền + đường + lối chuyển
│   └── fishing_lake_map_area.gd    # Hồ câu: nội dung hồ cá
├── content/                        # Builders (tái sử dụng code từ map_controller cũ)
│   ├── terrain/ground_builder.gd
│   ├── roads/road_builder.gd
│   ├── buildings/building_builder.gd
│   ├── trees/tree_builder.gd
│   ├── objects/object_builder.gd
│   └── transitions/transition_builder.gd
├── minimap.gd
└── README.md
```

## 3. Bản đồ trung tâm (hub, 40×40)

Hub sở hữu:
- Nền: `HubGround` (40×40).
- Đường: `RoadMain`, `RoadSpine`.
- Lối chuyển: `ToLake` (Area3D tại (0,1,4), sign "Hồ câu").
- Spawn: `hub_entry` = (0, 0.05, -8).
- Không có nhà, cây, kênh, hồ cá — không nhồi nhiều vào hub.

## 4. Hồ câu

- `fishing_lake_map.tscn` (map root chỉ metadata `npc_spawn_enabled = false`).
- Nội dung: `LakeWater`, LakeBanks, `DirtPath`, `FishingDock`, cây quanh hồ.
- Lối chuyển: `ToHub` (0,1,43) → `hub_map.tscn`.
- Spawn: `lake_entry` = (0, 0.05, 22).

## 5. Hệ thống chung (shared)

- Player, Camera, HUD, Joystick trong `shared_map.tscn` — độc lập với map.
- NPCDirector được nối vào SharedMap scene (nếu module NPC tồn tại).
- Bootstrap sở hữu vòng đời map; chuyển map qua `WorldEvents.MAP_CHANGE_REQUESTED`.

## 6. Navigation

- `MapArea` gọi `WorldNavigation.set_graph(points, width)` — đồ thị đường theo khu vực hiện tại.
- Hồ câu: không đường → route trả về rỗng.
- Minimap vẽ đường từ `WorldNavigation.get_road_points()`.

## 7. Save/Load

- Player participant: vị trí + máu — nhận khi vào map bất kỳ.
- GameClock (bootstrap), NPCDirector (nếu có) — participant qua Bootstrap/NPCDirector.

## 8. Đồ họa

- Không texture. Tất cả primitive mesh + `ShaderMaterial`/`StandardMaterial3D`.

## 9. Kiểm tra

1. `gdparse` cho các .gd mới và sửa: `world/map/areas/*.gd`, `world/map/content/*/*.gd`, `core/bootstrap/boot.gd`, `world/navigation/navigation_service.gd`, `world/map/minimap.gd`.
2. Mở Godot Android, chạy `scenes/boot/boot.tscn`:
   - Player xuất hiện ở (0, 0.05, -8) trên hub; HUD, Joystick, Minimap hiển thị.
   - Đi sang hồ câu: Player ở (0, 0.05, 22), không về mặt nước.
3. Mở Godot Android, xác nhận không lỗi parser.

## 10. Giới hạn hiện tại

- Chưa có chunk streaming/region streaming.
- Hồ câu chưa có va chạm cho nước.
- Chưa có runtime verification trên Godot Android.

## Spawn theo cổng chuyển map

- Mỗi cổng trong `TransitionBuilder` có `dest_scene` và `dest_spawn` (id điểm xuất hiện ở map đích).
- Map đích khai báo điểm đó trong `get_spawn_points()`; thiếu id thì dùng `get_entry_point()`.
- Điểm xuất hiện phải nằm NGOÀI vùng cổng để không bị chuyển ngược ngay.
- Thêm map/cổng mới: khai báo `dest_spawn` ở cổng và `get_spawn_points()` ở map đích.
