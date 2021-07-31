extends PanelContainer
class_name UserButton

signal send_dm_to(user)

var user : UsersManager.User

func _ready():
    pass
    
func set_user(user : UsersManager.User) -> void:
    self.user = user
    user.connect("update_picture", $User/Avatar, "set_avatar")
    user.connect("update_user", self, "update_user")
    
    $User/Avatar.set_avatar(user.avatar)
    $User/Label.set_text(user.username)
    $User/Avatar.set_status(user.status)

func update_user(data : UsersManager.User) -> void:
    $User/Label.set_text(data.username)
    $User/Avatar.set_status(data.status)



func _on_OutlineButton_pressed():
    emit_signal("send_dm_to", user)
