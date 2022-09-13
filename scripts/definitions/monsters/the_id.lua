local monster = {}
monster.name = "The Id"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType == 700) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.time % 4 == 0 then
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CREEP_WHITE,0,ent.Position,Vector.Zero,ent)
		creep:ToEffect():SetTimeout(50)
	end

	if data.sprite_flip ~= true then
		GODMODE.util.macro_on_enemies(ent,monster.type,10,0, function(chain) 
			chain:GetSprite():ReplaceSpritesheet(1,"gfx/monsters/the_id.png")
			chain:GetSprite():LoadGraphics()
			data.sprite_flip = true
		end)
	end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType == 700 and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		Game():BombExplosionEffects(ent.Position,10.0,TearFlags.TEAR_NORMAL,Color.Default,ent,0.5)
		local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CREEP_WHITE,0,ent.Position,Vector.Zero,ent)
		creep:ToEffect().Scale = 4
		Game():ShakeScreen(5)
	end
end

return monster