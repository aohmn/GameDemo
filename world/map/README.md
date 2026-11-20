# World Map — Two Map Travel Prototype

## Mục đích

Prototype kiểm tra hai bản đồ độc lập và cơ chế di chuyển qua lại giữa
các Location bằng vùng chuyển cảnh.

## Các map

### Khu dân cư

- Scene: `scenes/map_root.tscn`
- Map type: `residential`
- Spawn Point: `residential_entry`
- Điểm chuyển map nằm ở cuối đường.
- Đích đến: Hồ câu.

### Hồ câu

- Scene: `scenes/fishing_lake_map.tscn`
- Map type: `fishing_lake`
- Spawn Point: `lake_entry`
- Có hồ nước, bờ hồ, đường đất và bến câu.
- Đích đến: Khu dân cư.

## Map Transition

Map Controller tạo một Area3D tại vị trí chuyển cảnh.

Trên vùng chuyển cảnh có Label3D hiển thị tên địa điểm đích.

Khi Player đi vào Area3D:

1. Kiểm tra Player và scene đích.
2. Ghi Spawn Point ID đích vào metadata của SceneTree.
3. Chuyển sang scene đích.
4. Map Controller mới đọc Spawn Point ID.
5. Đặt Player tại vị trí xuất hiện của map mới.

Tên đích và scene đích được cấu hình riêng trên từng map scene.

## Thành phần dùng chung

- `Map3DController`: dựng môi trường và điều phối chuyển map.
- `Player3DController`: chuyển động vật lý.
- `VirtualJoystick`: điều khiển cảm ứng.
- `SpringArm3D` và `Camera3D`: camera cố định góc nghiêng.

Hai map dùng chung cấu trúc Player, Camera và Joystick.

## Đồ họa

- Dựng bằng Primitive Mesh.
- Vật liệu StandardMaterial3D.
- Không sử dụng texture.

## Kiểm tra trên Godot Android

1. Mở project bằng Godot Android.
2. Chạy Boot scene.
3. Xác nhận map Khu dân cư xuất hiện.
4. Di chuyển đến bảng Hồ câu.
5. Đi vào vùng chuyển cảnh.
6. Xác nhận Hồ câu được tải.
7. Xác nhận Player xuất hiện tại bờ hồ.
8. Đi đến bảng Khu dân cư.
9. Xác nhận có thể quay lại map đầu.
10. Kiểm tra joystick và camera ở cả hai map.

## Giới hạn prototype

- Chưa có Location Manager.
- Chưa có Spawn Point Registry độc lập.
- Spawn Point hiện được cấu hình trong Map Controller.
- Chưa lưu trạng thái từng map.
- Chưa tích hợp SaveCoordinator.
- Chưa kiểm tra runtime trên Godot Android.
