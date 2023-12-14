extends VBoxContainer

#signal alert(alert_text)

const YUMI : int = 0b00
const YUME : int = 0b01
const YUUKO : int = 0b10
const YUUKO_YUME : int = 0b1001
const YUUKO_YUMI : int = 0b1000
const YUME_YUMI  : int = 0b0100

const RECT_STOWED : float = 1283.0
const RECT_POPPED : float = 1048.0

export(NodePath) onready var _button_select = get_node(_button_select) as Button
export(NodePath) onready var _button_swap = get_node(_button_swap) as Button
export(NodePath) onready var _button_stack = get_node(_button_stack) as Button

onready var _tween : Tween = $Tween

onready var rect_pos_y : float = self.rect_position.y

var tween_speed : float =  0.2
var a_character : KinematicBody2D
var b_character : KinematicBody2D
var _swappable : bool = false

func _ready() -> void:
	_button_select.connect("pressed",self, "select_character")
	_button_swap.connect("pressed",self, "swap_check")
	_button_stack.connect("pressed",self, "stack_check")
	events.connect("world_pressed",self,"on_destroy")


func set_character_reference(a_ref : KinematicBody2D, b_ref : KinematicBody2D, s_ref : bool):
	a_character = a_ref
	b_character = b_ref
	_swappable = s_ref
	pop_out(RECT_POPPED)


func on_destroy():
	pop_out(RECT_STOWED)
	yield(_tween , "tween_completed")
	events.disconnect("world_pressed",self,"on_destroy")
	WorldButtons.sss_panel_instanced = false
	queue_free()


func select_character():
	a_character._is_active(true)
	b_character._is_active(false)
	on_destroy()


func pop_out(_target_x):
	_tween.interpolate_property(
		self,
		"rect_position",
		self.rect_position,
		Vector2(_target_x, rect_pos_y),
		tween_speed,
		_tween.TRANS_SINE,
		_tween.EASE_IN)
	_tween.start()


func swap_check():
	if _swappable:
		swap_character_pos()
	else:
		events.emit_signal("alert","characters not swappable.")


func swap_character_pos():
	# save and update current node
	var saved_a_pos: String = a_character.current_node
	a_character.current_node = b_character.current_node
	b_character.current_node = saved_a_pos
	
	# disable the button to avoid spam clicking
	_button_swap.disabled = true
	
	# swap the characters
	a_character._move_to(b_character.position)
	a_character._add_time()
	b_character._move_to(a_character.position)
	b_character._add_time()
	yield(a_character._tween,"tween_completed")
	_button_swap.disabled = false


func stack_check():
	var a : PoolIntArray = a_character.identifier
	var b : PoolIntArray = b_character.identifier
	var id_a : int
	var id_b : int
	for ids in a:
		id_a += ids
	for ids in b:
		id_b += ids
	
	print ("a: ", id_a, "b: ", id_b)
	if id_a == YUMI or id_b == YUMI:
		if id_a == YUME or id_b == YUME:
			stack_characters("res://scenes/Characters/Stack/Yumi_Yume.tscn", "Yumi_Yume")
			print("stacking: Yumi & Yume")
		elif id_a == YUUKO or id_b == YUUKO:
			stack_characters("res://scenes/Characters/Stack/Yumi_Yuuko.tscn", "Yumi_Yuuko")
			print("stacking: Yumi & Yuuko")
		else:
			stack_characters("res://scenes/Characters/Stack/Yumi_Yuuko_Yume.tscn", "Yumi_Yuuko_Yume")
			print ("stacking all")
	elif id_a == YUME or id_b == YUME:
		if id_a == YUUKO or id_b == YUUKO:
			stack_characters("res://scenes/Characters/Stack/Yuuko_Yume.tscn", "Yuuko_Yume")
			print("stacking: Yuuko & Yume")
		else:
			stack_characters("res://scenes/Characters/Stack/Yumi_Yuuko_Yume.tscn", "Yumi_Yuuko_Yume")
			print ("stacking all")
			
	print ("checked all")
	Main.reconnect()
	on_destroy()


# dont forget to also include calculation for other attributes (radiation, health, etc).
# the latest time gets priority over no of walks.
# if Yumi has 2 walks left @ 3:20am and Yume has 30 walks at 12:00am,
# the stack's time will be Yumi's
# however if both are the at the same time frame,
# the stack's remaining walks will be of character with the least time slice.
func stack_characters(_file_path : String, _character_name : String):
	print(_file_path)
	var new_character = load(_file_path).instance()
	WorldButtons._super_scene.add_child(new_character)
	var new_stack = WorldButtons._super_scene.get_node(_character_name)
	
#	if a_character.no_of_turns < b_character.no_of_turns:
#		new_stack.set_character_attribute(a_character)
#	else:
#		new_stack.set_character_attribute(b_character)
	for _to_be_disabled_button in get_tree().get_nodes_in_group("points"):
		if _to_be_disabled_button.get_name() == b_character.current_node:
			_to_be_disabled_button.disabled = false
	b_character._move_to(a_character.position)
	# yield(get_tree().create_timer(0.5), "timeout")
	new_stack.set_character_attribute(a_character)
	b_character.queue_free()
	a_character.queue_free()
