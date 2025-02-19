Scriptname FV_SAVHandlerScript extends Quest Conditional

ActorValue Property FV_HasHadNukaAcid Auto
FV_ConsumptionRegistryScript Property FV_ConsumptionRegistry Auto
FollowersScript Property Followers Auto
ReferenceAlias Property CompanionAlias Auto
ReferenceAlias Property CompanionPrey Auto
ReferenceAlias Property PlayerPrey Auto
;Topic Property VM_SAV_PlayerSwallow_Scene Auto
;Topic Property VM_SAV_CompanionSwallow_Scene Auto
;Topic Property VM_SAV_CompanionDigest_Scene Auto
Keyword Property ActorTypeAnimal Auto
Keyword Property ActorTypeCreature Auto
Keyword Property ActorTypeDeathclaw Auto
Keyword Property ActorTypeTurret Auto
Keyword Property FV_SAV_PlayerSwallowBN_Topic Auto
Keyword Property FV_SAV_PlayerSwallowAN_Topic Auto
Keyword Property FV_SAV_PlayerDigestBN_Topic Auto
Keyword Property FV_SAV_PlayerDigestAN_Topic Auto
Keyword Property FV_SAV_CompanionSwallow_Topic Auto
Keyword Property FV_SAV_CompanionDigest_Topic Auto
GlobalVariable Property FV_SkipPercentage Auto
GlobalVariable Property FV_SAV_General Auto
GlobalVariable Property FV_SAV_Timer_CompanionDigest Auto
GlobalVariable Property FV_SAV_Timer_CompanionSwallow Auto
GlobalVariable Property FV_SAV_Timer_PlayerDigest Auto
GlobalVariable Property FV_SAV_Timer_PlayerSwallow Auto


Struct EncDefinition
	keyword LocEncKeyword
;{Holds LocType Keywords}
	faction Associated_Faction
;{Holds Factions that correspond to LocEncKeywords}
	globalvariable LocEncGlobal
;{Holds Globals used as "enums" in dialogue conditions}

EndStruct

EncDefinition[] property EncDefinitions const auto
{Holds definitions for a Location Encounter Type - keyword on locations, a faction associated with that keyword, and an associated Global used in dialogue conditions}


Actor Companion = NONE
Int iTimerID_SAV_PlayerSwallow = 0
Int iTimerID_SAV_CompanionSwallow = 1
Int iTimerID_SAV_CompanionDigest = 2
Int iTimerID_SAV_PlayerDigest = 3
int iForceGeneralComments = 999

Float SAV_PlayerSwallow = -1.0 conditional
Float SAV_PlayerDigest = -1.0 conditional
Float SAV_CompanionSwallow = -1.0 conditional
Float SAV_CompanionDigest = -1.0 conditional

Bool CommentBlock_SAV_PlayerSwallow = false conditional
Bool CommentBlock_SAV_PlayerDigest = false conditional
Bool CommentBlock_SAV_CompanionSwallow = false conditional
Bool CommentBlock_SAV_CompanionDigest = false conditional

Int DigestEventStart = 3

Event OnInit()
	Companion = CompanionAlias.GetActorRef()
	EventRegistration()
EndEvent

Function EventRegistration()
	;grabbed wholesale form thicc.  Delete events not needed
	RegisterForCustomEvent(FV_ConsumptionRegistry, "OnSwallow")
	;RegisterForCustomEvent(FV_ConsumptionRegistry, "OnVomit")
	RegisterForCustomEvent(FV_ConsumptionRegistry, "OnDigest")
	;RegisterForCustomEvent(Followers, "CompanionChange")
EndFunction

EncDefinition Function GetEncDefinition(keyword KeywordToFind = None, location LocationToCheck = None, Faction FactionToCheck = None, Actor PreyToCheck = None)
	;finds the first matching item
	int i = 0
	while (i < EncDefinitions.length)
		
		if KeywordToFind && EncDefinitions[i].LocEncKeyword == KeywordToFind
			RETURN EncDefinitions[i]
		endif
		
		if LocationToCheck && LocationToCheck.HasKeyword(EncDefinitions[i].LocEncKeyword)
			RETURN EncDefinitions[i]
		endif

		if FactionToCheck && EncDefinitions[i].Associated_Faction == FactionToCheck
			RETURN EncDefinitions[i]
		endif

		if PreyToCheck && PreyToCheck.IsInFaction(EncDefinitions[i].Associated_Faction)
			RETURN EncDefinitions[i]
		endif

		i += 1
	endwhile
	return NONE
