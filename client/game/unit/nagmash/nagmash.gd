extends "res://game/script/unit.gd"

var player
var targetId = 0
var attack = 0
var transform_ = 0
var initPosX = 0
var initPosY = 0
var castPosX = 0
var castPosY = 0
var isCasting = false
var movingToCastPos = false

var attack_counter = 0

func Init(id, level, posX, posY, game, player):
	.Init(id, "nagmash", player.Team(), level, posX, posY, game)
	self.player = player
	initPosX = PositionX()
	initPosY = PositionY()

func TakeDamage(amount, attackType):
	.TakeDamage(amount, attackType)
	if IsDead():
		player.OnKnightDead(self)

func Destroy():
	.Destroy()
	$AnimationPlayer.play("explosion")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
	
func Update():
	if isCasting:
		if movingToCastPos:
			if transform_ == 10:
				$AnimationPlayer.play("drop-2-1")
				transform_ += 1
			elif transform_ == 35:
				cast(castPosX, castPosY)
				$AnimationPlayer.play("drop-3-1")
				
				transform_ += 1
			elif transform_ == 45:
				$AnimationPlayer.play("drop-4")
				transform_ += 1
			elif transform_ >= 90:
				movingToCastPos = false	
				
			else:
				if transform_ == 0:
					$AnimationPlayer.play("drop-1")
					scaleAni(castPosX, castPosY, PositionX(), PositionY())
				transform_ += 1
		else:
			transform_ = 0
			z_index = Z_INDEX[.Layer()]
			isCasting = false
			setLayer(initialLayer())
			rescaleAni(castPosX, castPosY, PositionX(), PositionY())
	else:
		if attack > 0:
			handleAttack()
		else:
			var t = target()
			if t == null:
				findTargetAndAttack()
			else:
				if withinRange(t):
					handleAttack()
				else:
					findTargetAndAttack()

func scaleAni(tar_x,tar_y, sta_x, sta_y):
	var tarX = tar_x/6553.6
	var tarY = tar_y/6533.6
	var staX = sta_x/6553.6
	var staY = sta_y/6553.6
	var destV = Vector2(tarX - staX, tarY - staY)
	var aniV = Vector2(0, -800)
	var angle = aniV.angle_to(destV)
	var sizeRatio = destV.length()/aniV.length()
	var resultV = aniV.rotated(angle) * sizeRatio
	
	var anim_go = $AnimationPlayer.get_animation("drop-2-1")
	var track_idx = anim_go.find_track("Rotatable/Body:position")
	var idx_num = anim_go.track_get_key_count(track_idx)
	for i in idx_num:
		var ori_value = anim_go.track_get_key_value(track_idx, i)
		var new_value = ori_value.rotated(angle) * sizeRatio
		anim_go.track_set_key_value(track_idx, i, new_value)
		
#	var anim_go = $AnimationPlayer.get_animation("drop-2-1")
#	var track_num = anim_go.get_track_count()
#	for i in track_num:
#		var idx_num =  anim_go.track_get_key_count(i)
#		for j in idx_num:
#			#print(" track name = ", anim_go.track_get_path(i) , " key #", j , " = ", ori_value)
#			if String(anim_go.track_get_path(i)).find(":position") > 0:
#				var ori_value = anim_go.track_get_key_value(i, j)
#				var new_value = ori_value.rotated(angle) * sizeRatio
#				anim_go.track_set_key_value(i, j, new_value)
#				print(" track name = ", anim_go.track_get_path(i) , " key #", j , " = ", ori_value , " =>> ", new_value)
		
	
		
	var anim_drop = $AnimationPlayer.get_animation("drop-3-1")
	track_idx = anim_drop.find_track("Rotatable/Body:position")
	idx_num = anim_drop.track_get_key_count(track_idx)
	for i in idx_num:
		var ori_value = anim_drop.track_get_key_value(track_idx, i)
		var new_value = ori_value.rotated(angle) * sizeRatio
		anim_drop.track_set_key_value(track_idx, i, new_value)
		
	var anim_back = $AnimationPlayer.get_animation("drop-4")
	track_idx = anim_back.find_track("Rotatable/Body:position")
	idx_num = anim_back.track_get_key_count(track_idx)
	for i in idx_num:
		var ori_value = anim_back.track_get_key_value(track_idx, i)
		var new_value = ori_value.rotated(angle) * sizeRatio
		anim_back.track_set_key_value(track_idx, i, new_value)
		
