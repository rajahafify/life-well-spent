class_name TestNpcState
extends TestCase

var npc: NpcState

func setup() -> void:
	npc = NpcState.new()

func test_initial_state_is_idle() -> void:
	assert_eq("idle", npc.state)

func test_initial_facing_is_down() -> void:
	assert_eq("down", npc.facing)

func test_face_player_right() -> void:
	npc.face_player(Vector2(100, 0))
	assert_eq("right", npc.facing)

func test_face_player_left() -> void:
	npc.face_player(Vector2(-100, 0))
	assert_eq("left", npc.facing)

func test_face_player_up() -> void:
	npc.face_player(Vector2(0, -100))
	assert_eq("up", npc.facing)

func test_face_player_down() -> void:
	npc.face_player(Vector2(0, 100))
	assert_eq("down", npc.facing)

func test_face_player_same_pos() -> void:
	npc.face_player(Vector2.ZERO)
	assert_eq("down", npc.facing)

func test_face_player_zero_delta() -> void:
	npc.face_player(Vector2.ZERO)
	assert_eq("down", npc.facing)

func test_assign_quest_sets_id() -> void:
	npc.assign_quest("fetch_wood")
	assert_eq("fetch_wood", npc.current_quest)

func test_assign_quest_overwrites() -> void:
	npc.assign_quest("fetch_wood")
	npc.assign_quest("kill_goblin")
	assert_eq("kill_goblin", npc.current_quest)

func test_clear_quest_resets() -> void:
	npc.assign_quest("fetch_wood")
	npc.clear_quest()
	assert_null(npc.current_quest)

func test_set_interacting() -> void:
	npc.set_interacting(true)
	assert_eq("interacting", npc.state)

func test_state_idle_on_interact_end() -> void:
	npc.set_interacting(true)
	npc.set_interacting(false)
	assert_eq("idle", npc.state)