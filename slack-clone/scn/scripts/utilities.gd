extends Node

func get_image_name(image_path : String) -> String:
    return (image_path.split("/") as Array).back() if image_path != "" else image_path

func get_texture(file_path : String) -> ImageTexture:
    var img : Image = Image.new()
    img.load(file_path)
    var texture : ImageTexture = ImageTexture.new()
    texture.create_from_image(img, 4)
    return texture

func task2image(task : StorageTask) -> ImageTexture:
    var new_image := Image.new()
    match typeof(task.data):
        TYPE_RAW_ARRAY:
            var data : PoolByteArray = task.data
            if data.size()>1:
                match data.subarray(0,1).hex_encode():
                    "ffd8":
                        new_image.load_jpg_from_buffer(data)
                    "8950":
                        new_image.load_png_from_buffer(data)
            else: 
                return null
        TYPE_DICTIONARY:
            printerr("ERROR %s: could not find image requested" % task.data.error.code)
            return null
    var new_texture := ImageTexture.new()
    new_texture.create_from_image(new_image, 4)
    return new_texture

func get_time() -> int:
    return OS.get_unix_time()

func parse_timestamp(ts : String) -> Dictionary:
    var datetime_dict : Dictionary = {}
    var datetime_array : PoolStringArray = ts.split("T")
    var date : PoolStringArray = datetime_array[0].split("-")
    var time : PoolStringArray = datetime_array[1].split(".")[0].split(":")
    datetime_dict = {
        day = date[2], month = date[1], year = date[0],
        hour = time[0], minute = time[1], second = time[2]
       }
    return datetime_dict

func get_human_time(t : int) -> String:
    var date : Dictionary = OS.get_datetime_from_unix_time(t)
    return ("{day}/{month}/{year}\n{hour}:{minute}").format({
        hour = date.hour,
        minute = ("0%s"%[date.minute] if str(date.minute).length() < 2 else (date.minute)),
        day = date.day,
        month = date.month,
        year = date.year
        })

func parse_content(_content : String):
    var parsed_content : String = _content
    var regex : RegEx = RegEx.new()
    var result : Array
