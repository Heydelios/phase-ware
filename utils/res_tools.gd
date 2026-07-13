extends Object
class_name ResTools

static func resource_path(directory:String, filename:String="") -> String:
	return "res://%s/%s" % [directory, filename]

static func _list_contents(directory: String) -> PackedStringArray:
	assert(not directory.begins_with("res://"))
	return ResourceLoader.list_directory(resource_path(directory))

static func list_resources(directory:String, suffix:String="") -> Array[Resource]:
	var out:Array[Resource]
	for f in _list_contents(directory):
		if f.ends_with("/"):
			continue
		if f.ends_with(suffix) or not suffix:
			var res = load(resource_path(directory, f))
			res.resource_name = f.get_basename()
			out.append(res)
	return out

static func list_subdirectories(directory:String) -> Array[String]:
	var out:Array[String]
	for f in _list_contents(directory):
		if f.ends_with("/"):
			out.append(directory + "/" + f)
	return out
