tool
extends Button

signal to_polygon()
signal to_collision()
signal to_occluder()

var selected = "none" 

func _pressed():
    $Popup.rect_position = rect_global_position
    $Popup.popup()

func _on_Popup_id_pressed(id):
    match id:
        0:
            emit_signal("to_polygon")
        1:
            emit_signal("to_collision")
        2:
            emit_signal("to_occluder")