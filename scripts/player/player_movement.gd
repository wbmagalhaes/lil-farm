class_name Player
extends CharacterBody2D

@export var speed: float = 40
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var pick_range: PickupRange = $pick_up_range
@onready var inventory: Inventory = $"../UI/inventory_dialog"

var _current_position: Vector2
var _current_direction: String
var _current_animation: String

func _ready():
	_current_position = Vector2(0, 0)
	_current_direction = "Down"
	_current_animation = "idle"

	pick_range.pick_item.connect(self._on_pick_item)

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func set_animation():
	if velocity.y < 0:
		animation_player.play("run_up")
		_current_direction = "Up"
		_current_animation = "run_up"
	elif velocity.y > 0:
		animation_player.play("run_down")
		_current_direction = "Down"
		_current_animation = "run_down"
	elif velocity.x < 0:
		animation_player.play("run_left")
		_current_direction = "Left"
		_current_animation = "run_left"
	elif velocity.x > 0:
		animation_player.play("run_right")
		_current_direction = "Right"
		_current_animation = "run_right"
	else:
		animation_player.play("idle")
		_current_animation = "idle"

func _physics_process(_delta: float) -> void:
	get_input()
	set_animation()
	move_and_slide()

	_current_position = get_position()
	send_move_update()

func send_move_update():
	# TODO: only send if changed from previous frame
	NetworkManager.send_move_command(
		_current_position,
		_current_direction,
		_current_animation,
	)

func _on_pick_item(item_pickup: ItemPickup):
	var item = item_pickup.get_item()
	var success = inventory.add_item(item)
	if success:
		item_pickup.set_disabled(true)
		item.visible = false
