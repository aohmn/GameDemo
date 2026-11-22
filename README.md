# ProjectGame

Game mô phỏng cuộc sống (Life Simulation) thế giới mở tại Việt Nam — trạng thái hiện tại: **prototype Android** (Godot 4.7, GL Compatibility).

## Trạng thái hiện tại

- **Player 3D**: `CharacterBody3D` điều khiển bằng joystick cảm ứng, camera bám theo theo hướng di chuyển, hồi phục vị trí khi rơi (`modules/player`).
- **Sprite HD-2D**: ngoại lệ texture Player (sprite billboard trong thế giới 3D) — theo quyết định trong `docs/decisions/0001-player-sprite.md`.
- **Sprite nhân vật dự phòng**: nhân vật 3D dựng từ primitive mesh (`presentation/player_visual`).
- **NPC**: 2 NPC dữ liệu mẫu (Lan, Minh) — lịch sinh hoạt theo GameClock, di chuyển theo tuyến đường, nút cảm ứng "NÓI CHUYỆN", hội thoại đơn giản (`modules/npc`).
- **Nhu cầu Player**: đói, khát, năng lượng tiêu hao theo GameClock; nút ĂN/UỐNG/NGHỈ (`modules/needs`).
- **Kinh tế**: số dư VND integer, API thu/chi (`modules/economy`); shop có danh mục hàng mẫu (`modules/shops`).
- **GameClock**: nguồn thời gian duy nhất (phút, đồng bộ save) — `core/services`.
- **World**: khu dân cư + hồ câu prototype, đường chính/ngang, nhà, cây, ranh giới, minimap pan/zoom (`world/`).
- **Tương tác trong bản đồ**: waypoint + tuyến đường dựng qua `WorldEvents` (`world/map`, `world/navigation`).
- **Tương tác chung**: HUD, Joystick, Needs, Player — giao tiếp qua EventBus contracts (`core/contracts`).

## Cấu trúc

```
GameDemo/
├── AGENTS.md, README.md, CHANGELOG.md, LICENSE, project.godot, .gitignore
├── docs/architecture/module_dependency_survey.md
├── docs/decisions/0001-player-sprite.md, 0002-player-module-split.md
├── docs/roadmap/ROADMAP.md
├── core/bootstrap/boot.gd
├── core/contracts/{player_events,world_events,job_events}.gd
├── core/events/{event_bus,core_events}.gd
├── core/services/{game_clock,save_coordinator}.gd
├── modules/{player,needs,jobs,shops,npc,economy}/
├── scenes/boot/boot.tscn
├── world/{map,navigation}/
├── presentation/{player_sprite,player_visual,hud}/
├── assets/characters/player/
├── icon.svg
└── .godot/, gdtoolkit/ (tooling)
```

## Chạy & kiểm tra

- Môi trường: Android + Godot Android (xem `AGENTS.md` §2).
- Mở project.godot, chạy `scenes/boot/boot.tscn`.
- Kiểm tra theo thang `AGENTS.md` §11: tại đây đã kiểm tra ở mức 2 (cú pháp, cấu trúc file, grep khớp đường dẫn); cần Godot Android khi có thể.

## Tài liệu

- `AGENTS.md` — luật phát triển (đọc trước khi thay đổi).
- `docs/architecture/module_dependency_survey.md` — bản khảo sát phụ thuộc module.
- `docs/decisions/` — các quyết định kiến trúc (ngoại lệ texture Player, tách module Player/Needs/HUD/Visual).
- `docs/roadmap/ROADMAP.md` — tiến độ đã làm + kế hoạch ngắn hạn.
- `CHANGELOG.md` — lịch sử thay đổi.
- README module: `core/{bootstrap,contracts,events,services}/README.md`, `modules/*/README.md`, `presentation/*/README.md`, `world/{README.md,map/README.md,navigation/README.md}`.
