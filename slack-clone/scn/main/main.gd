extends Control


onready var hover : ColorRect = $HOVER

onready var input_container : MarginContainer = $Slack/SlackChat/Container/InputContainer


var dms_root : TreeItem




func _connect_signals():    
    $Slack/SlackMenu.connect("channel_selected", self, "set_current_channel")
    input_container.connect("send_message", self, "_on_send_message")
    $Slack/SlackMenu/VBoxContainer/Channels.connect("add_new_channel", self, "_on_add_new_channel")
    $Slack/SlackMenu/VBoxContainer/DMs.connect("add_new_dm", self, "_on_add_new_dm")
    $Slack/SlackMenu/VBoxContainer/User.connect("logout", self, "_on_logout_pressed")
    $Slack/SlackMenu/VBoxContainer/User.connect("update_user", self, "_on_update_pressed")
    $Slack/MobileMenu.connect("menu_visibility", $Slack/SlackMenu, "change_visibility")
    
func set_app_mode(_mode : int) -> void:
    Globals.mode = _mode
    get_tree().call_group("supabase_components","set_mode", Globals.mode)
    get_tree().call_group("slack_components","set_mode", Globals.mode)
    

func _ready():
    if OS.get_name() == "Android": get_rect().size.x = OS.get_window_size().x
    _connect_signals()
    set_app_mode(0)
    $HOVER.show()
    $Auth.show()
    Globals.main = self

func load_messages() -> void:
    pass

func _on_show_media(media_preview : MediaPreview) -> void:
    $MediaHolder.show_media(media_preview)

func authenticated(user : SupabaseUser):
    UsersManager.connect_rt_users()
    var _user : UsersManager.User = UsersManager.add_user(user.id, RequestsManager.get_user(user.id), RequestsManager.get_user_avatar(user.id))
    _user.status = "ONLINE"
    Globals.user = _user
    Globals.s_user = user
    RequestsManager.update_user_status("ONLINE")
    load_slack()
    $Slack/SlackMenu/VBoxContainer/User.set_user(_user)
    $UpdateUserPanel.set_user(_user)
    

func _on_Auth_signed_in(user : SupabaseUser):
    authenticated(user)


func _on_Auth_signed_up(user : SupabaseUser):
    authenticated(user)


func _on_Auth_error(error):
    print(error)


# -------------------------------
func load_slack() -> void:
    hover.hide()
    $Auth.hide()
    $Slack/SlackMenu.load_channels()
    $Slack/SlackMenu.load_dm_channels()


func set_current_channel(channel) -> void:
    if not channel : return
    if Globals.current_channel: Globals.current_channel.hide()
    
    Globals.current_channel = channel
    $Slack/SlackChat.set_channel(Globals.current_channel)
    Globals.current_channel.show()
    Globals.current_channel.load_messages()
    input_container.set_placeholder_text("Send a message to #%s"%Globals.current_channel.slug)


# @media : Array of TImageHolder
func _on_send_message(text : String, media : Array = []):
    Globals.sending_message = true
    if not media.empty(): 
        for m in media: 
            yield(RequestsManager.upload_message_imgs(m.id, m.path), "completed")
    var task : DatabaseTask = yield(RequestsManager.send_message(text, Globals.current_channel.id, media), "completed")
    Globals.current_channel.add_user_message(task.data[0].id, text, media)
    input_container.clear()
    Globals.sending_message = false
    


func _notification(what):
    match what:
        NOTIFICATION_WM_QUIT_REQUEST:
            hover.show()
            if Globals.user : yield(RequestsManager.update_user_status("OFFLINE"), "completed")
            get_tree().quit()


func _on_add_new_channel() -> void:
    $HOVER.show()
    $AddChanelPanel.show()

func _on_add_new_dm() -> void:
    $HOVER.show()
    $AddDMPanel.show()

func _on_AddChanelPanel_hide_add_channel():
    $HOVER.hide()

func _on_update_pressed():
    $HOVER.show()
    $UpdateUserPanel.show()

func _on_logout_pressed():
    pass


func _on_UpdateUserPanel_hide_update_user():
    $HOVER.hide()


func _on_AddDMPanel_hide_add_dm_panel():
    $HOVER.hide()


func _on_AddDMPanel_send_dm_to_user(user : UsersManager.User):
    var channel : Channel = $Slack/SlackMenu.has_dm_channel(user.id)
    if channel:
        $Slack/SlackMenu/VBoxContainer/Channels.select_channel(channel)
    else:
        RequestsManager.add_new_dm_channel(user.id)
    $AddDMPanel._on_OutlineButton_pressed()
    
