extends CanvasLayer

export(NodePath) onready var _cancel_button = get_node(_cancel_button) as Button
export(NodePath) onready var _tween = get_node(_tween) as Tween

export var stowed_margin : int = 0
export var popped_margin : int = -200
var _target_margin : int = popped_margin

func _ready() -> void:
	_cancel_button.connect("pressed", self, "_on_finish")
	_on_ready()


func _on_ready():
	_target_margin = popped_margin
	_tween.interpolate_property(
		_cancel_button,
		"margin_left",
		_cancel_button.margin_left,
		_target_margin,
		0.2,
		_tween.TRANS_SINE,
		_tween.EASE_IN )
	_tween.interpolate_property(
		_cancel_button,
		"margin_right",
		_cancel_button.margin_right,
		_target_margin,
		0.2,
		_tween.TRANS_SINE,
		_tween.EASE_IN )
	_tween.start()


func _on_finish():
	events.emit_signal("traversing")
	
	_target_margin = stowed_margin
	_tween.interpolate_property(
		_cancel_button,
		"margin_left",
		_cancel_button.margin_left,
		_target_margin,
		0.2,
		_tween.TRANS_SINE,
		_tween.EASE_IN )
	_tween.interpolate_property(
		_cancel_button,
		"margin_right",
		_cancel_button.margin_right,
		_target_margin,
		0.2,
		_tween.TRANS_SINE,
		_tween.EASE_IN )
	_tween.start()
	yield(get_tree().create_timer(0.2), "timeout")
	queue_free()
