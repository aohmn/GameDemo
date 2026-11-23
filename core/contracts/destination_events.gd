class_name DestinationEvents
extends RefCounted
## Hop dong su kien cho he thong chon diem den va chuyen map.
## Cong khong tu chuyen map; Bootstrap lang nghe DESTINATION_CHOSEN roi phat MAP_CHANGE_REQUESTED.

## Player buoc vao vung cong. UI hien bang chon diem den.
## Payload: { "gate_id": String, "destinations": Array[Dictionary] }
## moi dict: { "id": String, "display_name": String, "scene_path": String,
##             "spawn_id": String, "unlocked": bool }
const GATE_ENTERED: StringName = &"destination_gate_entered"

## Player roi vung cong (body_exited). UI dong bang.
## Payload: { "gate_id": String }
const GATE_EXITED: StringName = &"destination_gate_exited"

## Player chon mot diem den. Bootstrap nhan va phat MAP_CHANGE_REQUESTED.
## Payload: { "gate_id": String, "destination_id": String,
##            "scene_path": String, "spawn_id": String }
const DESTINATION_CHOSEN: StringName = &"destination_destination_chosen"

## Khoa / mo khoa dieu khien joystick de UI travel panel co the tam dung di chuyen.
## Payload: { "locked": bool }
const INPUT_LOCK_REQUESTED: StringName = &"destination_input_lock_requested"