EndFunction

Event FV_ConsumptionRegistryScript.OnDigest(FV_ConsumptionRegistryScript akSend, Var[] akArgs)
	If(CompanionAlias.GetActorRef() == NONE || CompanionAlias.GetActorRef().HasKeyword(ActorTypeCreature) || CompanionAlias.GetActorRef().HasKeyword(ActorTypeAnimal))
		FV_ConsumptionRegistry.trace(self, "SAVHandler reports companion is a Creature or a None form. Skipping dialogue event.")
	Else
		Int EventType = akArgs[1] as Int
		If(EventType == DigestEventStart && CompanionAlias != NONE)
			Actor PredToCheck = akArgs[0] as Actor
			Actor PreyToCheck = akArgs[2] as Actor
			Companion = CompanionAlias.GetActorRef()
			FV_ConsumptionRegistry.trace(self, "  SAV: Received OnDigest event. PredToCheck: " + PredToCheck + "; PreyToCheck: " + PreyToCheck)
			If(Companion != NONE)
				int chanceToSkip = Utility.randomint()
				If(!Companion.IsTalking() && !PreyToCheck.HasKeyword(ActorTypeTurret) && (PreyToCheck.HasKeyword(ActorTypeDeathclaw) || chanceToSkip > FV_SkipPercentage.GetValue() as int))
					If(PredToCheck == Companion)
						CompanionPrey.ForceRefTo(PreyToCheck)
						SetSAV_CompanionDigest(PreyToCheck)
					ElseIf(PredToCheck == Game.GetPlayer())
						PlayerPrey.ForceRefTo(PreyToCheck)
						SetSAV_PlayerDigest(PreyToCheck)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndEvent

Event FV_ConsumptionRegistryScript.OnSwallow(FV_ConsumptionRegistryScript akSender, Var[] akArgs)
	;debug.notification("received swallow event")
	If(CompanionAlias.GetActorRef() == NONE || CompanionAlias.GetActorRef().HasKeyword(ActorTypeCreature) || CompanionAlias.GetActorRef().HasKeyword(ActorTypeAnimal))
		FV_ConsumptionRegistry.trace(self, "SAVHandler reports companion is a Creature or a None form. Skipping dialogue event.")
	Else
		int chanceToSkip = Utility.randomint()
		Actor PredToCheck = akArgs[0] as Actor
		Bool isLethal = akArgs[1] as Bool
		Actor PreyToCheck = akArgs[2] as Actor
		FV_ConsumptionRegistry.trace(self, "  SAV: Received OnSwallow event. PredToCheck: " + PredToCheck + "; IsLethal: " + isLethal + "; PreyToCheck: " + PreyToCheck)
		Companion = CompanionAlias.GetActorRef()
		If(Companion != NONE)
			If(!Companion.IsTalking() && !PreyToCheck.HasKeyword(ActorTypeTurret) && !PreyToCheck.IsDead() && (PreyToCheck.HasKeyword(ActorTypeDeathclaw) || chanceToSkip > FV_SkipPercentage.GetValue() as int))
				If(PredToCheck == Game.GetPlayer())
					PlayerPrey.ForceRefTo(PreyToCheck)
					SetSAV_PlayerSwallow(PreyToCheck)
				ElseIf(PredToCheck == Companion)
					CompanionPrey.ForceRefTo(PreyToCheck)
					SetSAV_CompanionSwallow(PreyToCheck)
				EndIf
			EndIf
		EndIf
	EndIf
EndEvent

