extends Node

func get_all_users() -> DatabaseTask:
    var usersquery : SupabaseQuery = SupabaseQuery.new().select().from("users")
    return Supabase.database.query(usersquery)

func get_channels() -> DatabaseTask:
    var channels_query : SupabaseQuery = SupabaseQuery.new().select().from("channels").Is("with_user",null)
    return Supabase.database.query(channels_query)

func get_user(id : String) -> DatabaseTask:
    var user_query : SupabaseQuery = SupabaseQuery.new().from("users").select(["*", "user_roles(role)"]).eq("id", id)
    return Supabase.database.query(user_query)

func get_user_roles(id : String) -> DatabaseTask:
    var user_query : SupabaseQuery = SupabaseQuery.new().from("user_roles").select().eq("id", id)
    return Supabase.database.query(user_query)

func get_user_avatar(id : String) -> StorageTask:
    return Supabase.storage.from("avatars").download(id)

func get_message_media(media_name : String) -> StorageTask:
    return Supabase.storage.from("messages").download(media_name)

# @media_attached: TImageHolder array
func send_message(message : String, channel : int, media_attached : Array = []) -> DatabaseTask:
    var media_name_attached : Array
    if not media_attached.empty():
        for media in media_attached:
            media_name_attached.append(media.id)
    var message_query : SupabaseQuery = SupabaseQuery.new().from("messages").insert([
        {
            message = message, 
            user_id = Globals.user.id, 
            channel_id = channel,
            media_attached = media_name_attached
        }])
    return Supabase.database.query(message_query)
    
func delete_message(id : int) -> DatabaseTask:
    var delete_query : SupabaseQuery = SupabaseQuery.new().from("messages").delete().eq("id", str(id))
    return Supabase.database.query(delete_query)
    
func get_messages(channel : int) -> DatabaseTask:
    var messages_query : SupabaseQuery = SupabaseQuery.new().from("messages").select().eq("channel_id", str(channel))
    return Supabase.database.query(messages_query)

func get_user_dm_channels() -> DatabaseTask:
    var dm_query : SupabaseQuery = SupabaseQuery.new().from("channels").select(["id", "inserted_at", "created_by(username, id)", "with_user(username, id)"]) \
    .like("slug", Globals.user.id) \
    .Is("with_user", null, true)
    return Supabase.database.query(dm_query)

func get_dms(channel : int) -> DatabaseTask:
    var messages_query : SupabaseQuery = SupabaseQuery.new().from("dms").select().eq("channel_id", str(channel))
    return Supabase.database.query(messages_query)

func update_user_status(status : String) -> DatabaseTask:
    var status_query : SupabaseQuery = SupabaseQuery.new().from("users").update({status = status}).eq("id", Globals.user.id)
    return Supabase.database.query(status_query)

func upload_message_imgs(media_name : String, media_path : String) -> StorageTask:
    return Supabase.storage.from("messages").upload(media_name, media_path)

func delete_message_media(media : Array) -> StorageTask:
    return Supabase.storage.from("messages").remove(media as PoolStringArray)

func add_new_channel(slug : String, description : String) -> DatabaseTask:
    var add_query : SupabaseQuery = SupabaseQuery.new().from("channels").insert([
        {
            slug = slug,
            description = description,
            created_by = Globals.user.id   
        }
       ])
    return Supabase.database.query(add_query)

func add_new_dm_channel(to_user : String) -> DatabaseTask:
    var add_query : SupabaseQuery = SupabaseQuery.new().from("channels").insert([
        {
            slug = Globals.user.id+":"+to_user,
            description = "Private Chat",
            created_by = Globals.user.id,
            with_user = to_user
        }
       ])
    return Supabase.database.query(add_query)

func update_username(username : String) -> DatabaseTask:
    var update_query : SupabaseQuery = SupabaseQuery.new().from("users").eq("id", Globals.user.id).update({username = username})
    return Supabase.database.query(update_query)

func update_user_avatar(path : String, new : bool = true) -> StorageTask:
    if new:
        return Supabase.storage.from("avatars").upload(Globals.user.id, path)
    else:
        return Supabase.storage.from("avatars").update(Globals.user.id, path)
        
