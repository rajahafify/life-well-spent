class_name NpcController
extends CharacterBody2D

signal interacted(npc)

@export var character_movement_path: NodePath = ^"Sprite"
@export var player_path: NodePath = ^"../Player"
@export var display_name: String = "NPC"
@export var role: String = "generic"
@export_multiline var dialog_text: String = "Hello."
@export var quest_name: String = ""
@export var quest_cost: int = 40
@export_multiline var quest_description: String = ""
@export var life_task_id: String = ""
@export var talk_radius: float = 60.0
@export var solid_radius: float = 20.0
@export var talk_stop_buffer: float = 24.0
@export var name_label_path: NodePath = ^"NameLabel"
@export var definition: Resource

var npc_state: NpcState

var _character_movement: CharacterMovement
var _proximity: Area2D
var _name_label: Label

func _ready():
	_apply_definition()
	_ensure_state()
	_character_movement = get_node_or_null(character_movement_path) as CharacterMovement
	_proximity = get_node_or_null("Proximity") as Area2D
	if _proximity and not _proximity.body_entered.is_connected(_on_proximity_body_entered):
		_proximity.body_entered.connect(_on_proximity_body_entered)
	_name_label = get_node_or_null(name_label_path) as Label
	if _name_label:
		_name_label.text = display_name
		_name_label.visible = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _character_movement and _character_movement.get_rect().has_point(_character_movement.to_local(get_global_mouse_position())):
			get_viewport().set_input_as_handled()
			interact_with_player(_resolve_player_position())

func _on_proximity_body_entered(body):
	if body.name == "Player":
		interact_with_player(body.global_position)

func interact_with_player(player_global_pos: Vector2) -> void:
	face_toward_player(player_global_pos)
	interacted.emit(self)


func face_toward_player(player_global_pos: Vector2) -> void:
	_ensure_state()
	npc_state.set_interacting(true)
	npc_state.face_player(player_global_pos - global_position)
	if _character_movement == null:
		_character_movement = get_node_or_null(character_movement_path) as CharacterMovement
	if _character_movement:
		_character_movement.set_facing(npc_state.facing)


func is_player_in_talk_range(player_global_pos: Vector2) -> bool:
	return global_position.distance_to(player_global_pos) <= talk_radius


func talk_point_for(player_global_pos: Vector2) -> Vector2:
	var from_npc := player_global_pos - global_position
	var dir := from_npc.normalized() if from_npc != Vector2.ZERO else Vector2.DOWN
	var stop_distance: float = min(talk_radius - 1.0, solid_radius + talk_stop_buffer)
	return global_position + dir * stop_distance


func _ensure_state() -> void:
	if npc_state == null:
		npc_state = NpcState.new()


func _apply_definition() -> void:
	if definition == null:
		return
	display_name = definition.display_name
	role = definition.role
	dialog_text = definition.dialog_text
	quest_name = definition.quest_name
	quest_cost = definition.quest_cost
	quest_description = definition.quest_description
	life_task_id = definition.life_task_id


func _resolve_player_position() -> Vector2:
	var player := get_node_or_null(player_path) as Node2D
	if player:
		return player.global_position
	return get_global_mouse_position()
