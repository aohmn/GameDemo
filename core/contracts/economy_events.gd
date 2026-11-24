class_name EconomyEvents
extends RefCounted

## Hợp đồng sự kiện kinh tế và giao dịch tiền tệ Linh Thạch.

## Số dư tiền tệ biến động sau giao dịch.
## Payload: { "amount_change": int, "new_balance": int, "reason": String }
const BALANCE_CHANGED: String = "economy_balance_changed"

## Giao dịch thành công (ví dụ: bán cá, mua pháp bảo).
## Payload: { "transaction_id": String, "item_id": String, "price": int, "quantity": int }
const TRANSACTION_COMPLETED: String = "economy_transaction_completed"

## Giao dịch thất bại (ví dụ: không đủ tiền).
## Payload: { "item_id": String, "required_amount": int, "current_balance": int, "reason": String }
const TRANSACTION_FAILED: String = "economy_transaction_failed"

