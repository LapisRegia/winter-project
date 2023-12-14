tool
extends Control

onready var tab_1 = get_node("Button") as Button
onready var tab_2 = get_node("Button2") as Button
onready var tab_3 = get_node("Button3") as Button
onready var tab_4 = get_node("Button4") as Button

onready var text_1 = get_node("Text") as Label
onready var text_2 = get_node("Text2") as Label
onready var text_3 = get_node("Text3") as Label
onready var text_4 = get_node("Text4") as Label

onready var text : Array = [text_1,text_2,text_3,text_4]
onready var tab : Array = [tab_1,tab_2,tab_3,tab_4]


func _ready() -> void:
	var index : int = 0
	for tabs in tab:
		tabs.connect("pressed", self, "show_tab", [tabs, text[index]])
		index += 1


func show_tab(tab : Button, label :Label):
	tab.disabled = true 
	label.modulate.a = 1.0
	var index : int = 0
	for tabs in get_tree().get_nodes_in_group("tabs"):
		if tabs.get_name() != tab.get_name():
			hide_tab(tabs, text[index])
		index += 1


func hide_tab(tab : Button, label :Label):
	tab.disabled = false 
	label.modulate.a = 0

