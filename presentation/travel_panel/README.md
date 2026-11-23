# TravelPanel — Bang chon diem den

## Muc dich
Hien bang UI khi Player buoc vao vung cong chuyen map.
Player chon diem den thi moi chuyen; bam "O lai" hoac roi cong thi dong bang.

## Thanh phan
- `travel_panel.gd`: class `TravelPanel extends Control`.
  Chi lang nghe event, chi phat event. KHONG chua logic chuyen map.

## Lam cho optional
Neu xoa thu muc `presentation/travel_panel/`, game van chay. Bootstrap tu
bo qua khi `TRAVEL_PANEL_SCRIPT_PATH` khong ton tai. Cong khong phan hoi
nhung khong co Parse Error.

## API (Event, qua EventBus)

### Nhan
- `DestinationEvents.GATE_ENTERED` — hien bang, dien danh sach diem den.
- `DestinationEvents.GATE_EXITED` — dong bang neu la cong dang hien.

### Phat
- `DestinationEvents.DESTINATION_CHOSEN` — khi chon diem den (Bootstrap xu ly).
- `DestinationEvents.INPUT_LOCK_REQUESTED { locked: bool }` — khoa joystick khi bang mo.

## Phu thuoc
- `core/events` (EventBus), `core/contracts` (DestinationEvents).
- Khong import code world, khong biet scene_path cu the cho den khi nhan GATE_ENTERED.

## Them diem den moi
Tao file `world/map/data/dest_<id>.tres` dung script `DestinationData`;
them `id` vao `GateSpec.destination_ids[]` trong hub_layout.tres.
Khong sua script.
