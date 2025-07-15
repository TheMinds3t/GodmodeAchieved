local monster = {}
monster.name = "Marshall Pawn"
monster.type = GODMODE.registry.entities.marshall_pawn.type
monster.variant = GODMODE.registry.entities.marshall_pawn.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()
    if data then
        if not data.init then
            data.init = true
            data.tears = {}
            data.tear_time = {}
            data.slowed = GODMODE.util.count_enemies(nil, GODMODE.registry.entities.grand_marshall.type, GODMODE.registry.entities.grand_marshall.variant) ~= 0
            data.spawn_tear = function(self, ang, spd)
                local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
                tear = tear:ToProjectile()
                tear.Height = -20
                tear.FallingSpeed = 0.0
                tear.FallingAccel = -(4/60.0)
                tear.Color = Color(0.5,0.5,1,1,0,0,0.9)
                self.tears[tear.Index] = tear
                self.tear_time[tear.Index] = 0
            end
        else
            if sprite:IsEventTriggered("Ring") then
                GODMODE.sfx:Play(SoundEffect.SOUND_CHILD_ANGRY_ROAR)
                GODMODE.sfx:AdjustPitch(SoundEffect.SOUND_CHILD_ANGRY_ROAR,0.7)
                GODMODE.sfx:Play(SoundEffect.SOUND_HEARTOUT,0.5)
                GODMODE.sfx:AdjustPitch(SoundEffect.SOUND_HEARTOUT,0.7)
                local spd = 3.75 + ent:GetDropRNG():RandomFloat() * 0.25
                if data.slowed == false then
                    spd = 6.0
                end

                for i=0,3 do
                    local f = math.rad(360 / 4 * i)
                    data:spawn_tear(f,spd)
                end
            end

            if data.time % 30 == 0 then 
                local new_times = {}
                for ind,time in pairs(data.tear_time) do
                    if time ~= nil then
                        new_times[ind] = time
                    end
                end
                data.tear_time = new_times 
                local new_tears = {}
                for ind,tear in pairs(data.tears) do
                    if tear ~= nil and not tear:IsDead() then
                        new_tears[ind] = tear
                    end
                end
                data.tears = new_tears
            end
            
            data.tears = data.tears or {}
            for i,tear in pairs(data.tears) do
                if tear == nil or tear:IsDead() then 
                    data.tears[i] = nil
                    
                    if tear ~= nil then data.tear_time[i] = nil end
                end

                local tear_data = GODMODE.get_ent_data(tear)
                data.tear_time[i] = (data.tear_time[i] or 0) + 1
                local tear_time = data.tear_time[i]
                if tear_time == 15 then
                    local dist = player.Position - tear.Position
                    --local ang = dist:GetAngleDegrees()
                    tear.Velocity = dist:Resized(tear.Velocity:Length()*0.8)
                    tear.Color = Color(0.5,0,1,1,0.25,0,0.9)
                    GODMODE.sfx:Play(SoundEffect.SOUND_HEARTIN,0.15)
                    GODMODE.sfx:AdjustPitch(SoundEffect.SOUND_HEARTIN,0.7)
    
                end
                
                tear.Color = Color((tear.Color.R * 29 + 0.5 * 1)/30,
                                    (tear.Color.G * 29 + 0.5 * 1)/30,
                                    (tear.Color.B * 29 + 1.0 * 1)/30,
                                    1,0,0,
                                    (tear.Color.BO * 29 + 0.9 * 1)/30)
            end    
        end
    end
end

return monster