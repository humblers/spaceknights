package nav

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

var (
	tileWidth  = fixed.FromInt(5)
	tileHeight = tileWidth
	tileNumX   = fixed.FromInt(20)
	tileNumY   = fixed.FromInt(34)
	centerX    = tileWidth.Mul(tileNumX).Div(fixed.Two)
	centerY    = tileHeight.Mul(tileNumY).Div(fixed.Two)
)

type area struct {
	t, b, l, r fixed.Number
}

type portal struct {
	left, right fixed.Vec2
}

var (
	top = &area{
		b: tileHeight.Mul(tileNumY.Div(fixed.Two).Sub(fixed.One)),
	}
	bottom = &area{
		t: tileHeight.Mul(tileNumY.Div(fixed.Two).Add(fixed.One)),
	}
	lefthole = &area{
		t: top.b,
		b: bottom.t,
		l: tileWidth.Mul(fixed.FromInt(3)),
		r: tileWidth.Mul(fixed.FromInt(5)),
	}
	righthole = &area{
		t: lefthole.t,
		b: lefthole.b,
		l: tileWidth.Mul(tileNumX).Sub(lefthole.r),
		r: tileWidth.Mul(tileNumX).Sub(lefthole.l),
	}
)

var (
	leftholeTL  = fixed.Vec2{lefthole.l, lefthole.t}
	leftholeTR  = fixed.Vec2{lefthole.r, lefthole.t}
	leftholeBL  = fixed.Vec2{lefthole.l, lefthole.b}
	leftholeBR  = fixed.Vec2{lefthole.r, lefthole.b}
	rightholeTL = fixed.Vec2{righthole.l, righthole.t}
	rightholeTR = fixed.Vec2{righthole.r, righthole.t}
	rightholeBL = fixed.Vec2{righthole.l, righthole.b}
	rightholeBR = fixed.Vec2{righthole.r, righthole.b}
)

var (
	topToLefthole     = &portal{leftholeTR, leftholeTL}
	topToRighthole    = &portal{rightholeTR, rightholeTL}
	bottomToLefthole  = &portal{leftholeBL, leftholeBR}
	bottomToRighthole = &portal{rightholeBL, rightholeBR}
	leftholeToTop     = &portal{leftholeTL, leftholeTR}
	leftholeToBottom  = &portal{leftholeBR, leftholeBL}
	rightholeToTop    = &portal{rightholeTL, rightholeTR}
	rightholeToBottom = &portal{rightholeBR, rightholeBL}
)

func NextCorner(from, to fixed.Vec2, radius fixed.Number) fixed.Vec2 {
	path := findPath(from, to, radius)
	narrowPath(path, radius)
	return nextCornerInPath(path, from)
}

func getLocation(pos fixed.Vec2, radius fixed.Number) *area {
	if pos.Y < top.b.Sub(radius) {
		return top
	}
	if pos.Y > bottom.t.Add(radius) {
		return bottom
	}
	if pos.X > lefthole.l.Add(radius) && pos.X < lefthole.r.Sub(radius) {
		return lefthole
	}
	if pos.X > righthole.l.Add(radius) && pos.X < righthole.r.Sub(radius) {
		return righthole
	}
	return nil
}

func findPath(from, to fixed.Vec2, radius fixed.Number) []*portal {
	var path []*portal
	src := getLocation(from, radius)
	dst := getLocation(to, radius)
	switch src {
	case top:
		switch dst {
		case bottom:
			if from.X < centerX {
				path = []*portal{topToLefthole, leftholeToBottom}
			} else {
				path = []*portal{topToRighthole, rightholeToBottom}
			}
		case lefthole:
			path = []*portal{topToLefthole}
		case righthole:
			path = []*portal{topToRighthole}
		}
	case bottom:
		switch dst {
		case top:
			if from.X < centerX {
				path = []*portal{bottomToLefthole, leftholeToTop}
			} else {
				path = []*portal{bottomToRighthole, rightholeToTop}
			}
		case lefthole:
			path = []*portal{bottomToLefthole}
		case righthole:
			path = []*portal{bottomToRighthole}
		}
	case lefthole:
		switch dst {
		case top:
			path = []*portal{leftholeToTop}
		case bottom:
			path = []*portal{leftholeToBottom}
		case righthole:
			if from.Y < centerY {
				path = []*portal{leftholeToTop, topToRighthole}
			} else {
				path = []*portal{leftholeToBottom, bottomToRighthole}
			}
		}
	case righthole:
		switch dst {
		case top:
			path = []*portal{rightholeToTop}
		case bottom:
			path = []*portal{rightholeToBottom}
		case lefthole:
			if from.Y < centerY {
				path = []*portal{rightholeToTop, topToLefthole}
			} else {
				path = []*portal{rightholeToBottom, bottomToLefthole}
			}
		}
	}
	path = append(path, &portal{to, to})
	return path
}

func narrowPath(path []*portal, radius fixed.Number) {
	for _, portal := range path {
		switch portal {
		case topToLefthole, topToRighthole:
			portal.left = portal.left.Add(fixed.Vec2{radius, -radius})
			portal.right = portal.left.Add(fixed.Vec2{-radius, -radius})
		case bottomToLefthole, bottomToRighthole:
			portal.left = portal.left.Add(fixed.Vec2{-radius, radius})
			portal.right = portal.left.Add(fixed.Vec2{radius, radius})
		case leftholeToTop, rightholeToTop:
			portal.left = portal.left.Add(fixed.Vec2{-radius, -radius})
			portal.right = portal.left.Add(fixed.Vec2{radius, -radius})
		case leftholeToBottom, rightholeToBottom:
			portal.left = portal.left.Add(fixed.Vec2{radius, radius})
			portal.right = portal.left.Add(fixed.Vec2{-radius, radius})
		}
	}
}

func nextCornerInPath(path []*portal, start fixed.Vec2) fixed.Vec2 {
	if len(path) <= 0 {
		panic("invalid path")
	}
	portalLeft := path[0].left
	portalRight := path[0].right
	left := portalLeft.Sub(start)
	right := portalRight.Sub(start)
	for _, portal := range path[1:] {
		newPortalLeft := portal.left
		newPortalRight := portal.right
		newLeft := newPortalLeft.Sub(start)
		newRight := newPortalRight.Sub(start)
		if left.Cross(newLeft) >= 0 {
			if right.Cross(newLeft) > 0 {
				return portalRight
			}
			portalLeft = newPortalLeft
			left = newLeft
		}
		if right.Cross(newRight) <= 0 {
			if left.Cross(newRight) < 0 {
				return portalLeft
			}
			portalRight = newPortalRight
			right = newRight
		}
	}
	return portalLeft
}
