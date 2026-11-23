# World Map — Bản đồ mở

## 1. Mục tiêu

Bản đồ mở gồm:
- **Bản đồ trung tâm (hub)** — `scenes/hub_map.tscn`, ~110×120m (bounds `Rect2(-55, -60, 110, 120)`), bố cục kiểu PHỐ CHÍNH + HẺM CỤT, dựng từ `MapLayout`.
- **Khu vực** — scene độc lập, mỗi khu vực là một bản đồ (hồ câu: `scenes/fishing_lake_map.tscn`).
- **Hệ thống chung** — `scenes/shared/shared_map.tscn` (Player, Camera, HUD, Joystick) độc lập với nội dung từng map.

## 2. Cấu trúc

```
world/map/
├── layout/                         # Resource specs cho bố cục map (static typing)
│   ├── map_layout.gd               # MapLayout { bounds, roads, lots, buildings, gates }
│   ├── road_spec.gd                # RoadSpec { id, kind, start_point, end_point, width }
│   ├── lot_spec.gd                 # LotSpec { id, rect, facing }
│   ├── building_spec.gd            # BuildingSpec { id, type, lot_id, floors, color, sign_text, door_point }
│   └── gate_spec.gd                # GateSpec { id, name, position, size, sign_text, dest_scene, dest_spawn }
├── data/
│   └── hub_layout.tres             # Dữ liệu bố cục MapLayout của khu dân cư (hub)
├── scenes/
│   ├── shared/shared_map.tscn      # Player, HUD, Joystick, minimap (hệ thống chung)
│   ├── hub_map.tscn                # Bản đồ trung tâm: nền + đường + lối chuyển
│   └── fishing_lake_map.tscn       # Hồ câu
├── areas/
│   ├── map_area.gd                 # MapArea: map_bounds, get_road_points(), get_buildings()
│   ├── hub_map_area.gd             # Bản đồ trung tâm dựng từ hub_layout.tres
│   └── fishing_lake_map_area.gd    # Hồ câu: nội dung hồ cá
├── content/                        # Builders dựng hình học không texture
│   ├── terrain/ground_builder.gd
│   ├── roads/road_builder.gd       # Dựng nền, lòng đường, vỉa hè, gờ lề, vạch kẻ theo chuẩn độ cao
│   ├── buildings/building_builder.gd
│   ├── trees/tree_builder.gd
│   ├── objects/object_builder.gd
│   └── transitions/transition_builder.gd
├── minimap.gd
└── README.md
```

## 3. Bản đồ trung tâm (hub, ~110×120m)

Hub sở hữu bố cục kiểu Phố chính + Hẻm cụt:
- Nền & hạ tầng: Dựng tự động từ `hub_layout.tres` qua `RoadBuilder.build_from_layout()`.
- Bảng độ cao mặt trên (m): Nền đất 0.00, Gờ lề 0.04, Lòng đường 0.05, Vạch sơn 0.062, Vỉa hè 0.08. Không để hai khối khác màu cùng độ cao.
- Phố chính: chạy dọc z từ -50 đến +50, lòng đường rộng 7m, vỉa hè 2m mỗi bên, vạch kẻ tim đường đứt đoạn.
- 3 hẻm cụt: rộng 3.5m, vỉa hè 1m mỗi bên, xen kẽ hai bên tại z = -30 (tây), z = 0 (đông), z = +30 (tây), dài ~25–28.5m.
- Quảng trường phía bắc: z từ -50 đến -38, lòng đường rộng 24m.
- Lối chuyển sang Hồ câu ở đầu nam: `ToLake` tại `(0, 1, 46.5)` dẫn sang Hồ câu (`dest_spawn: "from_hub"`).
- Spawn: `hub_entry` = `(0, 0.08, -8)`, `from_lake` = `(0, 0.08, 41)`.

## 4. MapArea — API cong khai

