class_name Player
extends Area2D

signal died

const SPEED := 500.0
const RADIUS := 16.0
const SCREEN_WIDTH := 1280.0
const SCREEN_HEIGHT := 720.0
const JOYSTICK_MAX_RADIUS := 64.0
const JOYSTICK_DEADZONE := 12.0

var _joystick_active := false
var _joystick_center := Vector2.ZERO
var _joystick_offset := Vector2.ZERO
var _joystick_node: Node2D
var _knob_node: Polygon2D

func _ready() -> void:
	_build_joystick_visual()
	area_entered.connect(_on_area_entered)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_joystick_active = true
			_joystick_center = _to_canvas_position(event.position)
			_joystick_offset = Vector2.ZERO
		else:
			_joystick_active = false
			_joystick_offset = Vector2.ZERO
		_update_joystick_visual()
	elif event is InputEventScreenDrag:
		if _joystick_active:
			_joystick_offset = _to_canvas_position(event.position) - _joystick_center
			_update_joystick_visual()

func _physics_process(delta: float) -> void:
	var velocity := _joystick_direction() * SPEED
	if velocity == Vector2.ZERO:
		velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED
	position += velocity * delta
	position.x = clamp(position.x, RADIUS, SCREEN_WIDTH - RADIUS)
	position.y = clamp(position.y, RADIUS, SCREEN_HEIGHT - RADIUS)

func _joystick_direction() -> Vector2:
	if not _joystick_active:
		return Vector2.ZERO
	var clamped := _joystick_offset.limit_length(JOYSTICK_MAX_RADIUS)
	if clamped.length() <= JOYSTICK_DEADZONE:
		return Vector2.ZERO
	var magnitude := (clamped.length() - JOYSTICK_DEADZONE) / (JOYSTICK_MAX_RADIUS - JOYSTICK_DEADZONE)
	return clamped.normalized() * magnitude

func _build_joystick_visual() -> void:
	_joystick_node = Node2D.new()
	_joystick_node.top_level = true
	var base := Polygon2D.new()
	base.polygon = _circle_points(JOYSTICK_MAX_RADIUS)
	base.color = Color(1.0, 1.0, 1.0, 0.25)
	_joystick_node.add_child(base)
	_knob_node = Polygon2D.new()
	_knob_node.polygon = _circle_points(26.0)
	_knob_node.color = Color(1.0, 1.0, 1.0, 0.6)
	_joystick_node.add_child(_knob_node)
	add_child(_joystick_node)
	_joystick_node.visible = false

func _update_joystick_visual() -> void:
	if _joystick_node == null:
		return
	_joystick_node.visible = _joystick_active
	if _joystick_active:
		_joystick_node.position = _joystick_center
		_knob_node.position = _joystick_offset.limit_length(JOYSTICK_MAX_RADIUS)

func _circle_points(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(24):
		var angle := TAU * i / 24.0
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points

func _to_canvas_position(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstacles"):
		_joystick_active = false
		_joystick_offset = Vector2.ZERO
		_update_joystick_visual()
		died.emit()
