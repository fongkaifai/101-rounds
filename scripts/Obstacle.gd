class_name Obstacle
extends Area2D

const SCREEN_WIDTH := 1280.0
const SCREEN_HEIGHT := 720.0
const DESTROY_MARGIN := 120.0

@export var direction := Vector2.LEFT
@export var speed := 350.0

@onready var _sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("obstacles")

func setup(new_direction: Vector2, new_speed: float) -> void:
	direction = new_direction.normalized()
	speed = new_speed

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	_sprite.flip_h = direction.x < 0.0
	if _is_out_of_screen():
		queue_free()

func _is_out_of_screen() -> bool:
	return position.x < -DESTROY_MARGIN \
		or position.x > SCREEN_WIDTH + DESTROY_MARGIN \
		or position.y < -DESTROY_MARGIN \
		or position.y > SCREEN_HEIGHT + DESTROY_MARGIN
