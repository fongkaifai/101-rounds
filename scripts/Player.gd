class_name Player
extends Area2D

signal died

const SPEED := 500.0
const RADIUS := 16.0
const SCREEN_WIDTH := 1280.0
const SCREEN_HEIGHT := 720.0

func _ready() -> void:
	_build_collision_shape()
	_build_visual()
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	position += input * SPEED * delta
	position.x = clamp(position.x, RADIUS, SCREEN_WIDTH - RADIUS)
	position.y = clamp(position.y, RADIUS, SCREEN_HEIGHT - RADIUS)

func _build_collision_shape() -> void:
	var shape := CircleShape2D.new()
	shape.radius = RADIUS
	var collision := CollisionShape2D.new()
	collision.shape = shape
	add_child(collision)

func _build_visual() -> void:
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * i / 24.0
		points.append(Vector2(cos(angle), sin(angle)) * RADIUS)
	var visual := Polygon2D.new()
	visual.polygon = points
	visual.color = Color(0.4, 0.65, 1.0)
	add_child(visual)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		died.emit()
