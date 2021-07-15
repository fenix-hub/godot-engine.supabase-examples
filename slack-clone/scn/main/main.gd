extends Control

export (PackedScene) var channel_scene : PackedScene

onready var hover : ColorRect = $HOVER

onready var channels_tree : Tree = $Slack/PanelContainer/VBoxContainer/Channels
onready var dms_tree : Tree = $Slack/PanelContainer/VBoxContainer/DMs

var channels_root : TreeItem
var dms_root : TreeItem

var current_user : SupabaseUser
var current_channel : Channel

var channels : Array = []

func _ready():
    channels_root = channels_tree.create_item()
    dms_root = dms_tree.create_item()
    
    channels_root.set_text(0, "Channels")
    dms_root.set_text(0, "Direct Messages")


func load_slack() -> void:
    hover.hide()
    $Auth.hide()
    load_channels()


func load_channels() -> void:
    var task : DatabaseTask = yield(RequestsManager.get_channels(), "completed")
    if task.error: return
    for channel in task.data:
        var ch : TreeItem = channels_tree.create_item(channels_root)
        ch.set_text(0, "# %s" % channel.slug)
        var channel_scn : Channel = channel_scene.instance()
        channel_scn.initialize(channel.created_by, channel.id, channel.inserted_at, channel.slug)
        channels.append(channel_scn)
        ch.set_meta("channel", channel_scn)
        $Slack/PanelContainer2/VBoxContainer/ChannelContainer.add_child(channel_scn)
    set_current_channel(channels[0])


func load_messages() -> void:
    pass


func set_current_channel(channel) -> void:
    if not channel : return
    if current_channel: current_channel.hide()
    
    current_channel = channel
    $Slack/PanelContainer2/VBoxContainer/Panel/HBoxContainer/Label.set_text("#%s" % current_channel.slug)
    current_channel.show()
    current_channel.load_messages()


func authenticated(user : SupabaseUser):
    UsersManager.connect_rt_users()
    var _user : UsersManager.User = UsersManager.add_user(user.id, RequestsManager.get_user(user.id), RequestsManager.get_user_avatar(user.id))
    load_slack()
    current_user = user
    RequestsManager.update_user_status(user.id , "ONLINE")
    

func _on_Auth_signed_in(user : SupabaseUser):
    authenticated(user)


func _on_Auth_signed_up(user : SupabaseUser):
    authenticated(user)


func _on_Auth_error(error):
    print(error)


func _on_LineEdit_text_entered(new_text : String):
    $Slack/PanelContainer2/VBoxContainer/PanelContainer/PanelContainer/VBoxContainer/LineEdit.clear()
    var task : DatabaseTask = yield(RequestsManager.send_message(new_text, current_user.id, current_channel.id), "completed")

func _on_Channels_item_selected():
    if channels_tree.get_selected().has_meta("channel"):
        set_current_channel(channels_tree.get_selected().get_meta("channel"))

func _notification(what):
    match what:
        NOTIFICATION_WM_QUIT_REQUEST:
            hover.show()
            if current_user : yield(RequestsManager.update_user_status(current_user.id, "OFFLINE"), "completed")
            get_tree().quit()
