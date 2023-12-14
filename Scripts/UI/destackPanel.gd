extends CanvasLayer

export(NodePath) onready var _noti_tween = get_node(_noti_tween) as Tween
export(NodePath) onready var _panel_tween = get_node(_panel_tween) as Tween
export(NodePath) onready var _line = get_node(_line) as Line2D
export(NodePath) onready var _notificationDestack = get_node(_notificationDestack) as Panel
export(NodePath) onready var _button_panel = get_node(_button_panel) as Panel
export(NodePath) onready var _cancel_button = get_node(_cancel_button) as Button

export var stowed_margin : int = 0
export var popped_margin : int = -200

onready var camera_instance = get_tree().get_nodes_in_group("camera")

var _target_margin : int
var _is_popped_up : bool = false
var dragging : bool
var _current_node : String
var _adjacents : Array


func _ready() -> void:
	camera_instance = camera_instance.front()
	_cancel_button.connect("pressed", self, "pop_back_and_destroy")
	events.connect("reset_camera", self, "_start_process")


func _process(_delta: float) -> void:
	_update_line_pos()


func _start_process():
	set_process(true)
	yield(get_tree().create_timer(0.3),"timeout")
	set_process(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_in"):
		_start_process()
	if event.is_action_pressed("zoom_out"):
		_start_process()
	if event.is_action("drag"):
		if event.is_pressed():
			dragging = true
		else:
			dragging = false
			yield(get_tree().create_timer(0.2),"timeout")
			set_process(false)
	elif event is InputEventMouseMotion and dragging:
		set_process(true)


#func on_button_press(button):
#	if _line.get_point_count() > 1:
#		_line.clear_points()
#		_adjacents.clear()
#	_current_node = button.get_name()
#	_create_line()


func set_details(current_set : String):
	_current_node = current_set
	pop_out()
	yield(get_tree().create_timer(0.2),"timeout")
	_create_line()


func _create_line():
	if _line.get_point_count() == 0:
		_line.add_point(Vector2(0,0))
		print("adding a point")
	if _line.get_point_count() == 1:
		_create_lines()
	else:
		print("updating")
		_update_line_pos()


func _create_lines():
	print("creating lines")
	_adjacents.clear()
	for adjacent in WorldButtons.adjacency_dict[_current_node]:
		for button in get_tree().get_nodes_in_group("points"):
			if adjacent == button.get_name():
				_adjacents.append(button)
				print(button)
				_line.add_point(_calculate_size(button))
				_line.add_point(Vector2(0,0))


func _update_line_pos():
	var n : int = 0
	for points in _adjacents:
		_line.set_point_position(((2*n) + 1), _calculate_size(points))
		n += 1


func _calculate_size(button : TextureButton) -> Vector2:
	var button_size: Vector2 = button.get_size() / 2
	var destination: Vector2 = button.get_global_transform_with_canvas().origin + (button_size / camera_instance.zoom)
	destination -= Vector2(1080,107)
	return destination


func pop_out():
	_is_popped_up = true
	_target_margin = popped_margin
	_noti_tween.interpolate_property(
		_notificationDestack,
		"margin_left",
		_notificationDestack.margin_left,
		_target_margin,
		0.3,
		_noti_tween.TRANS_SINE,
		_noti_tween.EASE_IN )
	_noti_tween.interpolate_property(
		_notificationDestack,
		"margin_right",
		_notificationDestack.margin_right,
		_target_margin,
		0.3,
		_noti_tween.TRANS_SINE,
		_noti_tween.EASE_IN )
	
	_panel_tween.interpolate_property(
		_button_panel,
		"margin_right",
		_button_panel.margin_right,
		_target_margin,
		0.3,
		_panel_tween.TRANS_SINE,
		_panel_tween.EASE_OUT )
	_panel_tween.interpolate_property(
		_button_panel,
		"margin_left",
		_button_panel.margin_left,
		_target_margin,
		0.3,
		_panel_tween.TRANS_SINE,
		_panel_tween.EASE_OUT )
	
	_panel_tween.start()
	_noti_tween.start()


func pop_back_and_destroy():
	_line.clear_points()
	_adjacents.clear()
	
	_is_popped_up = false
	_target_margin = stowed_margin
	_noti_tween.interpolate_property(
		_notificationDestack,
		"margin_right",
		_notificationDestack.margin_right,
		_target_margin,
		0.3,
		_noti_tween.TRANS_SINE,
		_noti_tween.EASE_OUT )
	_noti_tween.interpolate_property(
		_notificationDestack,
		"margin_left",
		_notificationDestack.margin_left,
		_target_margin,
		0.3,
		_noti_tween.TRANS_SINE,
		_noti_tween.EASE_OUT )
		
	_panel_tween.interpolate_property(
		_button_panel,
		"margin_right",
		_button_panel.margin_right,
		_target_margin,
		0.3,
		_panel_tween.TRANS_SINE,
		_panel_tween.EASE_IN_OUT )
	_panel_tween.interpolate_property(
		_button_panel,
		"margin_left",
		_button_panel.margin_left,
		_target_margin,
		0.3,
		_panel_tween.TRANS_SINE,
		_panel_tween.EASE_IN_OUT )
		
	_panel_tween.start()
	_noti_tween.start()
	
	events.emit_signal("traversing")
	
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()
