@tool
extends Node
class_name NodeSpawner

static var i: NodeSpawner

static func spawn(scene:PackedScene, tree: SceneTree = null):
	if not NodeSpawner.i:
		if not tree:
			tree = Engine.get_main_loop() as SceneTree
		if tree:
			NodeSpawner.i = tree.get_nodes_in_group("node_spawner")[0]
			if NodeSpawner.i:
				print("node spawner set")
				pass
			else:
				print("node spawner not set")
				pass
	
	if Engine.is_editor_hint():
		return await i._spawn_editor(scene, tree)
	else:
		return await i._spawn(scene)

func _ready() -> void:
	if NodeSpawner.i:
		return
	NodeSpawner.i = self

func _spawn(scene: PackedScene):
	var node = scene.instantiate()
	get_tree().root.add_child.call_deferred(node)
	if not node.is_node_ready():
		await node.ready
	return node

func _spawn_editor(scene: PackedScene, tree: SceneTree):
	var node = scene.instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	add_child(node)
	node.owner = tree.edited_scene_root
	return node