Event OnTimerGameTime(Int aiTimerID)
	If(aiTimerID == iTimerID_SAV_PlayerSwallow)
		ClearSAV_PlayerSwallow()
		PlayerPrey.Clear()
		;debug.notification("Cleared player swallow variables")
	ElseIf(aiTimerID == iTimerID_SAV_PlayerDigest)
		ClearSAV_PlayerDigest()
		PlayerPrey.Clear()
		;debug.notification("Cleared player digest variables")
	ElseIf(aiTimerID == iTimerID_SAV_CompanionSwallow)
		ClearSAV_CompanionSwallow()
		CompanionPrey.Clear()
		;debug.notification("Cleared companion swallow variables")
	ElseIf(aiTimerID == iTimerID_SAV_CompanionDigest)
		ClearSAV_CompanionDigest()
		CompanionPrey.Clear()
		;debug.notification("Cleared companion digest variables")
	EndIf
EndEvent

Function ClearSAV_PlayerSwallow()
	SAV_PlayerSwallow = -1.0
	CommentBlock_SAV_PlayerSwallow = false
EndFunction

Function ClearSAV_PlayerDigest()
	SAV_PlayerDigest = -1.0
	CommentBlock_SAV_PlayerDigest = false
EndFunction

Function ClearSAV_CompanionSwallow()
	SAV_CompanionSwallow = -1.0
	CommentBlock_SAV_CompanionSwallow = false
EndFunction

Function ClearSAV_CompanionDigest()
	SAV_CompanionDigest = -1.0
	CommentBlock_SAV_CompanionDigest = false
EndFunction

Function SetSAV_PlayerSwallow(Actor PreyToCheck = NONE)
	;clear timer and variables to make sure deathclaws always fire with no interruption
	If(PreyToCheck != NONE && PreyToCheck.HasKeyword(ActorTypeDeathclaw) && CommentBlock_SAV_PlayerSwallow)
		;Cancel timer to prevent alias clearing
		CancelTimerGameTime(iTimerID_SAV_PlayerSwallow)
		ClearSAV_PlayerSwallow()
	EndIf
	If(PreyToCheck != NONE && !CommentBlock_SAV_PlayerSwallow)
		EncDefinition FoundEncDefinition = GetEncDefinition(PreyToCheck = PreyToCheck)
		If(FoundEncDefinition != NONE)
			SAV_PlayerSwallow = FoundEncDefinition.LocEncGlobal.value
			;debug.notification("SAV_PlayerSwallow: " + SAV_PlayerSwallow)
		Else
			SAV_PlayerSwallow = FV_SAV_General.value
		EndIf
		;debug.notification("Sending say event to companion")
		If(CompanionAlias != NONE)
			If(CompanionAlias.GetActorRef().GetValue(FV_HasHadNukaAcid)==0)
				CompanionAlias.GetActorRef().SayCustom(FV_SAV_PlayerSwallowBN_Topic)
			Else
				CompanionAlias.GetActorRef().SayCustom(FV_SAV_PlayerSwallowAN_Topic)
			EndIf
			CommentBlock_SAV_PlayerSwallow = true
			StartTimerGameTime(FV_SAV_Timer_PlayerSwallow.GetValue(), iTimerID_SAV_PlayerSwallow)
		EndIF
	EndIf
EndFunction

Function SetSAV_PlayerDigest(Actor PreyToCheck = NONE)
	;clear timer and variables to make sure deathclaws always fire with no interruption
	If(PreyToCheck != NONE && PreyToCheck.HasKeyword(ActorTypeDeathclaw) && CommentBlock_SAV_PlayerDigest)
		;Cancel timer to prevent alias clearing
		CancelTimerGameTime(iTimerID_SAV_PlayerDigest)
		ClearSAV_PlayerDigest()
	EndIf
	If(PreyToCheck != NONE && !CommentBlock_SAV_PlayerDigest)
		EncDefinition FoundEncDefinition = GetEncDefinition(PreyToCheck = PreyToCheck)
		If(FoundEncDefinition != NONE)
			SAV_PlayerDigest = FoundEncDefinition.LocEncGlobal.value
			;debug.notification("SAV_PlayerDigest: " + SAV_PlayerDigest)
		Else
			SAV_PlayerDigest = FV_SAV_General.value
		EndIf
		;debug.notification("Sending say event to companion")
		If(CompanionAlias != NONE)
			If(CompanionAlias.GetActorRef().GetValue(FV_HasHadNukaAcid)==0)
				CompanionAlias.GetActorRef().SayCustom(FV_SAV_PlayerDigestBN_Topic)
			Else
				CompanionAlias.GetActorRef().SayCustom(FV_SAV_PlayerDigestAN_Topic)
			EndIf
			CommentBlock_SAV_PlayerDigest = true
			StartTimerGameTime(FV_SAV_Timer_PlayerDigest.GetValue(), iTimerID_SAV_PlayerDigest)
		EndIF
	EndIf
