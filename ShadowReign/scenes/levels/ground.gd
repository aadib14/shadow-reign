
extends StaticBody2D

# SHADOW REIGN - GROUND V0.1

func _ready() -> void:

	# Membuat tanah berbentuk persegi panjang
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-320, -20),
		Vector2(320, -20),
		Vector2(320, 20),
		Vector2(-320, 20)
	])

	# Memberikan warna abu-abu gelap
	$Polygon2D.color = Color("#55515f")
