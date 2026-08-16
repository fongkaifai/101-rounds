class_name Main
extends Node2D

const PLAYER_SCENE := preload("res://scenes/Player.tscn")
const OBSTACLE_SCENE := preload("res://scenes/Obstacle.tscn")

const SCREEN_WIDTH := 1280.0
const SCREEN_HEIGHT := 720.0
const ROUND_INTERVAL := 3.0
const SPAWN_MARGIN := 80.0

var _player: Node2D
var _round_count := 0
var _game_over := false

var _round_label: Label
var _game_over_label: Label
var _restart_button: Button
var _overlay: ColorRect

func _ready() -> void:
	_spawn_player()
	_build_ui()
	_start_round_timer()

func _spawn_player() -> void:
	_player = PLAYER_SCENE.instantiate()
	_player.position = Vector2(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
	_player.died.connect(_on_player_died)
	add_child(_player)

func _start_round_timer() -> void:
	var timer := Timer.new()
	timer.wait_time = ROUND_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_start_round)
	add_child(timer)

func _start_round() -> void:
	if _game_over:
		return
	_round_count += 1
	_round_label.text = "Round %d" % _round_count
	var obstacle_count := randi_range(3, 6)
	for i in obstacle_count:
		_spawn_obstacle()

func _spawn_obstacle() -> void:
	var spawn: Vector2
	var direction: Vector2
	var speed := randf_range(220.0, 420.0)

	match randi_range(0, 3):
		0:  # Top edge -> fly down
			spawn = Vector2(randf_range(0.0, SCREEN_WIDTH), -SPAWN_MARGIN)
			direction = Vector2.DOWN
		1:  # Bottom edge -> fly up
			spawn = Vector2(randf_range(0.0, SCREEN_WIDTH), SCREEN_HEIGHT + SPAWN_MARGIN)
			direction = Vector2.UP
		2:  # Left edge -> fly right
			spawn = Vector2(-SPAWN_MARGIN, randf_range(0.0, SCREEN_HEIGHT))
			direction = Vector2.RIGHT
		_:  # Right edge -> fly left
			spawn = Vector2(SCREEN_WIDTH + SPAWN_MARGIN, randf_range(0.0, SCREEN_HEIGHT))
			direction = Vector2.LEFT

	var obstacle := OBSTACLE_SCENE.instantiate()
	obstacle.position = spawn
	obstacle.setup(direction, speed)
	add_child(obstacle)

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	_show_game_over()
	get_tree().paused = true

func _show_game_over() -> void:
	_overlay.visible = true
	_game_over_label.visible = true
	_restart_button.visible = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _build_ui() -> void:
	var ui := CanvasLayer.new()
	ui.layer = 10
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui)

	_round_label = Label.new()
	_round_label.text = "Round 0"
	_round_label.position = Vector2(16.0, 8.0)
	_round_label.add_theme_font_size_override("font_size", 24)
	ui.add_child(_round_label)

	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.5)
	_overlay.position = Vector2.ZERO
	_overlay.size = Vector2(SCREEN_WIDTH, SCREEN_HEIGHT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.visible = false
	ui.add_child(_overlay)

	_game_over_label = Label.new()
	_game_over_label.text = "Game Over"
	_game_over_label.position = Vector2(0.0, 280.0)
	_game_over_label.size = Vector2(SCREEN_WIDTH, 90.0)
	_game_over_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_game_over_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_game_over_label.add_theme_font_size_override("font_size", 72)
	_game_over_label.visible = false
	ui.add_child(_game_over_label)

	_restart_button = Button.new()
	_restart_button.text = "Restart"
	_restart_button.position = Vector2(SCREEN_WIDTH * 0.5 - 100.0, 400.0)
	_restart_button.size = Vector2(200.0, 60.0)
	_restart_button.pressed.connect(_on_restart_pressed)
	_restart_button.visible = false
	ui.add_child(_restart_button)