EndFunction

Function SetSAV_CompanionSwallow(Actor PreyToCheck = NONE)
	;clear timer and variables to make sure deathclaws always fire with no interruption
	If(PreyToCheck != NONE && PreyToCheck.HasKeyword(ActorTypeDeathclaw) && CommentBlock_SAV_CompanionSwallow)
		;Cancel timer to prevent alias clearing
		CancelTimerGameTime(iTimerID_SAV_CompanionSwallow)
		ClearSAV_CompanionSwallow()
	EndIf
	If(PreyToCheck != NONE && !CommentBlock_SAV_CompanionSwallow)
		EncDefinition FoundEncDefinition = GetEncDefinition(PreyToCheck = PreyToCheck)
		If(FoundEncDefinition != NONE)
			SAV_CompanionSwallow = FoundEncDefinition.LocEncGlobal.value
			;debug.notification("SAV_CompanionSwallow: " + SAV_CompanionSwallow)
		Else
			SAV_CompanionSwallow = FV_SAV_General.value
		EndIf
		If(CompanionAlias != NONE)
			CompanionAlias.GetActorRef().SayCustom(FV_SAV_CompanionSwallow_Topic)
			CommentBlock_SAV_CompanionSwallow = true
			StartTimerGameTime(FV_SAV_Timer_CompanionSwallow.GetValue(), iTimerID_SAV_CompanionSwallow)
		EndIf
	EndIf
EndFunction

Function SetSAV_CompanionDigest(Actor PreyToCheck = NONE)
	;clear timer and variables to make sure deathclaws always fire with no interruption
	If(PreyToCheck != NONE && PreyToCheck.HasKeyword(ActorTypeDeathclaw) && CommentBlock_SAV_CompanionDigest)
		;Cancel timer to prevent alias clearing
		CancelTimerGameTime(iTimerID_SAV_CompanionDigest)
		ClearSAV_CompanionDigest()
	EndIf
	If(PreyToCheck != NONE && !CommentBlock_SAV_CompanionDigest)
		EncDefinition FoundEncDefinition = GetEncDefinition(PreyToCheck = PreyToCheck)
		If(FoundEncDefinition != NONE)
			SAV_CompanionDigest = FoundEncDefinition.LocEncGlobal.value
			;debug.notification("SAV_CompanionDigest: " + SAV_CompanionDigest)
		Else
			SAV_CompanionDigest = FV_SAV_General.value
		EndIf
		If(CompanionAlias != NONE)
			CompanionAlias.GetActorRef().SayCustom(FV_SAV_CompanionDigest_Topic)
			CommentBlock_SAV_CompanionDigest = true
			StartTimerGameTime(FV_SAV_Timer_CompanionDigest.GetValue(), iTimerID_SAV_CompanionDigest)
		EndIf
	EndIf
EndFunction

Function ResetSAVSystem()
	CancelTimerGameTime(iTimerID_SAV_PlayerSwallow)
	CancelTimerGameTime(iTimerID_SAV_PlayerDigest)
	CancelTimerGameTime(iTimerID_SAV_CompanionSwallow)
	CancelTimerGameTime(iTimerID_SAV_CompanionDigest)
	ClearSAV_PlayerSwallow()
	ClearSAV_PlayerDigest()
	ClearSAV_CompanionSwallow()
	ClearSAV_CompanionDigest()
	PlayerPrey.Clear()
	CompanionPrey.Clear()
	debug.messagebox("Reset SAV System.")
EndFunction