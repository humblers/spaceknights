extends Node

#class Area:
#	var T
#	var B
#	var L
#	var R

#class Portal:
#	var Left
#	var Right

var TILE_WIDTH = Q.FromInt(50)
var TILE_HEIGHT = TILE_WIDTH
var NX = Q.FromInt(20)
var NY = Q.FromInt(34)
var CENTER_X = Q.Div(Q.Mul(TILE_WIDTH, NX), Q.FromInt(2))
var CENTER_Y = Q.Div(Q.Mul(TILE_HEIGHT, NY), Q.FromInt(2))

# Areas
var Top = {
	"B": Q.Mul(TILE_HEIGHT, Q.Sub(Q.Div(NY, Q.FromInt(2)), Q.ONE)),
}
var Bottom = {
	"T": Q.Mul(TILE_HEIGHT, Q.Add(Q.Div(NY, Q.FromInt(2)), Q.ONE)),
}
var LeftHole = {
	"T": Top.B,
	"B": Bottom.T,
	"L": Q.Mul(TILE_WIDTH, Q.FromInt(3)),
	"R": Q.Mul(TILE_WIDTH, Q.FromInt(5)),
}
var RightHole = {
	"T": LeftHole.T,
	"B": LeftHole.B,
	"L": Q.Sub(Q.Mul(TILE_WIDTH, NX), LeftHole.R),
	"R": Q.Sub(Q.Mul(TILE_WIDTH, NX), LeftHole.L),
}
var Shield = {}

# Portal Points
var LeftHoleTL = Vec2.Create(LeftHole.L, LeftHole.T)
var LeftHoleTR = Vec2.Create(LeftHole.R, LeftHole.T)
var LeftHoleBL = Vec2.Create(LeftHole.L, LeftHole.B)
var LeftHoleBR = Vec2.Create(LeftHole.R, LeftHole.B)
var RightHoleTL = Vec2.Create(RightHole.L, RightHole.T)
var RightHoleTR = Vec2.Create(RightHole.R, RightHole.T)
var RightHoleBL = Vec2.Create(RightHole.L, RightHole.B)
var RightHoleBR = Vec2.Create(RightHole.R, RightHole.B)

# Portals
var TopToLeftHole = {"Left": LeftHoleTR, "Right": LeftHoleTL}
var TopToRightHole = {"Left": RightHoleTR, "Right": RightHoleTL}
var BottomToLeftHole = {"Left": LeftHoleBL, "Right": LeftHoleBR}
var BottomToRightHole = {"Left": RightHoleBL, "Right": RightHoleBR}
var LeftHoleToTop = {"Left": LeftHoleTL, "Right": LeftHoleTR}
var LeftHoleToBottom = {"Left": LeftHoleBR, "Right": LeftHoleBL}
var RightHoleToTop = {"Left": RightHoleTL, "Right": RightHoleTR}
var RightHoleToBottom = {"Left": RightHoleBR, "Right": RightHoleBL}

func GetLocation(pos, radius):
	if pos.Y < Q.Sub(Top.B, radius):
		return Top
	if pos.Y > Q.Add(Bottom.T, radius):
		return Bottom
	if pos.X > Q.Add(LeftHole.L, radius) and pos.X < Q.Sub(LeftHole.R, radius):
		return LeftHole
	if pos.X > Q.Add(RightHole.L, radius) and pos.X < Q.Sub(RightHole.R, radius):
		return RightHole
	return Shield

func FindPath(from, to, radius):
	var portals = []
	var src = GetLocation(from, radius)
	var dst = GetLocation(to, radius)
	match src:
		Top:
			match dst:
				Bottom:
					if from.X < CENTER_X:
						portals = [TopToLeftHole, LeftHoleToBottom]
					else:
						portals = [TopToRightHole, RightHoleToBottom]
				LeftHole:
					portals = [TopToLeftHole]
				RightHole:
					portals = [TopToRightHole]
		Bottom:
			match dst:
				Top:
					if from.X < CENTER_X:
						portals = [BottomToLeftHole, LeftHoleToTop]
					else:
						portals = [BottomToRightHole, RightHoleToTop]
				LeftHole:
					portals = [BottomToLeftHole]
				RightHole:
					portals = [BottomToRightHole]
		LeftHole:
			match dst:
				Top:
					portals = [LeftHoleToTop]
				Bottom:
					portals = [LeftHoleToBottom]
				RightHole:
					if from.Y < CENTER_Y:
						portals = [LeftHoleToTop, TopToRightHole]
					else:
						portals = [LeftHoleToBottom, BottomToRightHole]
		RightHole:
			match dst:
				Top:
					portals = [RightHoleToTop]
				Bottom:
					portals = [RightHoleToBottom]
				LeftHole:
					if from.Y < CENTER_Y:
						portals = [RightHoleToTop, TopToLeftHole]
					else:
						portals = [RightHoleToBottom, BottomToLeftHole]
#		Shield:
#			return null
	portals.append({"Left": to, "Right": to})
	return portals

func AdjustPath(path, radius):
	for portal in path:
		for k in portal:
			var pos = portal[k]
			match pos:
				LeftHoleTL, RightHoleTL:
					portal[k] = Vec2.Add(pos, Vec2.Create(radius, -radius))
				LeftHoleTR, RightHoleTR:
					portal[k] = Vec2.Add(pos, Vec2.Create(-radius, -radius))
				LeftHoleBL, RightHoleBL:
					portal[k] = Vec2.Add(pos, Vec2.Create(radius, radius))
				LeftHoleBR, RightHoleBR:
					portal[k] = Vec2.Add(pos, Vec2.Create(-radius, radius))
				
	
func NextCornerInPath(path, start):
	assert(len(path) > 0)
	var portalLeft = path[0].Left
	var portalRight = path[0].Right
	var left = Vec2.Sub(portalLeft, start)
	var right = Vec2.Sub(portalRight, start)
	for i in range(1, len(path)):
		var portal = path[i]
		var newPortalLeft = portal.Left
		var newPortalRight = portal.Right
		var newLeft = Vec2.Sub(newPortalLeft, start)
		var newRight = Vec2.Sub(newPortalRight, start)
		if Vec2.Cross(left, newLeft) >= 0:
			if Vec2.Cross(right, newLeft) > 0:
				return portalRight
			portalLeft = newPortalLeft
			left = newLeft
		if Vec2.Cross(right, newRight) <= 0:
			if Vec2.Cross(left, newRight) < 0:
				return portalLeft
			portalRight = newPortalRight
			right = newRight
	return portalLeft
		
	
	
	
	
	