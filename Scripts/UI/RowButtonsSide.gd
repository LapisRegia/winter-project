extends TextureButton

onready var RECT_STOWED : int = rect_position.x
const RECT_INACTIVE : int = -96
const RECT_ACTIVE : int = 50
const ALPHA_ACTIVE : float = 1.0
const ALPHA_INACTIVE : float = 0.0

onready var _tween = get_node("Tween") as Tween

var menu_showing : bool = true

func _ready() -> void:
	connect("mouse_entered",self,"hover_out")
	connect("mouse_exited",self,"hover_in")
	events.connect("destacking", self, "hover_inactive")
	events.connect("firing", self, "hover_inactive")
	events.connect("traversing", self, "hover_in")
	events.connect("showMenu_pressed", self, "_on_showMenu_press")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drag"):
		hover_inactive()
		menu_showing = false


func _on_showMenu_press():
	menu_showing = true
	disabled = false
	_alpha_mod(ALPHA_ACTIVE)
	_move_pos(RECT_STOWED)


func hover_inactive():
	_move_pos(RECT_INACTIVE)
	_alpha_mod(ALPHA_INACTIVE)
	disabled = true


func hover_out():
	_move_pos(RECT_ACTIVE)


func hover_in():
	if disabled:
		disabled = false
	if menu_showing:
		_alpha_mod(ALPHA_ACTIVE)
		_move_pos(RECT_STOWED)


func _move_pos(_target_x : int):
	_tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		Vector2(_target_x, rect_position.y),
		0.25,
		_tween.TRANS_SINE,
		_tween.EASE_OUT )
	_tween.start()


func _alpha_mod(_target_a : float):
	_tween.interpolate_property(
		self,
		"modulate:a",
		modulate.a,
		_target_a,
		0.15,
		_tween.TRANS_SINE,
		_tween.EASE_IN_OUT )
	_tween.start()
