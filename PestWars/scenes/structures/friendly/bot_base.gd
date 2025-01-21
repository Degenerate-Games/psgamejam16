extends StaticBody3D

@onready var path = $Path3D
var path_followers = []


func add_path_follower(node: Node3D):
	var path_follower: PathFollow3D = PathFollow3D.new()
	node.get_parent().remove_child(node)
	node.global_transform = Transform3D.IDENTITY
	path_follower.add_child(node)
	path_followers.append(path_follower)
	path.add_child(path_follower)
	return path_follower
