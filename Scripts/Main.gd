# also known as the Character Controller.
extends Node

var days_remaining: int = 30
var crepuscular_start : int = 0.0
var crepuscular_day: bool = true
var panel_tracker : Dictionary = {}
# ["Yume" : "point8"]
# ["Yumi" : "point12"]
# ["Yuuko" : "pointx"]

# saves runtime character atrributes such as 
# health, radiation, endurance, max walks and depleted walks.
# since a stack assumes the highest depleted walks from the 2 characters
# attributes cant be shown normally (on a per character basis) and 
# when de stacking, one of the 2 character is healthier than the other,
# eg: stack is at 3am, and will be destacked. both characters will retain their original (singular) 
# attributes, as well as time slices, max and depleted walks.
# when calculating the remaining walks for the healthier character, do some division/ factorial math
# --a has 30, b has 20
# --10 walks has been made, so its effectively 10/20 or 1/2
# --30 * 1/2 = 15 = 0000 hours which lines up with b's time
var details_character : Array

func _ready() -> void:
	_start_turn()


func _start_turn():
	if crepuscular_day:
		crepuscular_start = 20
	else:
		crepuscular_start = 5


func _first_crepuscular_calc(no_of_turns) -> int:
	var time_slice = 480 / no_of_turns
	return time_slice


func _second_crepuscular_calc(no_of_turns) -> int:
	var time_slice = 300 / no_of_turns
	return time_slice


func reconnect():
	for characters in get_tree().get_nodes_in_group("Characters"):
		characters.connect_to_others()
