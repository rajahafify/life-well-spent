class_name NpcController
extends CharacterBody2D

signal interacted()

@export var character_movement_path: NodePath = ^"Sprite"

var npc_state: NpcState

var _character_movement: Sprite2D
var _proximity: Area2D

func _ready():
	npc_state = NpcState.new()
	_character_movement = get_node(character_movement_path)
	_proximity = $Proximity
	_proximity.body_entered.connect(_on_proximity_body_entered)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if get_node("Sprite").get_rect().has_point(to_local(get_global_mouse_position())):
			_interact()

func _on_proximity_body_entered(body):
	if body.name == "Player":
		_interact()

func _interact():
	npc_state.set_interacting(true)
	_character_movement.face_player(get_global_mouse_position())
	print("NPC interacted")
	interacted.emit()
