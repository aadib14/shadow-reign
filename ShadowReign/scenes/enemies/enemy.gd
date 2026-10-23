
extends CharacterBody2D

# ==================================
# SHADOW REIGN - ABYSS SOLDIER V0.1
# ==================================

@export var GRAVITY: float = 980.0

# HP musuh (untuk sistem combat berikutnya)
var health: int = 100
var original_color: Color = Color("#8956D8")
var flash_id: int = 0
var knockback_velocity: float = 0.0
var knockback_jump: float = -140.0
var target: Node2D = null
var chase_speed: float = 85.0
var stop_distance: float = 38.0
var is_attacking: bool = false
var attack_hit_bodies: Array[Node2D] = []
var attack_cooldown: float = 1.0
var attack_timer: float = 0.0



@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_collision: CollisionShape2D = $AttackArea/CollisionShape2D


func _ready() -> void:

	# Membuat bentuk musuh otomatis
	$Polygon2D.polygon = PackedVector2Array([
		Vector2(-12, -24),
		Vector2(12, -24),
		Vector2(12, 24),
		Vector2(-12, 24)
	])
	
	
	# Bentuk visual tebasan Abyss Soldier
	$AttackArea/SlashVisual.polygon = PackedVector2Array([
		Vector2(-18, -14),
		Vector2(0, -20),
		Vector2(18, -14),
		Vector2(12, 0),
		Vector2(18, 14),
		Vector2(0, 20),
		Vector2(-18, 14),
		Vector2(-12, 0)
	])

	$AttackArea/SlashVisual.color = Color("#B388FF")
	$AttackArea/SlashVisual.visible = false

	# Warna ungu Abyss Soldier
	$Polygon2D.color = Color("#8956D8")
	

func _physics_process(delta: float) -> void:
	
	# Hentikan AI ketika Kael sudah kalah
	if is_instance_valid(target) and target.get("is_dead") == true:
		target = null
		velocity.x = 0.0
		knockback_velocity = 0.0

		attack_collision.set_deferred("disabled", true)
		$AttackArea/SlashVisual.visible = false
		is_attacking = false


	# Musuh mengalami gravitasi
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Musuh belum bisa berjalan sendiri

	# Jika sedang terdorong, prioritaskan Knockback
	if abs(knockback_velocity) > 0.1:
		velocity.x = knockback_velocity
	else:
		velocity.x = 0.0

		# Kejar Kael jika target masih valid
		if is_instance_valid(target):
			var distance_x: float = target.global_position.x - global_position.x

			if abs(distance_x) > stop_distance:
				velocity.x = sign(distance_x) * chase_speed

	# Perlahan kurangi kekuatan Knockback
	knockback_velocity = move_toward(knockback_velocity, 0.0, 800.0 * delta)
	
	# Kurangi waktu cooldown serangan
	attack_timer = maxf(attack_timer - delta, 0.0)

	# Serang ketika Kael cukup dekat
	if is_instance_valid(target) and not is_attacking:
		var distance_to_target: float = global_position.distance_to(target.global_position)

		if distance_to_target <= stop_distance and attack_timer <= 0.0:
			attack_timer = attack_cooldown
			enemy_attack()

	move_and_slide()

	
# ==================================
# ENEMY DAMAGE SYSTEM
# ==================================

func take_damage(amount: int) -> void:

	# Mengurangi HP musuh
	health -= amount
	health_bar.value = health
	hit_flash()

	# Menampilkan HP tersisa
	print("Enemy terkena damage: ", amount)
	print("Sisa HP Enemy: ", health)

	# Jika HP habis, musuh kalah
	if health <= 0:
		die()

func die() -> void:

	print("ABYSS SOLDIER DEFEATED!")

	# Menghapus musuh dari arena
	queue_free()
	


func hit_flash() -> void:
	flash_id += 1
	var current_flash: int = flash_id

	$Polygon2D.color = Color.WHITE

	await get_tree().create_timer(0.1).timeout

	if current_flash == flash_id:
		$Polygon2D.color = original_color

func apply_knockback(attacker_x: float) -> void:
	if global_position.x > attacker_x:
		knockback_velocity = 180.0
	else:
		knockback_velocity = -180.0
	
	velocity.y = knockback_jump


func enemy_attack() -> void:
	if is_attacking:
		return

	is_attacking = true
	attack_hit_bodies.clear()
	print("ABYSS SOLDIER ATTACK!")
	
	# Arahkan tebasan ke posisi Kael
	if is_instance_valid(target):
		if target.global_position.x < global_position.x:
			$AttackArea.position.x = -24.0
		else:
			$AttackArea.position.x = 24.0

	# Aktifkan hitbox serangan
	attack_collision.set_deferred("disabled", false)
	$AttackArea/SlashVisual.visible = true
	
	# Tunggu Godot memperbarui tabrakan hitbox
	await get_tree().physics_frame

	# Periksa Kael yang sudah berada dalam area serangan
	for body in $AttackArea.get_overlapping_bodies():
		_on_attack_area_body_entered(body)

	# Durasi serangan
	await get_tree().create_timer(0.2).timeout

	# Matikan kembali hitbox
	attack_collision.set_deferred("disabled", true)
	$AttackArea/SlashVisual.visible = false

	is_attacking = false
	print("ENEMY ATTACK FINISHED")

func _on_detection_area_body_entered(body: Node2D) -> void:
	var detected_name: String = String(body.name).strip_edges().to_lower()

	print("NAMA ASLI: [", body.name, "]")
	print("NAMA SETELAH DIPROSES: [", detected_name, "]")
	print("APAKAH COCOK? ", detected_name == "playerv2")

	
	if detected_name == "playerv2":
		# Jangan targetkan Kael yang sudah kalah
		if body.get("is_dead") == true:
			return

		target = body
		print("ABYSS SOLDIER: KAEL TERDETEKSI!")


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		print("ABYSS SOLDIER: KAEL KELUAR DARI JANGKAUAN!")




func _on_attack_area_body_entered(body: Node2D) -> void:
	if not is_attacking:
		return

	if body != target:
		return

	if body in attack_hit_bodies:
		return

	if body.has_method("take_damage"):
		attack_hit_bodies.append(body)
		body.take_damage(10)
		print("ABYSS SOLDIER BERHASIL MENYERANG KAEL!")
