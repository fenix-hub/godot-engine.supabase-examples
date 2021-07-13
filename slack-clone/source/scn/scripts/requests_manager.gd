extends Node

func get_channels() -> DatabaseTask:
    var channels_query : SupabaseQuery = SupabaseQuery.new().select().from("channels")
    return Supabase.database.query(channels_query)

func get_user(id : String) -> DatabaseTask:
    var user_query : SupabaseQuery = SupabaseQuery.new().from("users").select().eq("id", id)
    return Supabase.database.query(user_query)

func get_user_avatar(id : String) -> StorageTask:
    return Supabase.storage.from("avatars").download("%s.png" % id)

func send_message(message : String, user_id : String, channel : int) -> DatabaseTask:
    var message_query : SupabaseQuery = SupabaseQuery.new().from("messages").insert([{message = message, user_id = user_id, channel_id = channel}])
    return Supabase.database.query(message_query)
    
func get_messages(channel : int) -> DatabaseTask:
    var messages_query : SupabaseQuery = SupabaseQuery.new().from("messages").select().eq("channel_id", str(channel))
    return Supabase.database.query(messages_query)

func update_user_status(id : String, status : String) -> DatabaseTask:
    var status_query : SupabaseQuery = SupabaseQuery.new().from("users").update({status = status}).eq("id", id)
    return Supabase.database.query(status_query)
