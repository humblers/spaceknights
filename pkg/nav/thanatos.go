package nav

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"

type Map interface {
	GetObstacles() []*area
	FindNextCornerInPath(from, to fixed.Vector, radius fixed.Scalar)
}

type area struct {
	t, b, l, r fixed.Scalar
}

type portal struct {
	left, right fixed.Vector
}

type Thanatos struct {
	tileWidth  fixed.Scalar
	tileHeight fixed.Scalar
	tileNumX   fixed.Scalar
	tileNumY   fixed.Scalar
	centerX    fixed.Scalar
	centerY    fixed.Scalar

	// Areas
	top          *area
	bottom       *area
	lefthole     *area
	righthole    *area
	leftshield   *area
	centershield *area
	rightshield  *area

	// Portals
	topToLefthole     *portal
	topToRighthole    *portal
	bottomToLefthole  *portal
	bottomToRighthole *portal
	leftholeToTop     *portal
	leftholeToBottom  *portal
	rightholeToTop    *portal
	rightholeToBottom *portal
}

func NewThanatos(scale fixed.Scalar) *Thanatos {
	t := &Thanatos{}
	t.tileWidth = fixed.FromInt(50).Mul(scale)
	t.tileHeight = t.tileWidth
	t.tileNumX = fixed.FromInt(20)
	t.tileNumY = fixed.FromInt(34)
	t.centerX = t.tileWidth.Mul(t.tileNumX).Div(fixed.Two)
	t.centerY = t.tileHeight.Mul(t.tileNumY).Div(fixed.Two)
	t.top = &area{
		b: t.tileHeight.Mul(t.tileNumY.Div(fixed.Two).Sub(fixed.One)),
	}
	t.bottom = &area{
		t: t.tileHeight.Mul(t.tileNumY.Div(fixed.Two).Add(fixed.One)),
	}
	t.lefthole = &area{
		t: t.top.b,
		b: t.bottom.t,
		l: t.tileWidth.Mul(fixed.FromInt(3)),
		r: t.tileWidth.Mul(fixed.FromInt(5)),
	}
	t.righthole = &area{
		t: t.lefthole.t,
		b: t.lefthole.b,
		l: t.tileWidth.Mul(t.tileNumX).Sub(t.lefthole.r),
		r: t.tileWidth.Mul(t.tileNumX).Sub(t.lefthole.l),
	}
	t.leftshield = &area{
		t: t.lefthole.t,
		b: t.lefthole.b,
		l: 0,
		r: t.lefthole.l,
	}
	t.centershield = &area{
		t: t.lefthole.t,
		b: t.lefthole.b,
		l: t.lefthole.r,
		r: t.righthole.l,
	}
	t.rightshield = &area{
		t: t.lefthole.t,
		b: t.lefthole.b,
		l: t.righthole.r,
		r: t.tileWidth.Mul(t.tileNumX),
	}
	t.topToLefthole = &portal{
		fixed.Vector{t.lefthole.r, t.lefthole.t},
		fixed.Vector{t.lefthole.l, t.lefthole.t},
	}
	t.topToRighthole = &portal{
		fixed.Vector{t.righthole.r, t.righthole.t},
		fixed.Vector{t.righthole.l, t.righthole.t},
	}
	t.bottomToLefthole = &portal{
		fixed.Vector{t.lefthole.l, t.lefthole.b},
		fixed.Vector{t.lefthole.r, t.lefthole.b},
	}
	t.bottomToRighthole = &portal{
		fixed.Vector{t.righthole.l, t.righthole.b},
		fixed.Vector{t.righthole.r, t.righthole.b},
	}
	t.leftholeToTop = &portal{
		fixed.Vector{t.lefthole.l, t.lefthole.t},
		fixed.Vector{t.lefthole.r, t.lefthole.t},
	}
	t.leftholeToBottom = &portal{
		fixed.Vector{t.lefthole.r, t.lefthole.b},
		fixed.Vector{t.lefthole.l, t.lefthole.b},
	}
	t.rightholeToTop = &portal{
		fixed.Vector{t.righthole.l, t.righthole.t},
		fixed.Vector{t.righthole.r, t.righthole.t},
	}
	t.rightholeToBottom = &portal{
		fixed.Vector{t.righthole.r, t.righthole.b},
		fixed.Vector{t.righthole.l, t.righthole.b},
	}
	return t
}

