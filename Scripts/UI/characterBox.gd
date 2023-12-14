extends VBoxContainer

const YUMI : int = 0b00
const YUME : int = 0b01
const YUUKO : int = 0b10

const RECT_STOWED : int = 1280
const RECT_POPPED : int = 1130

onready var _tween = get_node("Tween") as Tween
onready var _destackContainer = get_node("destackContainer") as VBoxContainer

var _rect_target_x : int = RECT_STOWED
var _is_popped_up : bool = false
var _destackable :  bool = false
var _destructable : bool = true

func _ready() -> void:
	for button in get_tree().get_nodes_in_group("points"):
		button.connect("pressed",self,"pop_back_pre_check")
	events.connect("world_pressed", self, "pop_back_pre_check")
	events.connect("destacking", self, "_set_destructable", [false])
	events.connect("traversing", self, "_set_destructable", [true] )


func _set_destructable(_bool_set):
	_destructable = _bool_set
	if _destructable:
		pop_back()


# think if we want this
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drag") && _destructable:
		pop_back_pre_check()


func pop_back_pre_check():
	if _is_popped_up && _destructable:
		pop_back()


func create_buttons(button_ref : KinematicBody2D):
	var ids : Array = button_ref.identifier
	if ids.size() > 2:
		var destack_button = load("res://scenes/UI/destackScenes/three/Destack_three.tscn").instance()
		_destackContainer.add_child(destack_button)
		var destackYume : VBoxContainer = _destackContainer.get_node("destack_Vbox")
		destackYume.set_details(button_ref)
	elif ids[0] == YUMI or ids[1] == YUMI:
		if  ids[0] == YUME or ids[1] == YUME:
			var destack_button = load("res://scenes/UI/destackScenes/twos/Yumi_Yume.tscn").instance()
			_destackContainer.add_child(destack_button)
			var destackYume : VBoxContainer = _destackContainer.get_node("destack_Vbox")
			destackYume.set_details(button_ref)
		elif ids[0] == YUUKO or ids[1] == YUUKO:
			var destack_button = load("res://scenes/UI/destackScenes/twos/Yumi_Yuuko.tscn").instance()
			_destackContainer.add_child(destack_button)
			var destackYume : VBoxContainer = _destackContainer.get_node("destack_Vbox")
			destackYume.set_details(button_ref)
	elif ids[0] == YUME or ids[1] == YUME:
		if  ids[0] == YUUKO or ids[1] == YUUKO:
			var destack_button = load("res://scenes/UI/destackScenes/twos/Yuuko_Yume.tscn").instance()
			_destackContainer.add_child(destack_button)
			var destackYume : VBoxContainer = _destackContainer.get_node("destack_Vbox")
			destackYume.set_details(button_ref)


func pop_out(image_path : String, button_ref : KinematicBody2D):
	var id : int
	for i in button_ref.identifier:
# warning-ignore:unassigned_variable_op_assign
		id += i
	if id > YUUKO:
		create_buttons(button_ref)
		_destackable = true
	$TextureRect.texture = load(image_path)
	_is_popped_up = true
	_rect_target_x = RECT_POPPED
	
	_tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		Vector2(_rect_target_x, rect_position.y),
		0.25,
		_tween.TRANS_SINE,
		_tween.EASE_OUT )
	_tween.start()


func pop_back():
	if _destackable:
		_destroy_destack()
	_is_popped_up = false
	_rect_target_x = RECT_STOWED
	_tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		Vector2(_rect_target_x, rect_position.y),
		0.25,
		_tween.TRANS_SINE,
		_tween.EASE_OUT )
	_tween.start()


func _destroy_destack():
	_destackable = false
	var destackButton = _destackContainer.get_node("destack_Vbox")
	destackButton.queue_free()
