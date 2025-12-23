local monster = {}

monster.name = "[GODMODE] Keepah (Boss)"
monster.type = GODMODE.registry.entities.keepah_boss.type
monster.variant = GODMODE.registry.entities.keepah_boss.variant

-- how many vertical lanes to create for the boss fight (0 = center!)
local num_lanes = 5
-- set the vertical offset 
local min_lane = -3
-- how tall are the lanes?
local lane_size = 52

-- this is the animation based on the subtype of the attack
local head_attack_anims = {
    [GODMODE.registry.entities.keepah_boss_head_still.subtype] = "AttackStill",
    [GODMODE.registry.entities.keepah_boss_head_move.subtype] = "AttackMove",
    [GODMODE.registry.entities.keepah_boss_head_both.subtype] = "AttackAlternate",
    [GODMODE.registry.entities.keepah_boss_head_both_alt.subtype] = "AttackAlternate",
}

-- velocity length threshold for standing still
local still_thres = 0.33

-- how many ticks to get to the destination position?
local move_dampener = 19
-- head attack lifespan
local attack_lifetime = 180
-- tiles per second
local keepah_head_speed = 5

-- when head type switches how much extra time to wait?
local diff_head_type_add = 15

-- how many ticks between attacks to wait?
local attack_breathe_window = 60

local min_bubble_time = 100

local bubble_time_var = 100

local num_text_options = 5 

-- how much to scale cooldowns down by and projectile counts up by? the lower the stronger
local mad_scalar = 0.75

local mad_lane_switch_time = 100

local heal_tick = 1.5

-- speech bubble sprite offset
local speech_bubble_offset = Vector(-28,-26)

local head_type = {
    [GODMODE.registry.entities.keepah_boss_head_still.subtype] = 1,
    [GODMODE.registry.entities.keepah_boss_head_move.subtype] = 2,
}

-- this is the collision criteria based on the subtype of the attack
local head_criteria = {
    [GODMODE.registry.entities.keepah_boss_head_still.subtype] = function(target,vel,data) -- still
        return vel:Length() <= still_thres
    end,
    [GODMODE.registry.entities.keepah_boss_head_move.subtype] = function(target,vel,data) -- moving
        return vel:Length() > still_thres
    end,
    [GODMODE.registry.entities.keepah_boss_head_both.subtype] = function(target,vel,data) -- both!
        if data.cur_type == nil then return true else 
            if data.cur_type == 1 then --still
                return vel:Length() <= still_thres
            else --moving
                return vel:Length() > still_thres
            end
        end
    end,
}

-- add the alternate version as a fourth option
head_criteria[GODMODE.registry.entities.keepah_boss_head_both_alt.subtype] = head_criteria[GODMODE.registry.entities.keepah_boss_head_both.subtype]

local get_head_type = function(self,ent,data,sprite)
    local perc = ent.HitPoints / ent.MaxHitPoints 

    if perc < 0.25 + (data.mad and 0.2 or 0.0) then 
        data.cur_alt = not (data.cur_alt or false) 
        return ent:GetDropRNG():RandomInt(4) + 1 
    elseif perc <= 0.66 + (data.mad and 0.2 or 0.0) then 
        return ent:GetDropRNG():RandomInt(3) + 1 
    else 
        return ent:GetDropRNG():RandomInt(2) + 1 
    end
end

local boss_anims = {
    ["Talk"] = true,
    ["TalkCry"] = true,
    ["Idle"] = true,
    ["IdleCry"] = true,
    ["IdleMad"] = true,
    ["TalkMad"] = true,
    ["IdleCryMad"] = true,
    ["TalkCryMad"] = true,
}

