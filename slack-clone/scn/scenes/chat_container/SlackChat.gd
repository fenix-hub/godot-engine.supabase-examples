extends PanelContainer

var colors : Dictionary = {
    bg = [Color("ffffff"), Color("333333")]
   }

onready var channel_container : ScrollContainer = $Container/ChannelContainer

func set_channel(channel : Channel) -> void:
    var ch_name : String = ("# %s" % channel.slug) if not channel.is_dm else channel.slug
    $Container/Panel/HBoxContainer/Name.set_text(ch_name)
    $Container/Panel/HBoxContainer/Description.set_text(channel.description)

func _connect_signals():
    get_parent().get_node("SlackMenu").connect("add_channel", self, "_on_add_channel")

func _ready():
    $Container/Panel/HBoxContainer/Name.set_text("")
    $Container/Panel/HBoxContainer/Description.set_text("")
    _connect_signals()
    
    add_to_group("slack_components")

func _on_add_channel(channel : Channel) -> void:
    channel.connect("new_message", self, "_on_new_message")
    channel_container.add_child(channel)

func _on_new_message(message : Message) -> void:
    scroll()

func scroll() -> void:
    yield(get_tree(), "idle_frame")
    channel_container.scroll_vertical = Globals.current_channel.rect_size.y

func set_mode(mode : int) -> void:
    get("custom_styles/panel").set("bg_color", colors.bg[mode])
    $Container/Panel.get("custom_styles/panel").set("bg_color", colors.bg[mode])


func _on_InputContainer_pressed():
    Globals.filedrop_handler = $FileDropHandler
