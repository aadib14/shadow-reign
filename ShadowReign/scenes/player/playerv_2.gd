
extends CharacterBody2D

@export var arena_left: float = 20.0
@export var arena_right: float = 620.0
@export var max_health: int = 100

var health: int = 100
var is_dead: bool = false


@export var SPEED: float = 220.0
@export var JUMP_VELOCITY: float = -380.0
@export var GRAVITY: float = 980.0

# Sistem combat
var is_attacking: bool = false
var hit_enemies: Array[Node2D] = []


@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_collision: CollisionShape2D = $AttackHitbox/CollisionShape2D


func _ready() -> void:

	# Visual karakter
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-12, -24),
		Vector2(12, -24),
		Vector2(12, 24),
		Vector2(-12, 24)
	])

	$Polygon2D.color = Color.RED
	
	# ==================================
	# VISUAL TEBASAN KAEL
	# ==================================

	$AttackHitbox/SlashVisual.polygon = PackedVector2Array([
		Vector2(-20, -15),
		Vector2(0, -22),
		Vector2(20, -15),
		Vector2(14, 0),
		Vector2(20, 15),
		Vector2(0, 22),
		Vector2(-20, 15),
		Vector2(-12, 0)
	])

	# Warna efek tebasan
	$AttackHitbox/SlashVisual.color = Color("#FFD54F")

	# Sembunyikan visual ketika belum menyerang
	$AttackHitbox/SlashVisual.visible = false


	# Hitbox awal tidak aktif
	attack_collision.set_deferred("disabled", true)


func _physics_process(delta: float) -> void:
	
	if is_dead:
		velocity.x = 0.0
		velocity.y += GRAVITY * delta
		
		move_and_slide()
		global_position.x = clampf(
		global_position.x,
		arena_left,
		arena_right
	)
	
		return


	# Gravitasi
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Lompat
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED

		# Hitbox mengikuti arah hadap Kael
		$AttackHitbox.position.x = 32 if direction > 0 else -32

	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			SPEED * 10.0 * delta
		)

	# Input serangan
	if Input.is_action_just_pressed("attack"):
		attack()

	move_and_slide()


# ==================================
# ATTACK SYSTEM
# ==================================


func attack() -> void:

	# Mencegah serangan bertumpuk

	if is_dead or is_attacking:
		return

	is_attacking = true
	
	hit_enemies.clear()


	print("KAEL ATTACK!")

	# Aktifkan hitbox
	attack_collision.set_deferred("disabled", false)

	# Tampilkan efek tebasan
	$AttackHitbox/SlashVisual.visible = true
	
	# Tunggu physics memperbarui area serangan
	await get_tree().physics_frame

	# Periksa semua objek yang sudah berada di dalam hitbox
	for body in $AttackHitbox.get_overlapping_bodies():
		_on_attack_hitbox_body_entered(body)


	# Durasi serangan
	await get_tree().create_timer(0.2).timeout

	# Matikan hitbox
	attack_collision.set_deferred("disabled", true)

	# Sembunyikan efek tebasan
	$AttackHitbox/SlashVisual.visible = false

	is_attacking = false

	print("ATTACK FINISHED")

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	# Jangan pernah melukai diri sendiri
	if body == self:
		return

	if not is_attacking:
		return

	if not body.has_method("take_damage"):
		return

	if body in hit_enemies:
		return

	hit_enemies.append(body)

	if body.has_method("apply_knockback"):
		body.apply_knockback(global_position.x)

	body.take_damage(25)

	print("TEBASAN KAEL MENGENAI MUSUH!")


func take_damage(amount: int) -> void:
	if is_dead:
		return

	health = maxi(health - amount, 0)
	health_bar.value = health

	print("KAEL TERKENA DAMAGE: ", amount)
	print("SISA HP KAEL: ", health)

	if health <= 0:
		die()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	$Polygon2D.color = Color("#555555")

	print("KAEL DEFEATED!")

	var game_over_ui = get_parent().get_node_or_null("GameOverUI")

	if game_over_ui != null:
		game_over_ui.show()

		var game_over_label = game_over_ui.get_node_or_null("GameOverLabel")
		var retry_button = game_over_ui.get_node_or_null("RetryButton")

		if game_over_label != null:
			game_over_label.show()

		if retry_button != null:
			retry_button.show()
			print("RETRY BUTTON BERHASIL DITAMPILKAN!")
		else:
			print("ERROR: RetryButton tidak ditemukan!")
	else:
		print("ERROR: GameOverUI tidak ditemukan!")
