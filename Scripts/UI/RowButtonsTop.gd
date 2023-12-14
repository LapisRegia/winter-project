extends Panel

const ALPHA_ACTIVE : float = 1.0
const ALPHA_INACTIVE : float = 0.0
const RECT_ACTIVE : int = 31
const RECT_INACTIVE : int  = -79

onready var _tween = get_node("Tween") as Tween

func _ready() -> void:
	events.connect("firing", self, "hover_in")
	events.connect("destacking", self, "hover_in")
	events.connect("traversing", self, "hover_out")


func hover_out():
	_move_pos(RECT_ACTIVE)
	_alpha_mod(ALPHA_ACTIVE)


func hover_in():
	_move_pos(RECT_INACTIVE)
	_alpha_mod(ALPHA_INACTIVE)


func _move_pos(_rect_target_y : int):
	_tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		Vector2(rect_position.x, _rect_target_y),
		0.3,
		_tween.TRANS_BACK,
		_tween.EASE_IN_OUT )
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
