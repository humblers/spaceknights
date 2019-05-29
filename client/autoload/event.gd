extends Node

signal LoadSceneCompleted()

# For game
signal GameInitialized(game)

signal BlueEnergyUpdated(energy)
signal BluePlayerInitialized(player)
signal RedEnergyUpdated(energy)
signal RedPlayerInitialized(player)

signal BlueKnightHalfDamaged(side)
signal BlueKnightDead(side)
signal RedKnightHalfDamaged(side)
signal RedKnightDead(side)

signal BlueMothershipDeckUpdate(side, charging_ratio)
signal RedMothershipDeckUpdate(side, charging_ratio)

signal BlueSetHand1(card)
signal BlueSetHand2(card)
signal BlueSetHand3(card)
signal BlueSetHand4(card)
signal BlueHandFocused(index)
signal RedSetHand1(card)
signal RedSetHand2(card)
signal RedSetHand3(card)
signal RedSetHand4(card)
signal RedHandFocused(index)

signal BlueSetNext(card)
signal BlueUpdateNext(ready)
signal RedSetNext(card)
signal RedUpdateNext(ready)

signal RunwayRotate(num, angle)

# For lobby
signal LobbyInitialized()

const Pages = ["Shop", "Card", "Battle", "Explore", "Social"]
signal PageSelected(page)
signal VerticalScrollInput(released, dy)
signal InvalidateLobby()
signal InvalidateHUD()
signal InvalidatePageBattle()
signal InvalidatePageCard()

const PopupModalConfirm = "ModalConfirm"
const PopupModalMessage = "ModalMessage"
const PopupSetting      = "PopupSetting"
signal RequestPopup(kind, args)
signal ModalConfirmed(tf)

const PopupContentsCardInfo  = "PopupContentsCardInfo"
const PopupContentsChestInfo = "PopupContentsChestInfo"
signal RequestPoupInContents(kind, args)

const DialogCardUpgrade = "DialogCardUpgrade"
const DialogChestOpen   = "DialogChestOpen"
const DialogMatchwating = "DialogMatchWaiting"
signal RequestDialog(kind, args)

signal PageCardPickedCardItem(card)

# For tutorial
signal StudentUseCard(card)
signal PhaseChanged(phase)
signal MarkAt(global_pos)
signal MarkOff()
signal TransmissionOff()
signal TransmissionTerminated()