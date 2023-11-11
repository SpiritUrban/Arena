# Наследование от CharacterBody3D для создания 3D персонажа.
extends CharacterBody3D

# Инициализация ссылки на камеру, когда узел добавлен в сцену.
@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer
@onready var muzzle_flash = $Camera3D/Pistol/MuzzleFlash
@onready var raycast = $Camera3D/RayCast3D

var health = 3

# Определение констант для скорости движения и силы прыжка.
const SPEED = 10.0
const JUMP_VELOCITY = 10.0

# Получение значения гравитации из настроек проекта.
# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 20.0

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

# Функция, вызываемая при инициализации узла.
func _ready():
	if not is_multiplayer_authority(): return
	# Устанавливаем режим мыши на "захваченный", чтобы курсор был скрыт.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true

# Функция обработки входящих событий.
func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	# Обрабатываем движение мыши для управления вращением.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("shoot") \
			and anim_player.current_animation != "shoot":
		play_shoot_effects.rpc()
		if raycast.is_colliding():
			var hit_player = raycast.get_collider()
			hit_player.receive_damage.rpc_id(hit_player.get_multiplayer_authority())
			
# Функция, вызываемая на каждом физическом шаге обновления.
func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Применяем гравитацию, если персонаж не на полу.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Обрабатываем прыжок.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Получаем направление ввода и обрабатываем движение/торможение.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	if anim_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		anim_player.play("move")
	else:
		anim_player.play("idle")

	# Обновляем положение персонажа на основе его скорости.
	move_and_slide()

@rpc("call_local")
func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
	muzzle_flash.restart()
	muzzle_flash.emitting = true

@rpc("any_peer")
func receive_damage():
	health -= 1
	if health <= 0:
		health = 3
		position = Vector3.ZERO
	#health_changed.emit(health)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "shoot":
		anim_player.play("idle")
