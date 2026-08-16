class_name Obstacle
extends Area2D

const RADIUS := 14.0
const SCREEN_WIDTH := 1280.0
const SCREEN_HEIGHT := 720.0
const DESTROY_MARGIN := 120.0

@export var direction := Vector2.LEFT
@export var speed := 350.0

func _ready() -> void:
	add_to_group("obstacles")
	_build_collision_shape()
	_build_visual()

func setup(new_direction: Vector2, new_speed: float) -> void:
	direction = new_direction.normalized()
	speed = new_speed

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	rotation = direction.angle()
	if _is_out_of_screen():
		queue_free()

func _build_collision_shape() -> void:
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

func _build_visual() -> void:
	var visual := Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(RADIUS, 0.0),
		Vector2(-RADIUS * 0.7, RADIUS * 0.7),
		Vector2(-RADIUS * 0.7, -RADIUS * 0.7),
	])
	visual.color = Color(1.0, 0.35, 0.3)
	add_child(visual)

func _is_out_of_screen() -> bool:
	return position.x < -DESTROY_MARGIN \
		or position.x > SCREEN_WIDTH + DESTROY_MARGIN \
		or position.y < -DESTROY_MARGIN \
		or position.y > SCREEN_HEIGHT + DESTROY_MARGIN