local keepah_atks = {
    { -- line of heads
        max_delay = 30,
        row_count = 3,

        init = function(self,ent,data,sprite) 
            data.head_type = get_head_type(self,ent,data,sprite)
            data.count = math.ceil(self.row_count * (data.mad and (1 / mad_scalar) or 1.0))
            data.delay = self.max_delay * (data.mad and mad_scalar or 1.0)
        end,
        update = function(self,ent,data,sprite) 
            if (data.delay or 0) > 0 then 
                data.delay = data.delay - 1

                if data.delay <= 0 then 
                    for i=1,num_lanes do 
                        monster.head_attack(ent,data.goal_pos or ent.Position,data,i,data.head_type,-1)
                    end

                    data.count = data.count - 1
                    local old_type = data.head_type 
                    data.head_type = get_head_type(self,ent,data,sprite)

                    data.delay = self.max_delay * (data.mad and mad_scalar or 1.0)
                    if old_type ~= data.head_type and not data.mad then 
                        data.delay = data.delay + diff_head_type_add
                    end
                end
            end

            if (data.count or 1) <= 0 then 
                data.end_atk = true 
            end
        end,
    },
    { -- zigzag of heads
        num_heads = 9,
        head_delay = 7,
        init = function(self,ent,data,sprite) 
            data.head_type = get_head_type(self,ent,data,sprite)
            data.heads_left = math.ceil(self.num_heads * (data.mad and (1 / mad_scalar) or 1.0))
            data.cur_lane = ent:GetDropRNG():RandomInt(num_lanes) + 1
            data.cur_dir = data.cur_lane == 5 and -1 or data.cur_lane == 1 and 1 or (ent:GetDropRNG():RandomInt(2)*2-1) 
            data.delay = self.head_delay
        end,
        update = function(self,ent,data,sprite) 
            data.delay = data.delay - 1
            if data.delay <= 0 then 
                monster.head_attack(ent,data.goal_pos or ent.Position,data,data.cur_lane,data.head_type,-1)
                data.heads_left = data.heads_left - 1
                data.cur_lane = data.cur_lane + data.cur_dir 

                if data.cur_lane == 1 or data.cur_lane == num_lanes then 
                    data.cur_dir = data.cur_dir * -1
                end

                data.delay = self.head_delay
            end

            if (data.heads_left or 1) <= 0 then 
                data.end_atk = true 
            end
        end,
    },
    { -- alternating head spots (3 -> 2 -> 3 -> 2)
        max_delay = 15,
        num_waves = 6,
        init = function(self,ent,data,sprite) 
            data.head_type = get_head_type(self,ent,data,sprite)
            data.count = math.ceil(self.num_waves * (data.mad and (1 / mad_scalar) or 1.0))
            data.delay = self.max_delay * (data.mad and mad_scalar or 1.0)
            data.cur_type = 1 
        end,
        update = function(self,ent,data,sprite) 
            if (data.delay or 0) > 0 then 
                data.delay = data.delay - 1

                if data.delay <= 0 then 
                    for i=1,num_lanes do 
                        if (i + data.cur_type) % 2 == 0 then 
                            monster.head_attack(ent,data.goal_pos or ent.Position,data,i,data.head_type,-1)
                        end
                    end

                    data.cur_type = data.cur_type == 1 and 0 or 1 
                    data.count = data.count - 1
                    data.delay = self.max_delay * (data.mad and mad_scalar or 1.0)

                    if data.count % 2 == 0 then 
                        local old_type = data.head_type 
                        data.head_type = get_head_type(self,ent,data,sprite)

                        if old_type ~= data.head_type and not data.mad then 
                            data.delay = data.delay + diff_head_type_add
                        end
                    end
                end
            end

            if (data.count or 1) <= 0 then 
                data.end_atk = true 
            end
        end,
    },
    { -- diagonal lines of heads
        num_heads = 15,
        head_delay = 5,
        init = function(self,ent,data,sprite) 
            data.head_type = get_head_type(self,ent,data,sprite)
            data.heads_left = math.ceil(self.num_heads * (data.mad and (1 / mad_scalar) or 1.0))
            data.initial_lane = 5 - ent:GetDropRNG():RandomInt(2) * 5
            data.cur_lane = data.initial_lane
            data.cur_dir = (ent:GetDropRNG():RandomInt(2)*2-1) 
            data.delay = self.head_delay * (data.mad and mad_scalar or 1.0)
        end,
        update = function(self,ent,data,sprite) 
            data.delay = data.delay - 1
            if data.delay <= 0 then 
                monster.head_attack(ent,data.goal_pos or ent.Position,data,data.cur_lane,data.head_type,-1)
                data.heads_left = data.heads_left - 1
                data.cur_lane = data.cur_lane + data.cur_dir 

                if data.cur_lane > num_lanes then data.cur_lane = 1 elseif data.cur_lane < 1 then data.cur_lane = num_lanes end

                data.delay = self.head_delay * (data.mad and mad_scalar or 1.0)

                if data.cur_lane == data.initial_lane then 
                    local old_type = data.head_type 
                    data.head_type = get_head_type(self,ent,data,sprite)

                    if old_type ~= data.head_type and not data.mad then 
                        data.delay = data.delay + diff_head_type_add
                    end
                end
            end

            if (data.heads_left or 1) <= 0 then 
                data.end_atk = true 
            end
        end,
    },
}

