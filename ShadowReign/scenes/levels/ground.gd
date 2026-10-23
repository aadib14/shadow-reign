
extends StaticBody2D

# SHADOW REIGN - GROUND V0.3

# Warna default Ground (Stage 1).
# Setiap instance bisa mempunyai warna berbeda melalui Inspector.
@export var ground_color: Color = Color("#55515f")


func _ready() -> void:
	# Membuat tanah berbentuk persegi panjang.
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-320, -20),
		Vector2(320, -20),
		Vector2(320, 20),
		Vector2(-320, 20)
	])

	# Menggunakan warna sesuai pengaturan instance Ground.
	$Polygon2D.color = ground_color
