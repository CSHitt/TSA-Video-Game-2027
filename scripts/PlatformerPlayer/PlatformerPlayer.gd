class_name PlatformerPlayer
extends CharacterBody2D

# 32 px = 1 m

enum PlatformerStateEnum {
	Idle = 0,
	Walking,
	Crouching,
	Sprinting,
	Jumping
}

@export var WalkingSpeed: float = 300.0
@export var CrouchingSpeed: float = 150.0
@export var SprintingSpeed: float = 500.0
@export var JumpingSpeed: float = -400.0

var MovementSpeed: Dictionary[PlatformerStateEnum, float]

var direction: Vector2 = Vector2(0.0, 0.0)
var just_jumped: bool = false
var platformer_state = PlatformerStateEnum.Idle

func _init() -> void:
	MovementSpeed[PlatformerStateEnum.Idle] = 0.0
	MovementSpeed[PlatformerStateEnum.Walking] = WalkingSpeed
	MovementSpeed[PlatformerStateEnum.Crouching] = CrouchingSpeed
	MovementSpeed[PlatformerStateEnum.Sprinting] = SprintingSpeed
	MovementSpeed[PlatformerStateEnum.Jumping] = WalkingSpeed

func _physics_process(delta: float) -> void:
	# Get directional input
	direction = Input.get_vector("game_left", "game_right", "game_up", "game_down")
	# Update player state
	if is_on_floor():
		# Handle Jump
		if Input.is_action_just_pressed("game_jump"):
			velocity.y = JumpingSpeed
			platformer_state = PlatformerStateEnum.Jumping
		elif Input.is_action_pressed("game_crouch"):
			platformer_state = PlatformerStateEnum.Crouching
		elif Input.is_action_pressed("game_sprint"):
			platformer_state = PlatformerStateEnum.Sprinting
		elif direction != Vector2(0.0, 0.0):
			platformer_state = PlatformerStateEnum.Walking
		else:
			platformer_state = PlatformerStateEnum.Idle
	else:
		platformer_state = PlatformerStateEnum.Jumping
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity.x = move_toward(velocity.x, direction.x * MovementSpeed[platformer_state], 10)
	
	print(platformer_state)
	
	move_and_slide()
