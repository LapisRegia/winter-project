extends TextureButton

export(NodePath) onready var adjacent_button = get_node(adjacent_button) as TextureButton
export(NodePath) onready var this_node = get_node(this_node) as TextureButton
export(NodePath) onready var child_nodes = get_node(child_nodes) as Area2D
export(Resource) onready var location_tres = location_tres as Explorables

onready var point_name : String = get_name()
onready var pinButton : TextureButton = get_node("pinButton")
onready var statusLabel : Label =  get_node("statusLabel")

export var unreachable_point : Array = []
export var adjacent_points : Array = []

var presentCharacters : Array

func _ready() -> void:
	append_list()
	pinButton.visible = location_tres.discovered
	statusLabel.visible = location_tres.discovered


func append_list():
	WorldButtons.adjacency_dict[point_name] = adjacent_points


func _on_Area2D_area_entered(area: Area2D) -> void:
	var charac_identifiers = area.get_parent().identifier
	append_character_has_traversed(charac_identifiers)
	pinButton.visible = true
	statusLabel.visible = true
	

func append_character_has_traversed(charac_identifiers : PoolIntArray ):
	presentCharacters = charac_identifiers
	for ids in charac_identifiers:
		if (ids in location_tres.characterHasTraversed) == false:
			location_tres.characterHasTraversed.append(ids)
	print (presentCharacters)
	print (location_tres.requiredCharacters)

# formerly known as "append_and_delete()"
# does exactly that.
func post_success():
	statusLabel.text = "traversed"
	WorldButtons.adjacency_dict[point_name] += unreachable_point


func _on_pinButton_pressed() -> void:
	if !WorldButtons.calc_panel_instanced:
		var calculatorPanel = load("res://scenes/UI/CalculatorPanel.tscn").instance()
		var calcPanel : Control
		WorldButtons._UI_scene.add_child(calculatorPanel)
		calcPanel = WorldButtons._UI_scene.get_node("CalculatorPanel")
		calcPanel.setter(this_node, adjacent_button, location_tres, presentCharacters)
		WorldButtons.calc_panel_instanced = true


func _on_Area2D_area_exited(area: Area2D) -> void:
	presentCharacters = []
	print (presentCharacters)
