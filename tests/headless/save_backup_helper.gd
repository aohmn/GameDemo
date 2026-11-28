extends RefCounted
## Sao lưu và khôi phục các file save *.cfg trong user:// khi chạy test headless.

const BACKUP_DIR: String = "user://_test_save_backup/"


static func backup_user_saves() -> void:
	DirAccess.make_dir_recursive_absolute(BACKUP_DIR)
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	dir.list_dir_begin()
	var fn: String = dir.get_next()
	while not fn.is_empty():
		if not dir.current_is_dir() and fn.ends_with(".cfg"):
			DirAccess.copy_absolute("user://" + fn, BACKUP_DIR + fn)
		fn = dir.get_next()
	dir.list_dir_end()


static func restore_user_saves() -> void:
	var user_dir := DirAccess.open("user://")
	if user_dir != null:
		user_dir.list_dir_begin()
		var fn: String = user_dir.get_next()
		while not fn.is_empty():
			if not user_dir.current_is_dir() and fn.ends_with(".cfg"):
				DirAccess.remove_absolute("user://" + fn)
			fn = user_dir.get_next()
		user_dir.list_dir_end()

	var bak_dir := DirAccess.open(BACKUP_DIR)
	if bak_dir != null:
		bak_dir.list_dir_begin()
		var fn: String = bak_dir.get_next()
		while not fn.is_empty():
			if not bak_dir.current_is_dir() and fn.ends_with(".cfg"):
				DirAccess.copy_absolute(BACKUP_DIR + fn, "user://" + fn)
				DirAccess.remove_absolute(BACKUP_DIR + fn)
			fn = bak_dir.get_next()
		bak_dir.list_dir_end()