`map_area.gd` la base class; moi map ke thua:
- `map_bounds: Rect2` — gioi han toa do (x, z).
- `get_road_points() -> Array[Vector3]` — cac diem waypoint duong bo.
- `get_buildings() -> Dictionary` — {id: {door_point, type, sign_text, position, size}}.
- `_emit_buildings_ready()` — phat `WorldEvents.BUILDINGS_READY` sau `build_content()`.

**Flow BUILDINGS_READY**:
```
HubMapArea._ready()
  └─ build_content()          # Dung duong, via he, toa nha
      └─ _emit_buildings_ready()
          └─ EventBus.emit(BUILDINGS_READY, {buildings: {id: Vector3}})
              └─ NPCDirector._on_buildings_ready()
                  └─ LifeNPC.set_building_doors()
                      └─ LifeNPC.place_at_current_schedule()
```
Minimap, NPC va WorldNavigation doc tu day; khong hardcode toa do.

## 4. Hồ câu

- `fishing_lake_map.tscn` (map root chỉ metadata `npc_spawn_enabled = false`).
- Nội dung: `LakeWater`, LakeBanks, `DirtPath`, `FishingDock`, cây quanh hồ.
- Lối chuyển: `ToHub` (0, 1, 43) → `hub_map.tscn` (`dest_spawn: "from_lake"`).
- Spawn: `lake_entry` = (0, 0.05, 22), `from_hub` = (0, 0.05, 37.5).

## 5. Hệ thống chung (shared)

- Player, Camera, HUD, Joystick trong `shared_map.tscn` — độc lập với map.
- NPCDirector được nối vào SharedMap scene (nếu module NPC tồn tại).
- Bootstrap sở hữu vòng đời map; chuyển map qua `WorldEvents.MAP_CHANGE_REQUESTED`.

## 6. Navigation

- `MapArea` gọi `WorldNavigation.set_graph(points, width)` — đồ thị đường theo khu vực hiện tại.
- Hồ câu: không đường → route trả về rỗng.
- Minimap vẽ đường từ `WorldNavigation.get_road_points()`.

## 6b. Minimap / Bản đồ lớn

- **Minimap nhỏ**: bán kính ~30 m quanh Player (hằng số `MINI_RADIUS`), không chiếu toàn map.
- **Bản đồ lớn**: hiển thị TOÀN BỘ `map_bounds` của MapArea hiện tại (`Rect2(-55, -60, 110, 120)` trên Hub).
  - Tỷ lệ đều: `scale = min(pixel_w / bounds_w, pixel_h / bounds_h)`, căn giữa trong vùng vẽ.
  - Zoom (1x–4x) và pan nhân trên `scale` đó.
  - Nút -, +, ĐÓNG: hàm `_button_rects()` trả 3 `Rect2` không chồng nhau (khoảng cách ≥ 10 px); dùng chung cho vẽ và bắt chạm.
  - Waypoint: chạm trên map đặt điểm đích, yêu cầu route từ `WorldNavigation`.
- Ngưỡng kéo > 12 px để ngón rung không mất tap.

## 7. Save/Load

- Player participant: vị trí + máu — nhận khi vào map bất kỳ.
- GameClock (bootstrap), NPCDirector (nếu có) — participant qua Bootstrap/NPCDirector.

## 8. Đồ họa

- Không texture. Tất cả primitive mesh + `ShaderMaterial`/`StandardMaterial3D`.

## 9. Kiểm tra

1. Cú pháp và import sạch không có lỗi parser / script error.
2. Kiểm tra Player di chuyển từ đầu phố chính qua hết các hẻm cụt: `Player.y` luôn ổn định (~0.05m), không rơi xuyên sàn.
3. Chuyển map hai chiều qua lại (Hub <-> Hồ câu): xuất hiện an toàn tại điểm spawn đối diện, không bị bật ngược lặp lại.
4. Minimap và bản đồ lớn đọc đúng `map_bounds` từ MapArea.

## 10. Giới hạn hiện tại

- Chưa có chunk streaming/region streaming.
- Hồ câu chưa có va chạm cho nước.
- Chưa xác nhận trực tiếp bằng mắt trên giao diện Godot Android.
