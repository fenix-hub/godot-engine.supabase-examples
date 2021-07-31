extends Node

signal files_dropped(files)

func _ready():
    get_tree().connect("files_dropped", self, "_on_files_dropped")


func _on_files_dropped(files : PoolStringArray, screen : int):
    if Globals.filedrop_handler != self:
        return
    for file_dropped in files:
        if not file_dropped.get_extension() in ["png","jpg"]:
            return
    emit_signal("files_dropped", files)
