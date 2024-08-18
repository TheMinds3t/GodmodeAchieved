local monster = {}
monster.name = "Bulge Bat"
monster.type = GODMODE.registry.entities.bulge_bat.type
monster.variant = GODMODE.registry.entities.bulge_bat.variant

local charge_speed = 15.0/60.0
local max_charge_time = 25
local always_charge_thres = 0.175

local function fart(ent)
    ent = ent:ToNPC()
    for u=0,16+ent:GetDropRNG():RandomFloat()*5 do
        local params = ProjectileParams() 
        params.Variant = ProjectileVariant.PROJECTILE_PUKE
        params.FallingAccelModifier = 1.0
        params.GridCollision = false
        ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(24-ent:GetDropRNG():RandomFloat()*8),0.5,params)
        -- t.Color = Color(0.3,0.4,0.1,1.0,50/255,50/255,50/255)
    end
    -- GODMODE.log("child="..GODMODE.util.count_child_enemies(ent,false),true)
    if ent:IsDead() or GODMODE.util.count_child_enemies(ent,false) < 3 then 
        local dip = Isaac.Spawn(EntityType.ENTITY_DIP,0,0,ent.Position,RandomVector()*4,ent)
        dip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
    GODMODE.game:ButterBeanFart(ent.Position-Vector(0,10),128,ent,true,false)
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if sprite:IsFinished("Appear") then 
        sprite:Play("Idle",true)
        ent.I1 = -10
    end
    
    if sprite:IsFinished("Idle") or sprite:IsFinished("Puke") or sprite:IsFinished("Fart") then 
        ent.I1 = ent.I1 + 1
        -- GODMODE.log("i1="..ent.I1,true)
        local sel_atk = function() 
            if ent.HitPoints / ent.MaxHitPoints < always_charge_thres or ent:GetDropRNG():RandomFloat() < ent.I1 * 0.125 or ent.I1 == -9 then 
                return 1
            elseif ent:GetDropRNG():RandomFloat() < ent.I1 * 0.25 then 
                return 2
            elseif ent:GetDropRNG():RandomFloat() < 0.4 then 
                return 3
            else
                return 0
            end
        end

        local atk = sel_atk() 
        local depth = 20

        while data.last_attack ~= nil and data.last_attack == atk and atk > 0 and depth > 0 do 
            atk = sel_atk()
            depth = depth - 1
        end

        data.last_attack = atk 

        if atk == 1 then 
            sprite:Play("Charge",true)
            ent.I2 = max_charge_time

            data.charge_dir = (player.Position - ent.Position):Resized(charge_speed + GODMODE.game.Difficulty % 2)
        elseif atk == 2 then 
            sprite:Play("Puke",true)
            ent.I1 = 5
        elseif atk == 3 then 
            sprite:Play("Fart",true)
        else
            sprite:Play("Idle",true)
        end
    end
    ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

    if sprite:IsPlaying("Idle") or sprite:IsPlaying("Fart") then 
        ent.Pathfinder:MoveRandomlyBoss(true)
    end

    if sprite:IsPlaying("Charge") then 
        ent.Velocity = ent.Velocity * 0.9 + data.charge_dir 

        if ent.HitPoints / ent.MaxHitPoints > always_charge_thres then 
            ent.I2 = ent.I2 - 1
        else 
            data.charge_dir = (player.Position - ent.Position):Resized((charge_speed + GODMODE.game.Difficulty % 2) * 0.5)
        end
        ent.FlipX = ent.Velocity.X > 0

        if ent.I2 <= 0 then 
            sprite:Play("Idle",true)
            ent.FlipX = false
            ent.I1 = -2
        end

        for i=1,4 do 
            local grid = GODMODE.room:GetGridEntityFromPos(ent.Position+Vector(1,0):Resized(ent.Size):Rotated(90*i+45))
			
			if grid ~= nil and (grid:ToRock() or grid:ToPoop()) then 
				grid:Destroy()
			end
        end
    else 
        ent.Velocity = ent.Velocity * 0.875
    end

    if sprite:IsEventTriggered("Puke") then 
        local range = 60
        local targ = (player.Position - ent.Position)
        for i=0,1 do 
            local vel = targ:Rotated(ent:GetDropRNG():RandomFloat()*range-range/2):Resized(targ:Length()/52.0 * (0.8 + ent:GetDropRNG():RandomFloat()*0.4))
            local p = Isaac.Spawn(GODMODE.registry.entities.barfer.type,GODMODE.registry.entities.barfer.variant,1,ent.Position,vel,nil)
            p:GetSprite():Play("PukeUp", true)
            p:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            p.SpriteOffset = Vector(0,-60)
            local r = vel * (2.0 + ent:GetDropRNG():RandomFloat()*2)
            p.Velocity = r
            local d = GODMODE.get_ent_data(p)
            d.speed = r
            d.owner = ent
            p.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        end
    end

    if sprite:IsEventTriggered("Fart") then 
        fart(ent)
    end
end

monster.npc_kill = function(self, ent)
    if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 
        fart(ent)
    end
end

return monster