extends Node

var foundQuests : Array = []

func _ready() -> void:
	pass

func startQuest (quest_data : QuestData):
	var quest_instance = quest_data.duplicate()
	quest_instance.active_status = true
	foundQuests.append(quest_instance)


func completeQuest(questToComplete : QuestData):
	for quests in foundQuests:
		if quests.title == questToComplete.title:
			quests.completed = true
	
