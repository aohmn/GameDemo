class_name CultivationEvents
extends RefCounted

## Hợp đồng sự kiện tu luyện và cảnh giới (Cultivation).

## Tu vi thay đổi (hấp thu linh khí, luyện hóa...).
## Payload: { "amount_change": int, "current_exp": int, "reason": String }
const EXP_GAINED: String = "cultivation_exp_gained"

## Tăng tầng tu vi trong cùng một cảnh giới (tầng 1 -> tầng 9).
## Payload: { "realm_index": int, "realm_name": String, "old_layer": int, "new_layer": int }
const LAYER_UPGRADED: String = "cultivation_layer_upgraded"

## Đột phá đại cảnh giới thành công.
## Payload: { "old_realm_index": int, "new_realm_index": int, "new_realm_name": String }
const BREAKTHROUGH_SUCCESS: String = "cultivation_breakthrough_success"

## Đột phá đại cảnh giới thất bại.
## Payload: { "realm_index": int, "realm_name": String, "reason": String }
const BREAKTHROUGH_FAILED: String = "cultivation_breakthrough_failed"
