local monster = {}
monster.name = "Fallen Guard (Familiar)"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.max_state = 15 

monster.familiar_update = function(self, fam)
	local data = GODMODE.get_ent_data(fam)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
		fam:GetSprite():Play("Idle", false)

		if fam.FrameCount % 100 == 0 and fam.Target == nil or fam.Target ~= nil and fam.Target:IsDead() then 
			fam.Target = nil
			fam.State = 0
			fam:GetSprite().PlaybackSpeed = 1
			fam:SetColor(Color(1,1,1,1,0,0,0),100,100,false,false)
            fam:PickEnemyTarget(512.0, 1, 5, Vector.Zero, 180)
		end

		if fam:GetSprite():IsEventTriggered("Rush") then 
			fam.CollisionDamage = player.Damage * 0.15 + 1.3
			local target_pos = player.Position

			if fam.Target ~= nil then 
				target_pos = fam.Target.Position + fam.Target.Velocity * (math.max(2,monster.max_state - fam.State)) * 2
				fam.State = math.min(monster.max_state,fam.State + 1)
				local col_off = fam.State / monster.max_state * 0.25
				fam:SetColor(Color(1,1-col_off,1-col_off,1,col_off),100,100,false,false)
				fam:GetSprite().PlaybackSpeed = 1 + fam.State * 0.1
			end

			local offset_length = (math.min(16,math.max(4,(target_pos-fam.Position):Length()/12)))
			if fam.Target == nil then offset_length = 16 end
			target_pos = target_pos + RandomVector() * offset_length
			local length = (target_pos - fam.Position):Length()/8
			fam.Velocity = fam.Velocity * 0.9 + (target_pos - fam.Position):Resized(math.min(8, math.max(0.1,length)))
		end

		fam.Velocity = fam.Velocity * 0.925
    end
end

monster.new_room = function(self)
	GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(guard)
		guard:ToFamiliar():PickEnemyTarget(512.0, 1, 5, Vector.Zero, 180)
		guard:ToFamiliar().State = 0
		guard:GetSprite().PlaybackSpeed = 1
		guard:SetColor(Color(1,1,1,1,0,0,0),100,100,false,false)
	end)
end

return monster