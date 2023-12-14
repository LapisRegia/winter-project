extends VBoxContainer

export(NodePath) onready var _topButton = get_node(_topButton) as Button
export(NodePath) onready var _midButton = get_node(_midButton) as Button
export(NodePath) onready var _botButton = get_node(_botButton) as Button
export var path_top_character : String
export var name_top_character : String
export var path_top_residual : String
export var name_top_residual : String

export var path_mid_character : String
export var name_mid_character : String
export var path_mid_residual : String
export var name_mid_residual : String

export var path_bot_character : String
export var name_bot_character : String
export var path_bot_residual : String
export var name_bot_residual : String

var super = WorldButtons._super_scene
var _character_box_ref : VBoxContainer
var _character_ref : KinematicBody2D
var _current_node : String
var _destack_instance

func _ready() -> void:
	_character_box_ref = super.get_node("CanvasLayer/CharacterBox")
	_topButton.connect("pressed", self, "_top_clicked")
	_midButton.connect("pressed", self, "_mid_clicked")
	_botButton.connect("pressed", self, "_bot_clicked")


func set_details(character_set):
	_current_node = character_set.current_node
	_character_ref = character_set

# needs the singleton
func _top_clicked():
	create_line2_nodes()
	_find_and_connect(path_top_character, name_top_character, path_top_residual, name_top_residual)


func _mid_clicked():
	create_line2_nodes()
	_find_and_connect(path_mid_character, name_mid_character, path_mid_residual, name_mid_residual)


func _bot_clicked():
	create_line2_nodes()
	_find_and_connect(path_bot_character, name_bot_character, path_bot_residual, name_bot_residual)


func create_line2_nodes():
	events.emit_signal("destacking")
	var destack_panel : String = "res://scenes/UI/destackScenes/destackPanel.tscn"
	var destack_load = load(destack_panel).instance()
	super.add_child(destack_load)
	# weirld dependency
	_destack_instance = super.get_node("canvas_destack")
	_destack_instance.set_details(_current_node)


func _find_and_connect(moving_path : String, moving_name : String, stationary_path : String, stationary_name : String):
	for adjacent in WorldButtons.adjacency_dict[_current_node]:
		for button in get_tree().get_nodes_in_group("points"):
			if adjacent == button.get_name() && !button.is_connected("pressed", self, "_create_character"):
				button.connect("pressed", self, "_create_character", [moving_path, moving_name, stationary_path, stationary_name, button])


# unfinished, needs the math thing and the determiner
func _create_character(moving_path : String, moving_name : String, stationary_path : String, stationary_name : String, button : TextureButton):
	var moving_instance = load (moving_path).instance()
	var stationary_instance = load (stationary_path).instance()
	super.add_child(moving_instance)
	super.add_child(stationary_instance)
	
	var moving_char = super.get_node(moving_name)
	var stationary_char = super.get_node(stationary_name)
	moving_char.set_character_attribute(_character_ref)
	stationary_char.set_character_attribute(_character_ref)
	#moving_char.current_node = button.get_name()
	moving_char._to_Node(button)
	
	events.emit_signal("traversing")
	_character_ref.queue_free()
	Main.reconnect()
	_destack_instance.pop_back_and_destroy()
