extends CharacterBody3D

# get the camera input for the mouse event
@onready var camera_3d = $camera/Camera3D
@onready var animation_player = $visuals/ypack/AnimationPlayer
@onready var visuals = $visuals


var SPEED = 5.0
const JUMP_VELOCITY = 4.5
var run = false
var jump = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


@export var walking_speed = 3.0
@export var running_speed = 5.0


#horizontal sens mouse
@export var sens_horizontal = 0.5
@export var sens_vertical = 0.5

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x*sens_horizontal))	
		#plus for a static view on player 
		visuals.rotate_y(deg_to_rad(event.relative.x*sens_horizontal))
		camera_3d.rotate_x(deg_to_rad(-event.relative.y*sens_vertical))

func _physics_process(delta):
	
	#add running key
	if Input.is_action_pressed("run"):
		SPEED = running_speed
		run = true
	else:
		SPEED = walking_speed	
		run = false
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		jump = true
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if run:
			if animation_player.current_animation != "run":
				animation_player.play("run")
		else:
			#apply walk animation
			if animation_player.current_animation != "walk":
				animation_player.play("walk")
		#visuals -> point camera on position view	
		visuals.look_at(position + direction)	
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		#apply idle animation
		if animation_player.current_animation != "idle loop":
			animation_player.play("idle loop")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
