extends SPanel

signal hide_add_dm_panel()
signal send_dm_to_user(user)

export (PackedScene) var user_button_scn : PackedScene

onready var user_list : VBoxContainer = $VBoxContainer/UserListContainer/UserList

func _ready():
    pass # Replace with function body.

func load_users() -> void:
    var task : DatabaseTask = yield(RequestsManager.get_all_users(), "completed")
    for user_data in task.data:
        var user_button : UserButton = user_button_scn.instance()
        var user : UsersManager.User = UsersManager.get_user_by_id(user_data.id)
        user_list.add_child(user_button)
        user_button.set_user(user)
        user_button.connect("send_dm_to", self, "_on_send_dm_to")

func _on_Panel_visibility_changed():
    if visible:
        load_users()
                
func _on_send_dm_to(user : UsersManager.User) -> void:
    emit_signal("send_dm_to_user", user)

func _on_OutlineButton_pressed():
    hide()
    emit_signal("hide_add_dm_panel")
    clear()

func clear():
    for btn in user_list.get_children():
        btn.queue_free()
