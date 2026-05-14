## QuestDialogFlow - pure rules for reusable quest dialog panel states.
class_name QuestDialogFlow
extends Object

const STATE_NORMAL := "normal"
const STATE_QUEST_INCOMPLETE := "quest_incomplete"
const STATE_QUEST_COMPLETE := "quest_complete"
const STATE_REWARD := "reward"
const CLAIM_REWARD_ACTION := "Claim Reward"


func normal_panel(title: String, body: String) -> Dictionary:
	return {
		"state": STATE_NORMAL,
		"title": title,
		"body": body,
		"can_claim_reward": false,
		"action_text": CLAIM_REWARD_ACTION,
	}


func quest_panel(title: String, intro_text: String, claim_text: String, objective_text: String, is_complete: bool) -> Dictionary:
	var body := claim_text if is_complete else intro_text
	if objective_text != "":
		body += "\n\n%s" % objective_text
	return {
		"state": STATE_QUEST_COMPLETE if is_complete else STATE_QUEST_INCOMPLETE,
		"title": title,
		"body": body,
		"can_claim_reward": is_complete,
		"action_text": CLAIM_REWARD_ACTION,
	}


func reward_item_panel(display_name: String, quantity: int = 1) -> Dictionary:
	return reward_text_panel("Reward: %d x %s" % [quantity, display_name])


func reward_unlock_panel(display_name: String) -> Dictionary:
	return reward_text_panel("Reward: %s" % display_name)


func reward_text_panel(body: String) -> Dictionary:
	return {
		"state": STATE_REWARD,
		"title": "Reward",
		"body": body,
		"can_claim_reward": false,
		"action_text": CLAIM_REWARD_ACTION,
	}
