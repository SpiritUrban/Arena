# Наследование от CharacterBody3D для создания 3D персонажа.
extends CharacterBody3D

# Инициализация ссылки на камеру, когда узел добавлен в сцену.
@onready var camera = $Camera3D
@onready var anim_player = $AnimationPlayer


# Определение констант для скорости движения и силы прыжка.
const SPEED = 10.0
const JUMP_VELOCITY = 10.0

# Получение значения гравитации из настроек проекта.
# var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity = 20.0

# Функция, вызываемая при инициализации узла.
func _ready():
	# Устанавливаем режим мыши на "захваченный", чтобы курсор был скрыт.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Функция обработки входящих событий.
func _unhandled_input(event):
	# Обрабатываем движение мыши для управления вращением.
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * .005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if Input.is_action_just_pressed("shoot") \
			and anim_player.current_animation != "shoot":
		play_shoot_effects()
# Функция, вызываемая на каждом физическом шаге обновления.
func _physics_process(delta):
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

func play_shoot_effects():
	anim_player.stop()
	anim_player.play("shoot")
