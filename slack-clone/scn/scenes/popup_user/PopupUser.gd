extends SPopup
class_name PopupUser

signal update_user()
signal logout()

func _set_mode(_mode : int) -> void:
    for child in $Buttons.get_children():
        child.set_mode(_mode)

func set_permissions(role : String) -> void:
    pass

func popup_on_pos(pos : Vector2 = Vector2.ZERO) -> void:
    popup()
    rect_position = pos


func _on_UpdateBtn_pressed():
    hide()
    emit_signal("update_user")


func _on_LogoutBtn_pressed():
    hide()
    emit_signal("logout")
