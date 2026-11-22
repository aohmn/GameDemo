# Economy

EconomyService (autoload) là nguồn số dư VND duy nhất của Player trong prototype.

Số dư ban đầu: `STARTING_BALANCE_VND` = 250000 VND (`economy_service.gd`).

## API công khai
- `can_afford(amount_vnd: int) -> bool`
- `add_money(amount_vnd: int) -> bool`
- `spend_money(amount_vnd: int) -> bool`
- `serialize_state() -> Dictionary`, `deserialize_state(data) -> bool`
- Signal `balance_changed(new_balance_vnd: int)`
- Hằng `SAVE_ID = "player_economy"`

Mọi giá trị tiền dùng integer VND.

## Save
EconomyService tự khai báo `SAVE_ID`; `core/bootstrap/boot.gd` đăng ký với
`SaveCoordinator` qua `register_participant(EconomyService.SAVE_ID,
EconomyService)`. Module không tự quét group và không phụ thuộc module khác.

## Giới hạn
Chưa có giao dịch nhiều module/TransactionCoordinator; không thực hiện mua hàng
cho đến khi giao dịch được tích hợp atomic với Inventory. Chưa có UI ví.
