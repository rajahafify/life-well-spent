class_name NpcController
extends CharacterBody2D

signal interacted()

@export var character_movement_path: NodePath = ^"Sprite"

var npc_state: NpcState

var _character_movement: CharacterMovement
var _proximity: Area2D

func _ready():
	npc_state = NpcState.new()
	_character_movement = get_node(character_movement_path) as CharacterMovement
	_proximity = $Proximity
	_proximity.body_entered.connect(_on_proximity_body_entered)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _character_movement and _character_movement.get_rect().has_point(_character_movement.to_local(get_global_mouse_position())):
			_interact()

func _on_proximity_body_entered(body):
	if body.name == "Player":
		_interact()

func _interact():
	npc_state.set_interacting(true)
	if _character_movement:
		_character_movement.face_player(get_global_mouse_position())
	interacted.emit()
