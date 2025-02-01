extends CharacterBody2D

# this means you need to have a sprite2d attached as a child of the
# characterbody2d
# I think this is a sensible assumption?
# MAAYBE we could move this somewhere else but.... WHATEVER
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var dash_speed: float = 3000.0
@export var idle_sprite: Texture2D
@export var dashing_sprite: Texture2D
@export var running_sprite: Texture2D
@export var airborne_sprite: Texture2D

@onready var player_states = {
	"idle": {
		"speed": 300.0,
		"jump_velocity": -400.0,
		"sprite": idle_sprite
	},
	"dashing": {
		"speed": 300.0,
		"jump_velocity": -400.0,
		"sprite": dashing_sprite
	},
	"running": {
		"speed": 700.0,
		"jump_veleocity": -400.0,
		"sprite": running_sprite,
	},
	"airborne": {
		"speed": 300.0,
		"jump_velocity": -400.0,
		"sprite": airborne_sprite
	}
}

var current_state = "idle"

func get_current_state_opts():
	return player_states[current_state]

func set_current_state(state: String):
	# Don't redo the stuff after if we've already done it...
	if current_state == state:
		return
	
	current_state = state
	sprite_2d.texture = get_current_state_opts()["sprite"]



func _physics_process(delta: float) -> void:
	var current_state_opts = get_current_state_opts()
	
	match current_state:
		"idle": handle_idle_state(delta, current_state_opts)
		"dashing": handle_dashing_state(delta, current_state_opts)
		"airborne": handle_airborne_state(delta, current_state_opts)

	move_and_slide()



func handle_airborne_state(delta, current_state_opts) -> void:
	if velocity.x == 0 and is_on_floor():
		set_current_state("idle")
		return
	
	
	var SPEED = current_state_opts["speed"]
	var JUMP_VELOCITY = current_state_opts["jump_velocity"]
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		set_current_state("airborne")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# TODO: MOVE THIS UP
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		set_current_state("dashing")
		print('just pressed left or right')
		velocity.x = direction * SPEED * dash_speed
	
	if direction:
		print('youre holding a dir!!')
		#velocity.x = direction * SPEED
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	pass


# during a DASH, a player CAN press their DASH again
# this will give them another DASH in the direction they input
# if they hold in the DASH direction while DASH is ending
# then players will enter RUN state
func handle_dashing_state(delta, current_state_opts) -> void:
	if velocity.x == 0 and is_on_floor():
		set_current_state("idle")
		return
	
	
	var SPEED = current_state_opts["speed"]
	var JUMP_VELOCITY = current_state_opts["jump_velocity"]
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		set_current_state("airborne")

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# TODO: MOVE THIS UP
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		set_current_state("dashing")
		print('just pressed left or right')
		velocity.x = direction * SPEED * dash_speed
	
	if direction:
		print('youre holding a dir!!')
		#velocity.x = direction * SPEED
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	pass


func handle_idle_state(delta, current_state_opts) -> void:
	var SPEED = current_state_opts["speed"]
	var JUMP_VELOCITY = current_state_opts["jump_velocity"]
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		# We need to set ourselves to the dashing state, which means we're going
		# left or right for a set distance PER CHARACTER
		
		set_current_state("dashing")
		print('just pressed left or right')
		velocity.x = direction * SPEED * dash_speed
	
	if direction:
		print('youre holding a dir!!')
		#velocity.x = direction * SPEED
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	pass
