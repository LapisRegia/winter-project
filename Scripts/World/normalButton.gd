extends TextureButton

onready var point_name : String = get_name()
export var adjacent_points : Array = []


func _ready() -> void:
	append_list()


func append_list():
	WorldButtons.adjacency_dict[point_name] = adjacent_points
