extends SPanel

signal menu_visibility()


func _ready():
    if OS.get_name() != "Android": hide()
    add_to_group("slack_components")

func _on_MenuBtn_pressed():   
    emit_signal("menu_visibility")
