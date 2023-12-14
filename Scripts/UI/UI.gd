extends CanvasLayer

export(NodePath) onready var _reset_camera = get_node(_reset_camera) as TextureButton
export(NodePath) onready var _time_label = get_node(_time_label) as Label
export(NodePath) onready var _walks_label = get_node(_walks_label) as Label

const _ALPHA_ACTIVE : float = 1.0
const _ALPHA_INACTIVE: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_time_label.set_text("%02d00 hours" % Main.crepuscular_start)
	_reset_camera.connect("pressed",self,"_reset_pressed" )


func _reset_pressed():
	events.emit_signal("reset_camera")


func change_time(updated_time):
	_time_label.set_text(updated_time)


func change_walks(updated_walks):
	_walks_label.set_text("Walks Remaining: %s" % [updated_walks])
	
