extends VBoxContainer

signal selected(channel)
signal add_new_channel()

export (PackedScene) var channel_btn_scn : PackedScene
export (Texture) var collapsed_texture : Texture
export (Texture) var uncollapsed_texture : Texture

var collapsed : bool = true

func set_mode(_mode : int) -> void:
    $Container/TextButton.set_mode(_mode)
    $Container/AddChannel.set_mode(_mode)

func _ready():
    add_to_group("slack_components")
    
    Supabase.realtime.client()

func add_channel(channel : Channel) -> void:
    var channel_btn : TextButton = channel_btn_scn.instance()
    $ChannelButtons.add_child(channel_btn)
    channel_btn.set_text("# "+channel.slug)
    channel_btn.set_meta("channel", channel)
    channel_btn.set_mode(Globals.mode)
    channel_btn.modulate.a = 0.4
    channel_btn.connect("pressed", self, "_on_pressed", [channel_btn])

func _on_TextButton_pressed():
    collapsed = not collapsed
    $ChannelButtons.visible = collapsed
    if collapsed : $Container/TextButton.set_texture(collapsed_texture)
    else : $Container/TextButton.set_texture(uncollapsed_texture)

func _on_pressed(channel_btn : TextButton) -> void:
    select_channel(channel_btn.get_meta("channel"))

func select_channel(channel : Channel) -> void:
    emit_signal("selected", channel)
    

func _on_AddChannel_pressed():
    emit_signal("add_new_channel")
