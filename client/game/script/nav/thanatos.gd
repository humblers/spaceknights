extends Reference

var tileWidth
var tileHeight
var tileNumX
var tileNumY
var centerX
var centerY

# Areas
var top
var bottom
var lefthole
var righthole
var leftshield
var centershield
var rightshield

# Portals
var topToLefthole
var topToRighthole
var bottomToLefthole
var bottomToRighthole
var leftholeToTop
var leftholeToBottom
var rightholeToTop
var rightholeToBottom

var world

func _init(world):
	self.world = world
	tileWidth = scalar.Mul(scalar.FromInt(50), world.scale)
	tileHeight = tileWidth
	tileNumX = scalar.FromInt(20)
	tileNumY = scalar.FromInt(34)
	centerX = scalar.Div(scalar.Mul(tileWidth, tileNumX), scalar.Two)
	centerY = scalar.Div(scalar.Mul(tileHeight, tileNumY), scalar.Two)
	top = {
		"b": scalar.Mul(tileHeight, scalar.Sub(scalar.Div(tileNumY, scalar.Two), scalar.One)),
	}
	bottom = {
		"t": scalar.Mul(tileHeight, scalar.Add(scalar.Div(tileNumY, scalar.Two), scalar.One)),
	}
	lefthole = {
		"t": top.b,
		"b": bottom.t,
		"l": scalar.Mul(tileWidth, scalar.FromInt(3)),
		"r": scalar.Mul(tileWidth, scalar.FromInt(6)),
	}
	righthole = {
		"t": lefthole.t,
		"b": lefthole.b,
		"l": scalar.Sub(scalar.Mul(tileWidth, tileNumX), lefthole.r),
		"r": scalar.Sub(scalar.Mul(tileWidth, tileNumX), lefthole.l),
	}
	leftshield = {
		"t": lefthole.t,
		"b": lefthole.b,
		"l": 0,
		"r": lefthole.l,
	}
	centershield = {
		"t": lefthole.t,
		"b": lefthole.b,
		"l": lefthole.r,
		"r": righthole.l,
	}
	rightshield = {
		"t": lefthole.t,
		"b": lefthole.b,
		"l": righthole.r,
		"r": scalar.Mul(tileWidth, tileNumX),
	}
	topToLefthole = {
		"left_x": lefthole.r,
		"left_y": lefthole.t,
		"right_x": lefthole.l,
		"right_y": lefthole.t,
	}
	topToRighthole = {
		"left_x": righthole.r,
		"left_y": righthole.t,
		"right_x": righthole.l,
		"right_y": righthole.t,
	}
	bottomToLefthole = {
		"left_x": lefthole.l,
		"left_y": lefthole.b,
		"right_x": lefthole.r,
		"right_y": lefthole.b,
	}
	bottomToRighthole = {
		"left_x": righthole.l,
		"left_y": righthole.b,
		"right_x": righthole.r,
		"right_y": righthole.b,
	}
	leftholeToTop = {
		"left_x": lefthole.l,
		"left_y": lefthole.t,
		"right_x": lefthole.r,
		"right_y": lefthole.t,
	}
	leftholeToBottom = {
		"left_x": lefthole.r,
		"left_y": lefthole.b,
		"right_x": lefthole.l,
		"right_y": lefthole.b,
	}
	rightholeToTop = {
		"left_x": righthole.l,
		"left_y": righthole.t,
		"right_x": righthole.r,
		"right_y": righthole.t,
	}
	rightholeToBottom = {
		"left_x": righthole.r,
		"left_y": righthole.b,
		"right_x": righthole.l,
		"right_y": righthole.b,
	}

func Width():
	return scalar.Mul(tileWidth, tileNumX)

func Height():
	return scalar.Mul(tileHeight, tileNumY)

func TileWidth():
	return tileWidth

func TileHeight():
	return tileHeight

func TileNumX():
	return scalar.ToInt(tileNumX)

func TileNumY():
	return scalar.ToInt(tileNumY)

func MaxTileYOnTop():
	return scalar.ToInt(tileNumY) / 2 - 2

func MinTileYOnBot():
	return scalar.ToInt(tileNumY) / 2 + 1

func GetObstacles():
	return [leftshield, centershield, rightshield]

func FindNextCornerInPath(from_x, from_y, to_x, to_y, radius):
	var path = findPath(from_x, from_y, to_x, to_y, radius)
#	print_path(path)
	path = narrowPath(path, radius)
	return nextCornerInPath(path, from_x, from_y)

func print_path(path):
	for p in path:
		for k in p:
			print(world.ToPixel(p[k]))
	
func getLocation(pos_x, pos_y, radius):
	if pos_y < scalar.Sub(top.b, radius):
		return top
	if pos_y > scalar.Add(bottom.t, radius):
		return bottom
	if pos_x > scalar.Add(lefthole.l, radius) and pos_x < scalar.Sub(lefthole.r, radius):
		return lefthole
	if pos_x > scalar.Add(righthole.l, radius) and pos_x < scalar.Sub(righthole.r, radius):
		return righthole
	return null

