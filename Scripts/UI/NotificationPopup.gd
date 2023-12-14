extends Control

export var TEST = false
export var GUTTER_OFFSET = 540

func _ready() -> void:
	events.connect("alert", self, "notify")


func _on_AnimationPlayer_animation_finished(_anim_name):
	$PopupPanel.hide()


func notify(_text):
	$PopupPanel/Label.text = _text
	$PopupPanel.popup_centered()
	$PopupPanel.set_as_minsize()
	$PopupPanel.popup_centered()
	$PopupPanel.rect_position.y = get_viewport().size.y - GUTTER_OFFSET
	$AnimationPlayer.play("Fade")


