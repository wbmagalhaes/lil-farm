extends CharacterBody2D

@export var speed = 400
@onready var animation = $AnimationPlayer

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func set_animation():
	if velocity.y < 0:
		animation.play("run_up")
	elif velocity.y > 0:
		animation.play("run_down")
	elif velocity.x < 0:
		animation.play("run_left")
	elif velocity.x > 0:
		animation.play("run_right")
	else:
		animation.play("idle")

func _physics_process(_delta: float) -> void:
	get_input()
	set_animation()
	move_and_slide()