func findPath(from_x, from_y, to_x, to_y, radius):
	var path = []
	var src = getLocation(from_x, from_y, radius)
	var dst = getLocation(to_x, to_y, radius)
	match src:
		top:
			match dst:
				bottom:
					if from_x < centerX:
						path = [topToLefthole, leftholeToBottom]
					else:
						path = [topToRighthole, rightholeToBottom]
				lefthole:
					path = [topToLefthole]
				righthole:
					path = [topToRighthole]
		bottom:
			match dst:
				top:
					if from_x < centerX:
						path = [bottomToLefthole, leftholeToTop]
					else:
						path = [bottomToRighthole, rightholeToTop]
				lefthole:
					path = [bottomToLefthole]
				righthole:
					path = [bottomToRighthole]
		lefthole:
			match dst:
				top:
					path = [leftholeToTop]
				bottom:
					path = [leftholeToBottom]
				righthole:
					if from_y < centerY:
						path = [leftholeToTop, topToRighthole]
					else:
						path = [leftholeToBottom, bottomToRighthole]
		righthole:
			match dst:
				top:
					path = [rightholeToTop]
				bottom:
					path = [rightholeToBottom]
				lefthole:
					if from_y < centerY:
						path = [rightholeToTop, topToLefthole]
					else:
						path = [rightholeToBottom, bottomToLefthole]
	path.append({"left_x": to_x, "left_y": to_y, "right_x": to_x, "right_y": to_y})
	return path

func narrowPath(path, radius):
	var new_path = []
	for p in path:
		match p:
			topToLefthole, topToRighthole:
				new_path.append({
					"left_x": scalar.Add(p.left_x, -radius),
					"left_y": scalar.Add(p.left_y, -radius),
					"right_x": scalar.Add(p.right_x, radius),
					"right_y": scalar.Add(p.right_y, -radius),
				})
			bottomToLefthole, bottomToRighthole:
				new_path.append({
					"left_x": scalar.Add(p.left_x, radius),
					"left_y": scalar.Add(p.left_y, radius),
					"right_x": scalar.Add(p.right_x, -radius),
					"right_y": scalar.Add(p.right_y, radius),
				})
			leftholeToTop, rightholeToTop:
				new_path.append({
					"left_x": scalar.Add(p.left_x, radius),
					"left_y": scalar.Add(p.left_y, -radius),
					"right_x": scalar.Add(p.right_x, -radius),
					"right_y": scalar.Add(p.right_y, -radius),
				})
			leftholeToBottom, rightholeToBottom:
				new_path.append({
					"left_x": scalar.Add(p.left_x, -radius),
					"left_y": scalar.Add(p.left_y, radius),
					"right_x": scalar.Add(p.right_x, radius),
					"right_y": scalar.Add(p.right_y, radius),
				})
			_:
				new_path.append(p)
	return new_path
	
static func nextCornerInPath(path, start_x, start_y):
	assert(len(path) > 0)
	var portalLeft_x = path[0].left_x
	var portalLeft_y = path[0].left_y
	var portalRight_x = path[0].right_x
	var portalRight_y = path[0].right_y
	var left_x = scalar.Sub(portalLeft_x, start_x)
	var left_y = scalar.Sub(portalLeft_y, start_y)
	var right_x = scalar.Sub(portalRight_x, start_x)
	var right_y = scalar.Sub(portalRight_y, start_y)
	for i in range(1, len(path)):
		var portal = path[i]
		var newPortalLeft_x = portal.left_x
		var newPortalLeft_y = portal.left_y
		var newPortalRight_x = portal.right_x
		var newPortalRight_y = portal.right_y
		var newLeft_x = scalar.Sub(newPortalLeft_x, start_x)
		var newLeft_y = scalar.Sub(newPortalLeft_y, start_y)
		var newRight_x = scalar.Sub(newPortalRight_x, start_x)
		var newRight_y = scalar.Sub(newPortalRight_y, start_y)
		if vector.Cross(left_x, left_y, newLeft_x, newLeft_y) >= 0:
			if vector.Cross(right_x, right_y, newLeft_x, newLeft_y) > 0:
				return [portalRight_x, portalRight_y]
			portalLeft_x = newPortalLeft_x
			portalLeft_y = newPortalLeft_y
			left_x = newLeft_x
			left_y = newLeft_y
		if vector.Cross(right_x, right_y, newRight_x, newRight_y) <= 0:
			if vector.Cross(left_x, left_y, newRight_x, newRight_y) < 0:
				return [portalLeft_x, portalLeft_y]
			portalRight_x = newPortalRight_x
			portalRight_y = newPortalRight_y
			right_x = newRight_x
			right_y = newRight_y
	return [portalLeft_x, portalLeft_y]

static func AreaWidth(area):
	return scalar.Div(scalar.Sub(area.r, area.l), scalar.Two)

static func AreaHeight(area):
	return scalar.Div(scalar.Sub(area.b, area.t), scalar.Two)

static func AreaPosX(area):
	return scalar.Div(scalar.Add(area.l, area.r), scalar.Two)

static func AreaPosY(area):
	return scalar.Div(scalar.Add(area.t, area.b), scalar.Two)