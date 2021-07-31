extends Node

var main : Control

var user : UsersManager.User
var s_user : SupabaseUser
var sending_message : bool = false
var current_channel : Channel = null
var popup_message_menu : Popup
var mode : int
var filedrop_handler : Control

func set_mode(i : int) -> void:
    mode = i
    get_tree().call_group("slack_components", "set_mode", mode)
