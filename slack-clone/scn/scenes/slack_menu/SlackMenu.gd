extends PanelContainer

export (PackedScene) var channel_scene : PackedScene

var colors : Dictionary = {
    bg = [Color("f8f8fa"), Color("272727")]
   }

signal channel_selected(channel_meta)
signal dm_channel_selected(channel_meta)

signal add_channel(channel)

var realtime_client : RealtimeClient

var channels : Array = []


func _ready():
    add_to_group("slack_components")
    connect_client()
    
func connect_client():
    realtime_client = Supabase.realtime.client()
    realtime_client.connect("connected", self, "_on_connected")
    realtime_client.connect_client()

func _on_connected() -> void:
    realtime_client.channel("public", "channels") \
    .on("insert", self, "_on_insert") \
    .on("delete", self, "_on_delete") \
    .subscribe()

func _on_delete(old_channel : Dictionary, channel : RealtimeChannel) -> void:
    pass

func _on_insert(new_channel : Dictionary, channel : RealtimeChannel) -> void:
    if new_channel.with_user == null : add_channel(new_channel)
    else: add_dm_channel(new_channel)

func load_channels() -> void:
    var task : DatabaseTask = yield(RequestsManager.get_channels(), "completed")
    if task.error: 
        printerr(task.error)
        return
    for channel in task.data:
        add_channel(channel)
    emit_signal("channel_selected", channels[0])

func load_dm_channels() -> void:
    var task : DatabaseTask = yield(RequestsManager.get_user_dm_channels(), "completed")
    if task.error : 
        printerr(task.error)
        return
    for channel in task.data:
        add_dm_channel(channel)

func add_channel(channel : Dictionary) -> void:
    var channel_scn : Channel = channel_scene.instance()
    channel_scn.initialize(channel.created_by, int(channel.id), channel.inserted_at, channel.slug, channel.description)
    channels.append(channel_scn)
    $VBoxContainer/Channels.add_channel(channel_scn)
    emit_signal("add_channel", channel_scn)


func add_dm_channel(channel : Dictionary) -> void:
    var channel_scn : Channel = channel_scene.instance()
    var created_by : String = channel.created_by.id if channel.created_by is Dictionary else channel.created_by
    var with_user : UsersManager.User = UsersManager.get_user_by_id(channel.with_user.id if channel.with_user is Dictionary else channel.with_user)
    var recipient : String = Globals.user.username if Globals.user.id != created_by else with_user.username
    channel_scn.initialize(created_by, int(channel.id), channel.inserted_at, recipient, "", true)
    channel_scn.set_with_user(with_user)
    channels.append(channel_scn)
    $VBoxContainer/DMs.add_channel(channel_scn)
    emit_signal("add_channel", channel_scn)


func has_dm_channel(with_user_id : String) -> Channel:
    for channel in channels:
        if channel.with_user != null and channel.with_user.id == with_user_id:
            return channel
    return null

# ---------------------------------------
func change_visibility() -> void:
    visible = not visible
    get_parent().rect_size.x = get_parent().get_parent().rect_size.x

func _on_channel_selected(channel : Channel):
    emit_signal("channel_selected", channel)


func set_mode(mode : int) -> void:
    get("custom_styles/panel").set("bg_color", colors.bg[mode])


func _on_ModeButton_pressed():
    Globals.set_mode(!Globals.mode)
