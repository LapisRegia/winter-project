extends "res://Scripts/UI/RowButtonsBot.gd"

var menu_showing : bool = true

func _ready() -> void:
	disabled = true
	modulate.a = 0
	connect("pressed", self, "_on_press")


func hover_out():
	if !menu_showing:
		_move_pos(RECT_ACTIVE)
		_alpha_mod(ALPHA_ACTIVE)
		disabled = false


func hover_in():
	_move_pos(RECT_INACTIVE)
	_alpha_mod(ALPHA_INACTIVE)
	disabled = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drag"):
		menu_showing = false
		_alpha_mod(ALPHA_ACTIVE)
		rect_position.y = RECT_ACTIVE
		disabled = false


func _on_press():
	events.emit_signal("showMenu_pressed")
	_alpha_mod(ALPHA_INACTIVE)
	disabled = true
	menu_showing = true