func rescaleAni(tar_x,tar_y, sta_x, sta_y):
	var tarX = tar_x/6553.6
	var tarY = tar_y/6533.6
	var staX = sta_x/6553.6
	var staY = sta_y/6553.6
	var destV = Vector2(tarX - staX, tarY - staY)
	var aniV = Vector2(0, -800)
	var angle = aniV.angle_to(destV) * -1
	var sizeRatio = destV.length()/aniV.length()
	var resultV = aniV.rotated(angle) * sizeRatio
	
	var anim_go = $AnimationPlayer.get_animation("drop-2-1")
	var track_idx = anim_go.find_track("Rotatable/Body:position")
	var idx_num = anim_go.track_get_key_count(track_idx)
	for i in idx_num:
		var ori_value = anim_go.track_get_key_value(track_idx, i)
		var new_value = ori_value.rotated(angle) / sizeRatio
		anim_go.track_set_key_value(track_idx, i, new_value)
		
	var anim_drop = $AnimationPlayer.get_animation("drop-3-1")
	track_idx = anim_drop.find_track("Rotatable/Body:position")
	idx_num = anim_drop.track_get_key_count(track_idx)
	for i in idx_num:
		var ori_value = anim_drop.track_get_key_value(track_idx, i)
		var new_value = ori_value.rotated(angle) / sizeRatio
		anim_drop.track_set_key_value(track_idx, i, new_value)
		
	var anim_back = $AnimationPlayer.get_animation("drop-4")
	track_idx = anim_back.find_track("Rotatable/Body:position")
	idx_num = anim_back.track_get_key_count(track_idx)
	for i in idx_num:
		var ori_value = anim_back.track_get_key_value(track_idx, i)
		var new_value = ori_value.rotated(angle) / sizeRatio
		anim_back.track_set_key_value(track_idx, i, new_value)
		

func findTargetAndAttack():
	var t = findTarget()
	setTarget(t)
	if t != null and withinRange(t):
		handleAttack()
	else:
		$AnimationPlayer.play("idle")

func CastSkill(posX, posY):
	if isCasting:
		return false
	attack = 0
	isCasting = true
	movingToCastPos = true
	castPosX = game.World().FromPixel(posX)
	castPosY = game.World().FromPixel(posY)
	setLayer("Casting")
	init_rotation()
	return true

func cast(x,y):
	var damage = stat.cards[Skill()]["damage"][level]
	var radius = game.World().FromPixel(stat.cards[Skill()]["radius"])
	for id in game.UnitIds():
		var u = game.FindUnit(id)
		if u.Team() == Team():
			continue
		var d = squaredDistanceTo(u)
		var r = scalar.Add(Radius(), radius)
		if d < scalar.Mul(r, r):
			u.TakeDamage(damage, "Skill")
	
	# client only
	var skill = resource.SKILL[name_].instance()
	game.get_node("Skills").add_child(skill)
	skill.position = Vector2(x/6553.6,y/6553.6)
	skill.z_index = Z_INDEX["Skill"]
	var anim = skill.get_node("AnimationPlayer")
	anim.play("explosion")
	yield(anim, "animation_finished")
	skill.queue_free()

func target():
	return game.FindUnit(targetId)
	
func setTarget(unit):
	if unit == null:
		targetId = 0
	else:
		targetId = unit.Id()
	
func handleAttack():
	if attack == 0:
		$AnimationPlayer.play("attack")
	var t = target()
	if t != null:
		look_at(t.PositionX(), t.PositionY())
	if attack == preAttackDelay():
		if t != null and withinRange(t):
			fire()
		else:
			attack = 0
			return
	attack += 1
	if attack > attackInterval():
		attack = 0

func fire():
	var b = resource.BULLET[name_].instance()
	b.Init(targetId, bulletLifeTime(), attackDamage(), game)
	game.AddBullet(b)
	
	# client only
	if attack_counter % 2 == 0:
		b.global_position = $Rotatable/Body/ShotpointL.global_position
	else:
		b.global_position = $Rotatable/Body/ShotpointR.global_position
	attack_counter += 1
