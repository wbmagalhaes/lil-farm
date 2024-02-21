extends CharacterBody2D

@export var speed = 400
@onready var animation = $AnimationPlayer

var current_position: Vector2
var current_direction: String
var current_animation: String

func _ready():
	current_position = Vector2(0, 0)
	current_direction = "Down"
	current_animation = "idle"

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func set_animation():
	if velocity.y < 0:
		animation.play("run_up")
		current_direction = "Up"
		current_animation = "run_up"
	elif velocity.y > 0:
		animation.play("run_down")
		current_direction = "Down"
		current_animation = "run_down"
	elif velocity.x < 0:
		animation.play("run_left")
		current_direction = "Left"
		current_animation = "run_left"
	elif velocity.x > 0:
		animation.play("run_right")
		current_direction = "Right"
		current_animation = "run_right"
	else:
		animation.play("idle")
		current_animation = "idle"

func _physics_process(_delta: float) -> void:
	get_input()
	set_animation()
	move_and_slide()
	
	current_position = get_position()
	send_move_update()

func send_move_update():
	NetworkManager.send_move_command(current_position, current_direction, current_animation)
