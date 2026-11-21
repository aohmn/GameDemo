# Economy

EconomyService là nguồn số dư VND duy nhất của Player trong prototype.

API: `can_afford(amount_vnd)`, `add_money(amount_vnd)`, `spend_money(amount_vnd)`, `serialize_state()`, `deserialize_state()`.

Mọi giá trị tiền dùng integer VND. Chưa có giao dịch nhiều module/TransactionCoordinator; không thực hiện mua hàng cho đến khi giao dịch được tích hợp atomic với Inventory.