local choose_next_atk = function(ent,data,sprite)
    local perc = ent.HitPoints / ent.MaxHitPoints 

    if perc < 0.25 then 
        return ent:GetDropRNG():RandomInt(2) == 1 and 1 or 3 
    else 
        return ent:GetDropRNG():RandomInt(#keepah_atks) + 1
    end
end

local set_mad_lane_types = function(ent,data,sprite)
    data.mad_lane_types = {}
    for i=1,num_lanes do 
        table.insert(data.mad_lane_types,get_head_type(nil,ent,data,sprite))
    end

    data.mad_lane_switch_time = mad_lane_switch_time
    data.delay = data.delay + diff_head_type_add
end

monster.fire_tear = function(ent,dir,speed)
    local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_COIN,0,ent.Position + Vector(dir * -300),Vector(1,0):Rotated(dir):Resized(speed),ent)
    proj = proj:ToProjectile()
    proj.FallingAccel = -0.07
    proj.Scale = ent:GetDropRNG():RandomFloat()*0.8+0.6
    local color = ent:GetDropRNG():RandomFloat()
    proj:SetColor(Color(math.sin(color*6.28),math.sin(color*6.28+2.1),math.sin(color*6.28+4.2),1),999,1,false,false)
end

monster.head_attack = function(ent,pos,data,lane,var,dir)
    lane = lane == nil and 0 or lane 
    var = var == nil and GODMODE.registry.entities.keepah_boss_head_both.subtype or var
    dir = dir == nil and -1 or dir

    if data.mad == true then 
        var = data.mad_lane_types[lane] or var
    end

    local pos = pos + Vector(dir * -keepah_head_speed * 10,(min_lane + lane)*lane_size)
    local atk = Isaac.Spawn(monster.type,monster.variant,var,pos,Vector(dir * keepah_head_speed,0),ent)
    return atk 
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    -- local anim = sprite:GetAnimation()

    if ent.SubType == GODMODE.registry.entities.keepah_boss.subtype or ent.SubType == GODMODE.registry.entities.keepah_boss_dead.subtype then -- main boss
        if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then 
            ent.SpriteOffset = Vector(0,8)
        end

        if ent.SubType == GODMODE.registry.entities.keepah_boss.subtype then 
            if sprite:IsFinished("Appear") then 
                sprite:Play("Transform",true)
            end

            if sprite:IsFinished("Transform") then 
                sprite:Play("Idle",true)
            end

            -- apply regen if it exists
            if (data.heals_left or 0) > 0 then 
                ent.HitPoints = ent.HitPoints + math.min(math.max(0,data.heals_left),heal_tick)

                if ent.HitPoints >= ent.MaxHitPoints or data.heals_left - heal_tick <= 0 then data.heals_left = nil else 
                    data.heals_left = data.heals_left - heal_tick
                end
            end

            if sprite:IsEventTriggered("Explode") then 
                data.mama_mega_negate = 30
                GODMODE.room:MamaMegaExplosion(ent.Position)

                if data.destroyed_shop ~= true then 
                    GODMODE.util.schedule_function(function() 
                        GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,nil,nil,function(shop)
                            if shop and shop:ToPickup() and shop:ToPickup().ShopItemId > 0 then 
                                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,shop.Position,Vector.Zero,nil)
                                shop:Remove()
                            end
                        end)
                    end, 20)
                    
                    data.destroyed_shop = true 
                end
            end

            data.mad_lane_switch_time = math.max((data.mad_lane_switch_time or 0) - 1, 0)

            -- for enraged form, changes the current lane attack types
            if data.mad_lane_switch_time <= 0 and data.mad then 
                set_mad_lane_types(ent,data,sprite)
            end

            -- speech bubble
            if data.bubble then 
                if data.blue_flag == true then 
                    data.blue_flag = nil 
                    data.bubble:Play("TextBlue",true)
                end

                if data.red_flag == true then 
                    data.red_flag = nil 
                    data.bubble:Play("TextRed",true)
                end

                data.bubble:Update()

                if data.bubble:IsFinished(data.bubble:GetAnimation()) then 
                    data.bubble_ticks = (data.bubble_ticks or min_bubble_time) - 1

                    if data.bubble_ticks <= 0 then 
                        data.bubble:Play("Text"..tostring(ent:GetDropRNG():RandomInt(num_text_options)+1),true)
                        data.bubble_ticks = min_bubble_time + ent:GetDropRNG():RandomInt(bubble_time_var) + 1
                    end
                end
            else 
                data.bubble = Sprite()
                data.bubble:Load("godmode/gfx/117_keeper.anm2", true)
                GODMODE.log("created!",true)
            end

            data.goal_pos = data.goal_pos or Vector(GODMODE.room_bottom_right.X, GODMODE.room_center.Y)
            local offset = Vector(math.sin(math.rad(ent.FrameCount * 8)) * 4.0,math.sin(math.rad(ent.FrameCount * 8)) * 4.0)

            if boss_anims[sprite:GetAnimation()] then 
                local desired_anim = "Idle"
                
                if data.bubble:IsPlaying(data.bubble:GetAnimation()) then 
                    desired_anim = "Talk"
                end

                if ent.HitPoints < ent.MaxHitPoints/2.0 then 
                    desired_anim = desired_anim.."Cry"
                end

                if data.mad then 
                    desired_anim = desired_anim.."Mad"
                end

                sprite:Play(desired_anim,false)

                data.goal_pos = Vector(GODMODE.room_bottom_right.X, GODMODE.room_center.Y)
                ent.Velocity = ent.Velocity * 0.9 + ((data.goal_pos+offset) - ent.Position) / (move_dampener + 1)
            else 
                ent.Velocity = ent.Velocity * 0.8 
            end

            local cur_atk = keepah_atks[data.cur_attack or 0]

            if cur_atk == nil and (data.goal_pos - ent.Position):Length() < ent.Size * 2.5 then 
                data.cur_attack = choose_next_atk(ent,data,sprite)
                data.atk_start_cd = attack_breathe_window 
            elseif cur_atk then 
                if not data.atk_init == true then 
                    cur_atk:init(ent,data,sprite)
                    data.atk_init = true 
                end

                if (data.atk_start_cd or 0) > 0 then data.atk_start_cd = data.atk_start_cd - 1 else 
                    cur_atk:update(ent,data,sprite)
                end

                if data.end_atk == true then 
                    data.end_atk = nil 
                    data.atk_init = nil 
                    data.cur_attack = nil 
                end
            end
        else --death animation/rewards
            if sprite:GetAnimation() ~= "DeathRattle" then 
                sprite:Play("DeathRattle",true)
            elseif ent:IsFrame(2,1) and sprite:GetFrame() < 40 then 
                local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,math.min(CoinSubType.COIN_PENNY,ent:GetDropRNG():RandomInt(5)),ent.Position-Vector(12,0),Vector(-1,0):Resized(ent:GetDropRNG():RandomFloat()*8.0+4.0):Rotated(ent:GetDropRNG():RandomFloat()*100-50),ent)
                coin:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                coin:GetSprite():Play("Appear",true)
            end
        end

        if sprite:IsEventTriggered("Flap") then 
            ent.Velocity = ent.Velocity + Vector(0,-3)
        end
        
        if sprite:IsFinished("DeathRattle") then 
            ent:Kill()
        end

        if data.mama_mega_negate then 
            data.mama_mega_negate = math.max(0,data.mama_mega_negate - 1) 
            if data.mama_mega_negate == 0 then data.mama_mega_negate = nil end
        end

        
    else -- head attacks! 
        if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then 
            ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) 
            ent.SizeMulti = Vector(1.2,1)
            ent.SpriteOffset = Vector(0,8)        
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        end 

        local sprite_anim = head_attack_anims[ent.SubType]
        
        if sprite_anim then 
            if sprite:IsEventTriggered("Flap") then 
                data.cur_type = nil
            elseif sprite:IsEventTriggered("Still") then 
                data.cur_type = 1
            elseif sprite:IsEventTriggered("Move") then 
                data.cur_type = 2
            end

            if ent.FrameCount > attack_lifetime then 
                ent:Remove()
            end

            if ent.Velocity.X > 0 then 
                ent.FlipX = true
            end

            ent.Velocity = ent.Velocity:Resized(keepah_head_speed) * Vector(1,0)

            if not sprite:IsPlaying(sprite_anim) then 
                sprite:Play(sprite_anim,true)

                if ent.SubType == GODMODE.registry.entities.keepah_boss_head_both_alt.subtype then 
                    sprite:SetFrame(32)
                end
            end
        end
    end
