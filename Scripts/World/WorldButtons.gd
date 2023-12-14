extends Node

onready var _super_scene : Node2D = get_tree().get_nodes_in_group("super_scene").front()
onready var _UI_scene : CanvasLayer = _super_scene.get_node("UI")

#onready var _UI_canvas = get_tree().get_root().get_child("CanvasLayer")

# updated dynamically. when implementing a save feature, just copy the current 
# instance of the variable, and save in a file or something.
var adjacency_dict : Dictionary = {}
var sss_panel_instanced : bool = false

var calc_panel_popped : bool = false
var calc_panel_instanced : bool = false

func _ready() -> void:
	for points in get_tree().get_nodes_in_group("points"):
		points.connect("pressed", self, "destroy_sss")


func create_sss(a_character : KinematicBody2D, b_character : KinematicBody2D, swappable : bool):
	if !sss_panel_instanced:
		sss_panel_instanced = true
		print("ere")
		var ssspanel = preload("res://scenes/UI/SSScontainer.tscn").instance()
		_UI_scene.add_child(ssspanel)
		_UI_scene.get_node("SSScontainer").set_character_reference(a_character, b_character, swappable)


func destroy_sss():
	if sss_panel_instanced:
		var sss_node = _UI_scene.get_node("SSScontainer")
		sss_node.on_world_button_pressed()

