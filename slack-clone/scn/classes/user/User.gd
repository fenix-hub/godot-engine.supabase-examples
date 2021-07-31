extends PanelContainer

signal update_user()
signal logout()

onready var popup_menu : SPopup = $PopupUser


func _ready():
    popup_menu._set_mode(Globals.mode)
    
func set_user(user : UsersManager.User) -> void:
    user.connect("update_picture", $User/Avatar, "set_avatar")
    user.connect("update_user", self, "update_user")
    
    $User/Avatar.set_avatar(user.avatar)
    set_user_name(user)
    $User/Avatar.set_status(user.status)
    popup_menu.set_permissions(user.role)

func update_user(data : UsersManager.User) -> void:
    set_user_name(data)
    $User/Avatar.set_status(data.status)
    popup_menu.set_permissions(data.role)

func set_user_name(user : UsersManager.User) -> void:
    $User/Label.set_text("%s (%s)"%[user.username, user.role])
    

func _on_Options_pressed():
    popup_menu.popup_on_pos(Vector2($User/Options.get_global_rect().size.x,0) + $User/Options.get_global_rect().position)


func _on_PopupUser_logout():
    emit_signal("logout")


func _on_PopupUser_update_user():
    emit_signal("update_user")
