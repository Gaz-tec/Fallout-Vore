;BEGIN FRAGMENT CODE - Do not edit anything between this and the end comment
Scriptname followersript:Fragments:Scenes:SF_ContextDialogue1_0400222B Extends Scene Hidden Const

;BEGIN FRAGMENT Fragment_Phase_03_End
Function Fragment_Phase_03_End()
;BEGIN AUTOCAST TYPE FV_ContextVoreQuestScript
FV_ContextVoreQuestScript kmyQuest = GetOwningQuest() as FV_ContextVoreQuestScript
;END AUTOCAST
;BEGIN CODE
kmyQuest.EndDialogue()
;END CODE
EndFunction
;END FRAGMENT

;END FRAGMENT CODE - Do not edit anything between this and the begin comment
