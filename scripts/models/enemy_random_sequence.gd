## EnemyRandomSequence - deterministic random helpers for enemy behavior.
class_name EnemyRandomSequence
extends Object


static func unit(state) -> float:
	state.random_seed = int((1103515245 * state.random_seed + 12345) & 0x7fffffff)
	return float(state.random_seed % 10000) / 9999.0


static func range_value(state, min_value: float, max_value: float) -> float:
	return min_value + (max_value - min_value) * unit(state)


static func idle_duration(state, definition) -> float:
	return range_value(state, definition.idle_min_time, definition.idle_max_time)
