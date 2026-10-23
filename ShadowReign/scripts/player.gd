
extends CharacterBody2D

# ==================================
# SHADOW REIGN - PLAYER SYSTEM V0.1
# ==================================

@export var SPEED: float = 220.0
@export var JUMP_VELOCITY: float = -380.0
@export var GRAVITY: float = 980.0


# Dipanggil saat karakter pertama muncul
func _ready() -> void:

	# Membuat bentuk karakter otomatis
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-12, -24),
		Vector2(12, -24),
		Vector2(12, 24),
		Vector2(-12, 24)
	])

	# Warna karakter merah
	$Polygon2D.color = Color.RED


# Sistem pergerakan karakter
func _physics_process(delta: float) -> void:

	# Gravitasi
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Gerakan kiri dan kanan
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Menjalankan gerakan
	move_and_slide()