end

monster.player_collide = function(self,player,ent,entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant and head_criteria[ent.SubType] then 
        -- if the movement criteria is satisfied, OR the player is on the latter part of the entity (behind them to make it more forgiving)
        if head_criteria[ent.SubType](player,player:GetMovementJoystick(),GODMODE.get_ent_data(ent)) or player.Position.X > ent.Position.X + ent.Size / 4.0 then 
            return true 
        else 
            player:TakeDamage(1,0,EntityRef(ent),0)
            ent:Kill()
            return nil
        end
    end

    -- ghost through
    return true
end

monster.npc_post_render = function(self, ent, offset, data, sprite)
    local bub = data.bubble
    if bub ~= nil and not bub:IsFinished(bub:GetAnimation()) then
		bub:Render(Isaac.WorldToScreen(ent.Position) + speech_bubble_offset)
    end
end

monster.npc_kill = function(self, ent)
	local dist = 4
	local base_offset = Vector.Zero
	local count = 4
	local data = GODMODE.get_ent_data(ent)
	local flag = true

	if ent.SubType == GODMODE.registry.entities.keepah_boss.subtype or ent.SubType == GODMODE.registry.entities.keepah_boss_dead.subtype then
		if ent:GetSprite():GetAnimation() ~= "DeathRattle" then
			local new = Isaac.Spawn(ent.Type,ent.Variant,GODMODE.registry.entities.keepah_boss_dead.subtype,ent.Position,Vector.Zero,ent)
			new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			new:GetSprite():Play("DeathRattle",true)
			new.MaxHitPoints = -1
            new.HitPoints = -1
			flag = false
            GODMODE.save_manager.set_data("KeepahBossKilled","true",true)
			ent:Remove()
        else 
            local new = Isaac.Spawn(GODMODE.registry.entities.keepah.type,GODMODE.registry.entities.keepah.variant,GODMODE.registry.entities.keepah.subtype,ent.Position,Vector.Zero,ent)
            ent:Remove()
            new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            new:GetSprite():Play("Appear2",true)
        	new.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
	end
end

-- create the hardmode fight!
monster.explode_frame = function(self, ent, data, sprite, fx, explode_pos, explode_size, collided)
    if collided and data.bubble and not data.mad then 
        data.bubble:Play("TextEnrage",true)
        data.mad = true
        set_mad_lane_types(ent,data,sprite)
        ent.MaxHitPoints = ent.MaxHitPoints / mad_scalar
        data.heals_left = ent.MaxHitPoints
        data.atk_start_cd = attack_breathe_window 
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)

	if enthit.Type == monster.type and enthit.Variant == monster.variant and data.mama_mega_negate then
        data.mama_mega_negate = data.mama_mega_negate - 1
        if data.mama_mega_negate <= 0 then data.mama_mega_negate = nil end  
        return false 
	end
end

return monster