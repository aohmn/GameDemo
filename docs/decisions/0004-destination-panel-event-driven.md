# 0004 — He thong chuyen map event-driven qua TravelPanel

**Ngay**: 2026-11-23
**Trang thai**: Da ap dung

## Boi canh

Cong chuyen map cu (`_on_transition_entered`) tu chuyen map ngay khi
Player buoc vao. Khong co xac nhan, khong co danh sach chon, khong the
mo rong sang nhieu diem den.

## Quyet dinh

Tach trach nhiem:
- **TransitionBuilder**: dung cong co hinh khoi that, phat GATE_ENTERED/GATE_EXITED.
  Khong biet diem den nao; khong tu chuyen map.
- **TravelPanel** (Presentation): lang nghe GATE_ENTERED -> hien bang chon.
  Phat DESTINATION_CHOSEN khi chon. Khong biet scene_path cu the ngoai payload.
- **Bootstrap**: lang nghe DESTINATION_CHOSEN -> _change_map().
  Bootstrap la noi duy nhat goi _change_map.
- **DestinationEvents**: contract sự kiện trong core/contracts/.
- **DestinationData**: Resource .tres cho moi diem den.
  Them diem den = them file, khong sua script.

## Hau qua

- Cong ho tro N diem den (Array[String] destination_ids trong GateSpec).
- Xoa TravelPanel -> game van chay, cong khong phan hoi, khong Parse Error.
- Joystick bi khoa khi bang mo (INPUT_LOCK_REQUESTED); mo khoa khi dong.
- Minimap danh dau cong bang diem tron vang khi GATE_ENTERED.
- Bootstrap doc TRAVEL_PANEL_SCRIPT_PATH tuy chon; thieu file = bo qua.
- TransitionBuilder.build() khong con nhan Callable on_enter.

## Thu tuc cap nhat de di chuyen cong

1. Sua `GateSpec.destination_ids` trong hub_layout.tres.
2. Them/sua file `.tres` tuong ung o world/map/data/.
Khong can sua script nao.
