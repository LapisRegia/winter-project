extends Camera2D

# variables for drag
var mouse_start_pos
var screen_start_position
var dragging = false

# variables for zoom
signal zoom_level_changed(new_value)

export var zoom_duration := 0.2
export var zoom_factor := 0.1
export var min_zoom := 0.5
export var max_zoom := 2.0
var zoom_level := 1.0 setget set_zoom_level

onready var tween = get_node("Tween") as Tween

func _ready() -> void:
	events.connect("set_camera", self, "set_camera")
	events.connect("reset_camera", self, "set_zoom_level", [1.0])


func _input(event):
	if event.is_action_pressed("zoom_in"):
		set_zoom_level(zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		set_zoom_level(zoom_level + zoom_factor)
	if event.is_action("drag"):
		if event.is_pressed() && !WorldButtons.calc_panel_popped:
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		var new_position = zoom * (mouse_start_pos - event.position) + screen_start_position
		drag_camera(new_position)


func drag_camera(new_position):
	tween.interpolate_property(
		self,
		"position",
		position,
		new_position,
		0.1,
		tween.TRANS_SINE,
		tween.EASE_OUT
	)
	tween.start()

func set_zoom_level(value: float) -> void:
	zoom_level = clamp(value, min_zoom, max_zoom)
	emit_signal("zoom_level_changed", zoom_level)
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(zoom_level, zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		tween.EASE_OUT
	)
	tween.start()


func set_camera(current_position) -> void:
	set_zoom_level(0.6)
	tween.interpolate_property(
		self,
		"position",
		position,
		current_position,
		zoom_duration,
		tween.TRANS_SINE,
		tween.EASE_OUT)
	tween.start()

