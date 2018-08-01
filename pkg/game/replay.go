package game

import "log"

type Replay struct {
	game   Game
	logger *log.Logger
}

func NewReplay(cfg Config, states []State, l *log.Logger) *Replay {
	/*
		g := newGame(cfg, nil)
		for _, s := range states {
			for _, a := range s.Actions {
				g.actions[s.Step] = append(g.actions[s.Step], a)
			}
		}
		return &Replay{
			game:   g,
			logger: l,
		}
	*/
	return &Replay{}
}

func (r *Replay) Run(step int) {
	for i := 0; i < step; i++ {
		//r.game.Update()
		//r.logger.Printf("%v:%v", r.game.step, r.game.world.Digest())
		//r.game.step++
	}
}
