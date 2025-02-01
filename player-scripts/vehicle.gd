extends CharacterBody3D
class_name CustomCarController

# You're expected to provide a ray pointing in the 'forward' direction
# for your vehicle
# ray_x_basis will be used to track the direction it's pointing
# So that we don't have to access the ray every time we want this info
@onready var forward_ray: RayCast3D = $RayCast3D
#var ray_x_basis

# This needs to be renamed, but it's the curve at which we're rotating our vehicle
@export var s: Curve

# OUR VEHICLE CAN JUMP????
@export var JUMP_VELOCITY = 4.5


@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

# vehicle configuration that should be put into a resource honestly..
@export var SPEED = 5.0
@onready var CURRENT_MPH: float = 3.0
@onready var TRACTION: float = 0.1

# TODO: acceleration should be a curve
@onready var ACCELERATION: float = 0.2

@onready var VEHICLE_MODEL: Node3D = $"vehicle-suv3"


func get_ray_x_basis(ray: RayCast3D):
	# ray could be null
	if ray:
		return ray.transform.basis.x


func rotate_model_to_direction(delta, dir: Vector3):
	#var rotation_to_do = lerp(0.0, - dir.x, s.sample(delta))
	var rotation_to_do = move_toward(0.0, - dir.x, 0.1 * s.sample(delta))
	
	VEHICLE_MODEL.rotate_y(rotation_to_do)
	forward_ray.rotate_object_local(Vector3.FORWARD, rotation_to_do)
	collision_shape_3d.rotate_y(rotation_to_do)
	
	pass

func get_current_speed():
	return CURRENT_MPH

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_pressed("ui_up"):
		CURRENT_MPH = move_toward(CURRENT_MPH, CURRENT_MPH + 1, ACCELERATION)
	elif Input.is_action_pressed("ui_down"):
		CURRENT_MPH = move_toward(CURRENT_MPH, 0, ACCELERATION)
	
	if direction:
		rotate_model_to_direction(delta, direction)

	var ray_x_basis = get_ray_x_basis(forward_ray)
	if ray_x_basis:
		# https://docs.godotengine.org/en/latest/tutorials/3d/using_transforms.html
		# NO, the flipped X / Z are not incorrect
		# SWITCHING these or changing this without understanding the consequences... is DIRE
		velocity.z = move_toward(velocity.z, - ray_x_basis.x * CURRENT_MPH, TRACTION)
		velocity.x = ray_x_basis.z * CURRENT_MPH

	move_and_slide()
