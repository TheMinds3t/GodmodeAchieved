local monster = {}
monster.name = "Bulge Bat"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

local charge_speed = 15.0/60.0
local max_charge_time = 25
local always_charge_thres = 0.175

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if ent:GetSprite():IsFinished("Appear") then 
        ent:GetSprite():Play("Idle",true)
        ent.I1 = -10
    end
    
    if ent:GetSprite():IsFinished("Idle") or ent:GetSprite():IsFinished("Puke") or ent:GetSprite():IsFinished("Fart") then 
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

        while data.last_attack ~= nil and data.last_attack == atk and atk > 0 do 
            atk = sel_atk()
        end

        data.last_attack = atk 

        if atk == 1 then 
            ent:GetSprite():Play("Charge",true)
            ent.I2 = max_charge_time

            data.charge_dir = (player.Position - ent.Position):Resized(charge_speed + Game().Difficulty % 2)
        elseif atk == 2 then 
            ent:GetSprite():Play("Puke",true)
            ent.I1 = 5
        elseif atk == 3 then 
            ent:GetSprite():Play("Fart",true)
        else
            ent:GetSprite():Play("Idle",true)
        end
    end
    ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

    if ent:GetSprite():IsPlaying("Idle") or ent:GetSprite():IsPlaying("Fart") then 
        ent.Pathfinder:MoveRandomlyBoss(true)
    end

    if ent:GetSprite():IsPlaying("Charge") then 
        ent.Velocity = ent.Velocity * 0.9 + data.charge_dir 

        if ent.HitPoints / ent.MaxHitPoints > always_charge_thres then 
            ent.I2 = ent.I2 - 1
        else 
            data.charge_dir = (player.Position - ent.Position):Resized((charge_speed + Game().Difficulty % 2) * 0.5)
        end
        ent.FlipX = ent.Velocity.X > 0

        if ent.I2 <= 0 then 
            ent:GetSprite():Play("Idle",true)
            ent.FlipX = false
            ent.I1 = -2
        end

        for i=1,4 do 
            local grid = Game():GetRoom():GetGridEntityFromPos(ent.Position+Vector(1,0):Resized(ent.Size):Rotated(90*i+45))
			
			if grid ~= nil and (grid:ToRock() or grid:ToPoop()) then 
				grid:Destroy()
			end
        end
    else 
        ent.Velocity = ent.Velocity * 0.875
    end

    if ent:GetSprite():IsEventTriggered("Puke") then 
        local range = 60
        local targ = (player.Position - ent.Position)
        for i=0,1 do 
            local vel = targ:Rotated(ent:GetDropRNG():RandomFloat()*range-range/2):Resized(targ:Length()/52.0 * (0.8 + ent:GetDropRNG():RandomFloat()*0.4))
            local p = Isaac.Spawn(Isaac.GetEntityTypeByName("Barfer"),Isaac.GetEntityVariantByName("Barfer"),1,ent.Position,vel,nil)
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

    if ent:GetSprite():IsEventTriggered("Fart") then 
        for u=0,16+ent:GetDropRNG():RandomFloat()*5 do
            local params = ProjectileParams() 
            params.Variant = ProjectileVariant.PROJECTILE_PUKE
            params.FallingAccelModifier = 1.0
            params.GridCollision = false
            ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(24-ent:GetDropRNG():RandomFloat()*8),0.5,params)
            -- t.Color = Color(0.3,0.4,0.1,1.0,50/255,50/255,50/255)
        end
        -- GODMODE.log("child="..GODMODE.util.count_child_enemies(ent,false),true)
        if GODMODE.util.count_child_enemies(ent,false) < 3 then 
            local dip = Isaac.Spawn(EntityType.ENTITY_DIP,0,0,ent.Position,RandomVector()*4,ent)
            dip:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
        Game():ButterBeanFart(ent.Position-Vector(0,10),128,ent,true,false)
    end
end

return monster