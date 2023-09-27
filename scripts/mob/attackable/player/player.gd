class_name Player extends Attackable

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var visuals: Node3D = $Visuals
@onready var camera_points : Node3D = $CameraPoints

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera : Camera3D = $CameraPivot/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	if position.y <= -10: # handle falling off the map for now
		position.y = 1

func _input(_event: InputEvent):
	if Input.is_action_just_pressed("quit"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		print("quit")

	if Input.is_action_just_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("click")

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		print("Mouse Click/Unclick at: ", event.position)
		pass

	if event is InputEventMouseMotion:
		pass

func _physics_process(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		handle_inputs()

	move_and_slide()

func handle_inputs():
	handle_attack()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle movement.

	var input_dir = Input.get_vector("left", "right", "forward", "back")
	if(input_dir): print("input dir: ", input_dir)
	var direction = (camera.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		visuals.look_at(position + direction)
		visuals.rotation.x = 0
		visuals.rotation.z = 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func handle_attack():
	if Input.is_action_just_pressed("attack"):
		# GameUI.instance.status_bars.set_health(72, 100)
		var space = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(camera.global_position,
			camera.global_position - camera.global_transform.basis.z * 100, PhysicsUtils.arr_to_collision_mask(
				[ PhysicsUtils.ENEMY_MASK ]
			))
		var collision = space.intersect_ray(query)
		if collision:
			print("Attacked:", collision.collider.name)
			_attack(collision.collider)
		else:
			print("Collide with:", "nuthin")