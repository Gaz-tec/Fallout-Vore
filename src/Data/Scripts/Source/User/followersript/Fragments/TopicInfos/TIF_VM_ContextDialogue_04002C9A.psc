;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname followersript:Fragments:TopicInfos:TIF_VM_ContextDialogue_04002C9A Extends TopicInfo Hidden Const

;BEGIN FRAGMENT Fragment_End
Function Fragment_End(ObjectReference akSpeakerRef)
Actor akSpeaker = akSpeakerRef as Actor
;BEGIN AUTOCAST TYPE FV_ContextVoreQuestScript
FV_ContextVoreQuestScript kmyQuest = GetOwningQuest() as FV_ContextVoreQuestScript
;END AUTOCAST
;BEGIN CODE
kmyQuest.RandomConvinceChance(true)
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