func (t *Thanatos) GetObstacles() []*area {
	return []*area{t.leftshield, t.centershield, t.rightshield}
}

func (t *Thanatos) FindNextCornerInPath(from, to fixed.Vector, radius fixed.Scalar) fixed.Vector {
	path := t.findPath(from, to, radius)
	path = t.narrowPath(path, radius)
	return nextCornerInPath(path, from)
}

func (t *Thanatos) getLocation(pos fixed.Vector, radius fixed.Scalar) *area {
	if pos.Y < t.top.b.Sub(radius) {
		return t.top
	}
	if pos.Y > t.bottom.t.Add(radius) {
		return t.bottom
	}
	if pos.X > t.lefthole.l.Add(radius) && pos.X < t.lefthole.r.Sub(radius) {
		return t.lefthole
	}
	if pos.X > t.righthole.l.Add(radius) && pos.X < t.righthole.r.Sub(radius) {
		return t.righthole
	}
	return nil
}

func (t *Thanatos) findPath(from, to fixed.Vector, radius fixed.Scalar) []*portal {
	var path []*portal
	src := t.getLocation(from, radius)
	dst := t.getLocation(to, radius)
	switch src {
	case t.top:
		switch dst {
		case t.bottom:
			if from.X < t.centerX {
				path = []*portal{t.topToLefthole, t.leftholeToBottom}
			} else {
				path = []*portal{t.topToRighthole, t.rightholeToBottom}
			}
		case t.lefthole:
			path = []*portal{t.topToLefthole}
		case t.righthole:
			path = []*portal{t.topToRighthole}
		}
	case t.bottom:
		switch dst {
		case t.top:
			if from.X < t.centerX {
				path = []*portal{t.bottomToLefthole, t.leftholeToTop}
			} else {
				path = []*portal{t.bottomToRighthole, t.rightholeToTop}
			}
		case t.lefthole:
			path = []*portal{t.bottomToLefthole}
		case t.righthole:
			path = []*portal{t.bottomToRighthole}
		}
	case t.lefthole:
		switch dst {
		case t.top:
			path = []*portal{t.leftholeToTop}
		case t.bottom:
			path = []*portal{t.leftholeToBottom}
		case t.righthole:
			if from.Y < t.centerY {
				path = []*portal{t.leftholeToTop, t.topToRighthole}
			} else {
				path = []*portal{t.leftholeToBottom, t.bottomToRighthole}
			}
		}
	case t.righthole:
		switch dst {
		case t.top:
			path = []*portal{t.rightholeToTop}
		case t.bottom:
			path = []*portal{t.rightholeToBottom}
		case t.lefthole:
			if from.Y < t.centerY {
				path = []*portal{t.rightholeToTop, t.topToLefthole}
			} else {
				path = []*portal{t.rightholeToBottom, t.bottomToLefthole}
			}
		}
	}
	path = append(path, &portal{to, to})
	return path
}

func (t *Thanatos) narrowPath(path []*portal, radius fixed.Scalar) []*portal {
	var new_path []*portal
	for _, p := range path {
		switch p {
		case t.topToLefthole, t.topToRighthole:
			l := p.left.Add(fixed.Vector{-radius, -radius})
			r := p.right.Add(fixed.Vector{radius, -radius})
			new_path = append(new_path, &portal{l, r})
		case t.bottomToLefthole, t.bottomToRighthole:
			l := p.left.Add(fixed.Vector{radius, radius})
			r := p.right.Add(fixed.Vector{-radius, radius})
			new_path = append(new_path, &portal{l, r})
		case t.leftholeToTop, t.rightholeToTop:
			l := p.left.Add(fixed.Vector{radius, -radius})
			r := p.right.Add(fixed.Vector{-radius, -radius})
			new_path = append(new_path, &portal{l, r})
		case t.leftholeToBottom, t.rightholeToBottom:
			l := p.left.Add(fixed.Vector{-radius, radius})
			r := p.right.Add(fixed.Vector{radius, radius})
			new_path = append(new_path, &portal{l, r})
		default:
			new_path = append(new_path, p)
		}
	}
	return new_path
}

func nextCornerInPath(path []*portal, start fixed.Vector) fixed.Vector {
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
