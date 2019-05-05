extends Node

signal DoneBackgroundProcess

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

const MothershipDeckOpen = "deck_on"
const MothershipDeckClose = "deck_off"
const MothershipDeckCharging = "charging"
signal BlueMothershipDeckUpdate(state, side, charging_ratio)
signal RedMothershipDeckUpdate(state, side, charging_ratio)

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

# For lobby
const Pages = ["Battle", "Card", "Explore", "Shop", "Social"]
signal PageSelected(page)
signal VerticalScrollInput(released, dy)
signal InvalidateLobby
signal InvalidateHUD
signal InvalidatePageBattle

const PopupModalConfirm = "ModalConfirm"
const PopupModalMessage = "ModalMessage"
const PopupSetting      = "PopupSetting"
signal RequestPopup(kind, args)
signal ModalConfirmed(tf)

const DialogCardUpgrade = "DialogCardUpgrade"
const DialogChestOpen   = "DialogChestOpen"
const DialogMatchwating = "DialogMatchWaiting"
signal RequestDialog(kind, args)


# For tutorial
signal StudentUseCard(card)
signal PhaseChanged(phase)
signal MarkAt(global_pos)
signal MarkOff
signal TransmissionOff
signal TransmissionTerminated