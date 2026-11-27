extends RefCounted

## Bộ dựng hình kiến trúc tiên hiệp bằng SurfaceTool: mái cong vút, mái tròn, cầu đá vòm.
## Chỉ sinh Mesh; vật liệu và vị trí do builder quyết định.


## Mái cong hình chữ nhật (nửa rộng hw >= nửa sâu hd): sống mái dài, dốc lõm, bốn góc hất lên.
static func roof_mesh(hw: float, hd: float, height: float, upturn: float, curve: float = 1.7, n: int = 14) -> ArrayMesh:
	var half_w: float = maxf(hw, hd)
	var half_d: float = minf(hw, hd)
	var swap: bool = hd > hw
	var ridge: float = half_w - half_d
	var grid: Array = []
	for i in range(n + 1):
		var col: Array = []
		for j in range(n + 1):
			var x: float = (float(i) / n * 2.0 - 1.0) * half_w
			var z: float = (float(j) / n * 2.0 - 1.0) * half_d
			var dx: float = maxf(absf(x) - ridge, 0.0) / half_d
			var s: float = clampf(maxf(dx, absf(z) / half_d), 0.0, 1.0)
			var y: float = height * pow(1.0 - s, curve)
			var cx: float = smoothstep(0.6, 1.0, absf(x) / half_w)
			var cz: float = smoothstep(0.6, 1.0, absf(z) / half_d)
			y += upturn * cx * cz + upturn * 0.2 * pow(s, 5.0)
			col.append(Vector3(z, y, x) if swap else Vector3(x, y, z))
		grid.append(col)
	return _grid_to_mesh(grid, n, 0.07)


## Mái tròn / bát giác (lọng đình): lathe quanh trục Y, mép hất lên.
static func round_roof_mesh(radius: float, height: float, upturn: float, curve: float = 1.6, sides: int = 16, rings: int = 8) -> ArrayMesh:
	var grid: Array = []
	for i in range(sides + 1):
		var a: float = -float(i) / sides * TAU
		var col: Array = []
		for j in range(rings + 1):
			var s: float = float(j) / rings
			var y: float = height * pow(1.0 - s, curve) + upturn * pow(s, 6.0)
			col.append(Vector3(cos(a) * radius * s, y, sin(a) * radius * s))
		grid.append(col)
	return _grid_to_mesh(grid, rings, 0.06, sides)


static func _grid_to_mesh(grid: Array, n_j: int, thickness: float, n_i: int = -1) -> ArrayMesh:
	var n_i_eff: int = n_i if n_i > 0 else grid.size() - 1
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(0)
	var down := Vector3(0.0, -thickness, 0.0)
	for i in range(n_i_eff):
		for j in range(n_j):
			var a: Vector3 = grid[i][j]
			var b: Vector3 = grid[i + 1][j]
			var c: Vector3 = grid[i + 1][j + 1]
			var d: Vector3 = grid[i][j + 1]
			for v in [a, c, d, a, b, c]:
				st.add_vertex(v)
			for v in [a + down, d + down, c + down, a + down, c + down, b + down]:
				st.add_vertex(v)
	for i in range(n_i_eff):
		_fascia(st, grid[i][n_j], grid[i + 1][n_j], down)
		_fascia(st, grid[i + 1][0], grid[i][0], down)
	for j in range(n_j):
		_fascia(st, grid[0][j + 1], grid[0][j], down)
		_fascia(st, grid[n_i_eff][j], grid[n_i_eff][j + 1], down)
	st.generate_normals()
	return st.commit()


static func _fascia(st: SurfaceTool, p: Vector3, q: Vector3, down: Vector3) -> void:
	for v in [p, q + down, q, p, p + down, q + down]:
		st.add_vertex(v)


## Cầu đá vòm: dọc theo trục X, dài length, rộng width, vòm cao rise, dày thickness. Gốc ở mặt cầu hai đầu (y=0).
static func arch_bridge_mesh(length: float, width: float, rise: float, thickness: float, n: int = 16) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var hw: float = width * 0.5
	for i in range(n):
		var x0: float = (float(i) / n - 0.5) * length
		var x1: float = (float(i + 1) / n - 0.5) * length
		var t0: float = _arch_y(x0, length, rise)
		var t1: float = _arch_y(x1, length, rise)
		var b0: float = t0 - thickness
		var b1: float = t1 - thickness
		_quad(st, Vector3(x0, t0, -hw), Vector3(x0, t0, hw), Vector3(x1, t1, hw), Vector3(x1, t1, -hw))
		_quad(st, Vector3(x0, b0, hw), Vector3(x0, b0, -hw), Vector3(x1, b1, -hw), Vector3(x1, b1, hw))
		_quad(st, Vector3(x0, t0, hw), Vector3(x0, b0, hw), Vector3(x1, b1, hw), Vector3(x1, t1, hw))
		_quad(st, Vector3(x1, t1, -hw), Vector3(x1, b1, -hw), Vector3(x0, b0, -hw), Vector3(x0, t0, -hw))
	st.generate_normals()
	return st.commit()


static func _arch_y(x: float, length: float, rise: float) -> float:
	var u: float = x / (length * 0.5)
	return rise * (1.0 - u * u)


static func arch_height_at(x: float, length: float, rise: float) -> float:
	return _arch_y(x, length, rise)


static func _quad(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	for v in [a, c, b, a, d, c]:
		st.add_vertex(v)
