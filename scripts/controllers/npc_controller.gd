class_name NpcController
extends CharacterBody2D

signal interacted(npc)

@export var character_movement_path: NodePath = ^"Sprite"
@export var player_path: NodePath = ^"../Player"

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
			get_viewport().set_input_as_handled()
			interact_with_player(_resolve_player_position())

func _on_proximity_body_entered(body):
	if body.name == "Player":
		interact_with_player(body.global_position)

func interact_with_player(player_global_pos: Vector2) -> void:
	npc_state.set_interacting(true)
	npc_state.face_player(player_global_pos - global_position)
	if _character_movement:
		_character_movement.set_facing(npc_state.facing)
	interacted.emit(self)

func _resolve_player_position() -> Vector2:
	var player := get_node_or_null(player_path) as Node2D
	if player:
		return player.global_position
	return get_global_mouse_position()
