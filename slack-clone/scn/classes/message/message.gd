extends PanelContainer
class_name Message

var user_name : String      setget set_user_name
var message : String        setget set_message
var avatar : ImageTexture   setget set_avatar

func _ready():
    hide()


func initialize(user_name : String, message : String, avatar : ImageTexture, user_status : String) -> void:
    set_user_name(user_name)
    set_message(message)
    set_avatar(avatar)
    set_status(user_status)
    show()


func set_status(status : String) -> void:
    match status:
        "OFFLINE": $Box/Avatar/Status.hide()
        "ONLINE": $Box/Avatar/Status.show()

func set_user(user) -> void:
    user.connect("update_picture", self, "set_avatar")
    user.connect("update_document", self, "update_user_data")
    user.connect("update_user", self , "_on_update_user")
    
func update_user_data(data : Dictionary) -> void:
    set_user_name(data.username)

func _on_update_user(user) -> void:
    set_status(user.status)
    

func set_user_name(_name : String) -> void:
    user_name = _name
    $Box/Container/Name.set_text(user_name)


func set_message(_message : String) -> void:
    message = _message
    $Box/Container/Content.set_text(message)


func set_avatar(_avatar : ImageTexture) -> void:
    avatar = _avatar
    $Box/Avatar.set_texture(avatar)
