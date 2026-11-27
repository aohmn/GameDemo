# presentation/fishing_battle_ui

Màn hình đấu cá riêng (Presentation thuần).

- Lắng nghe `EventBus`: `STATE_CHANGED` (`FIGHT` -> hiện, kết thúc -> ẩn), `FIGHT_UPDATE`, `FISH_CAUGHT`, `FISH_ESCAPED`.
- Gọi `FishingAPI`: `set_rod_steer(float)`, `reel(bool)`, `set_drag(float)`.
- Chạy độc lập: `presentation/fishing_battle_ui/scenes/dev.tscn`.
