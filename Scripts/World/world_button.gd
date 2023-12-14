extends TextureButton


func _ready() -> void:
	connect("pressed", self, "_world_button_pressed")

func _world_button_pressed():
	events.emit_signal("world_pressed")

