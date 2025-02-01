extends CharacterBody3D
class_name CustomCarController

@export var s: Curve
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@onready var VEHICLE_MODEL: Node3D = $"vehicle-suv3"
@onready var forward_ray: RayCast3D = $RayCast3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var CURRENT_MPH: float = 3.0
@onready var ACCELERATION: float = 0.2

var facing_dir

# we just want the rotation to know where we're facing..
func set_facing_dir():
	#print(forward_ray.get_global_transform().basis)
	facing_dir = forward_ray.transform.basis.x
	

func _ready():
	set_facing_dir()
	pass


func rotate_model_to_direction(delta, dir: Vector3):
	var rotation_to_do = lerp(0.0, - dir.x, s.sample(delta))
	
	VEHICLE_MODEL.rotate_y(rotation_to_do)
	forward_ray.rotate_object_local(Vector3.FORWARD, rotation_to_do)
	collision_shape_3d.rotate_y(rotation_to_do)
	
	set_facing_dir()
	pass

func get_current_speed() -> Vector3:
	return velocity

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	
	
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		rotate_model_to_direction(delta, direction)

	if facing_dir:
		# https://docs.godotengine.org/en/latest/tutorials/3d/using_transforms.html
		velocity.z = - facing_dir.x * CURRENT_MPH
		velocity.x = facing_dir.z * CURRENT_MPH

	#else:
		#velocity.x = move_toward(velocity.x, CURRENT_MPH, SPEED)
		#velocity.z = move_toward(velocity.z, CURRENT_MPH, SPEED)

	move_and_slide()
