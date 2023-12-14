extends KinematicBody2D


signal change_time(updated_time)
signal change_walks(updated_walks)
signal pop_out(image_path,identifier)
signal character_selected

export var identifier : PoolIntArray
export(NodePath) onready var _active_label = get_node(_active_label) as RichTextLabel
export(NodePath) onready var _tween = get_node(_tween) as Tween

# UI variables
# maybe put it in a class or something
var character_time : String = "2000 hours"
onready var _character_name: String = get_name()
# character attributes
export var health: int = 100
export var endurance: int = 100
export var tween_speed: float = 0.5
export var current_node: String = "point"
export var box_image_path : String = ""
export var no_of_turns: int 

onready var _UI_reference : Array = get_tree().get_nodes_in_group("UI")
onready var _box_reference : Array = get_tree().get_nodes_in_group("character_box")

# limiting movement
var selected : bool = false
var moving : bool = false
var character_box_popped : bool = false
# calculator instance management
#var _in_calculator_node : bool = false

# time calculation
var walks_depleted: int
var time_slice: int
var current_character_time: int


func _ready():
	# update this with for the end turn logic
	# time calculation
	time_slice = Main._first_crepuscular_calc(no_of_turns)
	current_character_time = Main.crepuscular_start
	# makes the active label invisible
	_active_label.modulate.a = 0
	
	#connections
	for button in get_tree().get_nodes_in_group("points"):
		button.connect("pressed",self,"_pre_check", [button])
	connect_to_others()
	connect("change_walks", _UI_reference.front(), "change_walks")
	connect("change_time", _UI_reference.front(), "change_time")
	connect("pop_out", _box_reference.front(), "pop_out")
	events.connect("world_pressed", self, "_is_active", [false])


# quite confusing. 
	# character butttons (other than the connecting button) connect to the current button
	# when you press on a char button, it will emit a signal to the other character buttons
	# to disable other character buttons (in other words disable the previous active character
func connect_to_others():
	for characters in get_tree().get_nodes_in_group("Characters"):
		if characters.get_name() != _character_name && !characters.is_connected("character_selected", self, "determine_action"):
			characters.connect("character_selected", self, "determine_action", [characters])


func set_character_attribute(character_ref):
	position = character_ref.position
	current_node = character_ref.current_node
	no_of_turns = character_ref.no_of_turns
	walks_depleted = character_ref.walks_depleted
	time_slice = Main._first_crepuscular_calc(no_of_turns)
	character_time = character_ref.character_time


func _on_characterButton_pressed() -> void:
	if selected:
		emit_signal("pop_out", box_image_path, get_node("."))
		events.emit_signal("set_camera", position)
	if !selected:
		emit_signal("character_selected")
		_is_active(true)
		_update_UI()


# please dont delete the selected = boolean line
# the last time you did it the thing broke
func _is_active(boolean):
	selected = boolean
	if !selected:
		_active_label.modulate.a = 0
	else:
		_active_label.modulate.a = 1


func _update_UI():
	emit_signal("change_time",character_time)
	emit_signal("change_walks", no_of_turns - walks_depleted)


# this works. the flow is
# click on a, a is selected
# click on b, a is hears the "character pressed" signal 
# a runs _is_adjacent_to_character function
#		a checks own adjacency list and sees if there is a match with b's current node
# if return true, stack menu is shown on b
# else deactivate (selected = false) a, and select b.
# assume the functions below here are in "b".
# _character_reference is a, self is b
func determine_action(_character_reference : KinematicBody2D):
	# print("listening: ",_character_name)
	if selected:
		if _one_way_check(_character_reference):
			if _two_way_check(_character_reference):
				_create_stack_button(_character_reference, true)
			else:
				_create_stack_button(_character_reference, false)
		else:
			_is_active(false)


func _one_way_check(_character_reference : KinematicBody2D) -> bool:
	for nodes in WorldButtons.adjacency_dict[current_node]:
		if nodes == _character_reference.current_node:
			return true
	return false


func _two_way_check(_character_reference : KinematicBody2D) -> bool:
	for nodes in WorldButtons.adjacency_dict[_character_reference.current_node]:
		if nodes == current_node:
			return true
	return false


func _create_stack_button(_character_reference: KinematicBody2D, swappable : bool):
	WorldButtons.create_sss(_character_reference, get_node("."), swappable)


# movement 
func _pre_check(button):
	if walks_depleted == no_of_turns:
		events.emit_signal("alert","No more walks for this turn!")
	elif moving:
		events.emit_signal("alert","Currently moving...")
	elif selected and !moving and !WorldButtons.calc_panel_popped:
		if _is_button_adjacent(button):
			events.emit_signal("alert","Node is unreachable")
		else:
			_to_Node(button)


func _is_button_adjacent(button) -> bool:
	for nodes in WorldButtons.adjacency_dict[current_node]:
		if nodes == button.get_name():
			return false
	return true


func _to_Node(button : TextureButton):
	_enable_previous_disable_new(button)
	_calculate_size(button)
	_add_time()
	yield(_tween,"tween_completed")
	moving = false


func _add_time():
	# add walks depleted
	walks_depleted += 1
	# calculates the minutes to add
	var time_added = (time_slice * walks_depleted)
	# calculates the remainder of the division of 60
	var minutes = time_added % 60
	# calculates the quotient
	var hour = time_added / 60
	
	hour += current_character_time
	hour = hour % 24
	character_time = str("%02d%02d hours" % [hour,minutes])
	emit_signal("change_time",character_time)
	emit_signal("change_walks", no_of_turns - walks_depleted)


# in the future separate the adjacency lists into >2
# you dont want to have your worst case be O(n)
# at least O(n/2)
func _enable_previous_disable_new(button : TextureButton):
	for _to_be_disabled_button in get_tree().get_nodes_in_group("points"):
		if _to_be_disabled_button.get_name() == current_node:
			_to_be_disabled_button.disabled = false
	button.disabled = true
	current_node = button.get_name()


func _calculate_size(button : TextureButton):
	var button_size: Vector2 = button.get_size() / 2
	var destination: Vector2 = button.get_global_position() + button_size
	_move_to(destination)


func _move_to(destination : Vector2):
	moving = true
	_tween.interpolate_property(
		self,
		"position",
		position,
		destination,
		tween_speed,
		_tween.TRANS_SINE,
		_tween.EASE_IN_OUT)
	_tween.start()
	yield(_tween , "tween_completed")
	moving = false


#---------------------- Calculator management
#func _on_Area2D_area_entered(area: Area2D) -> void:
#	var button = area.get_parent()
#	_in_calculator_node = true
#	Main.panel_tracker[get_node(".")] = button


#func _on_Area2D_area_exited(_area: Area2D) -> void:
#	_in_calculator_node = false
#	Main.panel_tracker.erase(get_node("."))
