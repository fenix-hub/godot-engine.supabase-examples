extends SPopup
class_name PopupMessageMenu

signal delete_message(message)

var message

func _ready():
    pass

func set_permissions(role : String) -> void:
    match role:
        "admin":
            $Buttons/Delete.show()
        "moderator":
            $Buttons/Delete.show()
        _:
            $Buttons/Delete.hide()
            $Buttons/Delete.disabled = true

func _set_mode(_mode : int) -> void:
    for child in $Buttons.get_children():
        child.set_mode(_mode)

func set_message(message) -> void:
    self.message = message

func popup_on_pos(pos : Vector2) -> void:
    if not are_button_visible(): return
    popup(Rect2(pos - Vector2(162, 0), Vector2(20,20)))

func _on_Delete_pressed():
    message.hide()
    RequestsManager.delete_message(message.id)
    if not message.media.empty():
        RequestsManager.delete_message_media(message.media)
    emit_signal("delete_message", message)
    hide()

func are_button_visible() -> bool:
    for button in $Buttons.get_children():
        if button.visible:    
            return true
    return false

func _on_PopupMessageMenu_focus_exited():
    hide()
