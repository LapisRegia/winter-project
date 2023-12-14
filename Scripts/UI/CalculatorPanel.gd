extends Control

const YUMI : int = 0b00
const YUME : int = 0b01
const YUUKO : int = 0b10

# position
const RECT_INACTIVE : int = 0
const RECT_STOWED : int = 1175
const RECT_POPPED : int = 0

onready var useDummyArrow = get_node("TrajectoryCalc/DummyFire") as Button
onready var dummyLabel = get_node("TrajectoryCalc/dummyArrowResult") as Label
onready var useRangefinder = get_node("TrajectoryCalc/RadioFire") as Button
onready var rangeLabel = get_node("TrajectoryCalc/rangeFinderResult") as Label

onready var headerLabel = get_node("Header") as Label
onready var descriptionLabel = get_node("Location/Description") as Label

onready var _tween = get_node("Tween") as Tween
onready var tab_button_1 = get_node("locButton") as Button
onready var tab_button_2 = get_node("calcButton") as Button
onready var tab_button_3 = get_node("aimButton") as Button
onready var tab_button_4 = get_node("notesButton") as Button

onready var tab1 = get_node("Location") as Control
onready var tab2 = get_node("TrajectoryCalc") as Control
onready var tab3 = get_node("Angle") as Control
onready var tab4 = get_node("Notes") as Control

onready var notes_yumi = get_node("Notes/NotesYumi") as ColorRect
onready var notes_yume = get_node("Notes/NotesYume") as ColorRect
onready var notes_yuuko = get_node("Notes/NotesYuuko") as ColorRect

onready var tab_content : Array = [tab1,tab2,tab3,tab4]
onready var tab_buttons : Array = [tab_button_1,tab_button_2,tab_button_3,tab_button_4]
onready var notes : Array = [notes_yumi,notes_yume,notes_yuuko]

var originButton : TextureButton
var destinationButton : TextureButton
var explorableData : Explorables
var presentCharacters : Array

var _is_popped_up: bool = false


func _ready() -> void:
	var index : int = 0
	while index != tab_content.size():
		tab_content[index].rect_position.x = 0
		tab_content[index].visible = false
		tab_buttons[index].connect("pressed", self, "show_tab", [tab_buttons[index], tab_content[index]])
		index += 1
	
	for note in notes:
		note.visible = false
	
	tab_button_1.disabled = true
	tab1.visible = true
	dummyLabel.visible = false
	rangeLabel.visible = false
	useRangefinder.disabled = true
	useDummyArrow.disabled = true
	events.connect("world_pressed", self, "world_button_pressed")


func show_tab(clicked_button : Button, content : Control):
	clicked_button.disabled = true 
	content.visible = true
	var index : int = 0
	for buttons in get_tree().get_nodes_in_group("tab_buttons"):
		if buttons.get_name() != clicked_button.get_name():
			hide_tab(buttons, tab_content[index])
		index += 1


func hide_tab(button : Button, content : Control):
	button.disabled = false 
	content.visible = false
	

func setter(originButton : TextureButton, destinationButton : TextureButton,
			 data : Explorables, presentCharacters : Array):
	self.originButton = originButton
	self.destinationButton = destinationButton
	self.explorableData = data
	self.presentCharacters = presentCharacters
	enable_buttons()
	set_notes_visible()
	show_result_if_was_pressed()
	for i in range(len(explorableData.notesArray)):
		notes[i].get_node("ColorRect/Content").text = explorableData.notesArray[i]
	headerLabel.text = explorableData.locationHeader
	descriptionLabel.text = explorableData.description


func update_present_characters():
	self.presentCharacters = presentCharacters

# what exactly does this do
# compares if the characters present == requiredCharacters
# the implementation of this function is constrained by the type of explorable
# this function assumes the "BGM-71" trio
# need extra implementation of other types of explorables that dont need the bgm71
func enable_buttons():
	for id in presentCharacters:
		if id in explorableData.requiredCharacters and id == 0:
			useDummyArrow.disabled = false
		elif id in explorableData.requiredCharacters and id == 1:
			useRangefinder.disabled = false
		elif id in explorableData.requiredCharacters and id == 2:
			# implementation of radio arrow fire needed
			pass

func show_result_if_was_pressed():
	if explorableData.dummyFirePressed:
		useDummyArrow.disabled = true
		useDummyArrow.visible = false
		dummyLabel.visible = true
		
	if explorableData.rangeFindPressed:
		useRangefinder.disabled = true
		useRangefinder.visible = false
		rangeLabel.visible = true


func set_notes_visible():
	for id in explorableData.characterHasTraversed:
		print(id)
		if id == YUMI:
			notes_yumi.visible = true
		elif id == YUME:
			notes_yume.visible = true
		elif id == YUUKO:
			notes_yuuko.visible = true


func pop_back_pre_check():
	if _is_popped_up:
		pop_back()


func pop_out():
	events.emit_signal("firing")
	WorldButtons.calc_panel_popped = true
	_pop(RECT_POPPED, true)


func pop_back():
	events.emit_signal("traversing")
	WorldButtons.calc_panel_popped = false
	_pop(RECT_STOWED, false)


func _pop(_rect_target_x : int, pop_state : bool):
	_tween.interpolate_property(
		self,
		"rect_position",
		rect_position,
		Vector2(_rect_target_x, rect_position.y),
		0.25,
		_tween.TRANS_SINE,
		_tween.EASE_OUT )
	_tween.start()
#	yield(_tween, "tween_completed")
	_is_popped_up = pop_state
	WorldButtons.calc_panel_popped = pop_state


func _on_DummyFire_pressed() -> void:
	print("Yumi: reachable. About... 50 meters.")
	dummyLabel.visible = true
	useDummyArrow.visible = false
	explorableData.dummyFirePressed = true


func _on_RadioFire_pressed() -> void:
	print("Yume: I only hear light crackles. no beeping... route is safe.")
	
	rangeLabel.visible = true
	useRangefinder.visible = false
	explorableData.rangeFindPressed = true
	pop_back_pre_check()
	
	var button_size: Vector2 = destinationButton.get_size() / 2
	var destination: Vector2 = destinationButton.get_global_position() + button_size
	events.emit_signal("set_camera", destination)
	yield(_tween,"tween_completed")
	originButton.post_success()
	

func world_button_pressed():
	if !WorldButtons.calc_panel_popped:
		WorldButtons.calc_panel_instanced  = false
		events.disconnect("world_pressed",self,"world_button_pressed")
		queue_free()


func _on_Bookmark_pressed() -> void:
	if !_is_popped_up:
		pop_out()
	else:
		pop_back_pre_check()
