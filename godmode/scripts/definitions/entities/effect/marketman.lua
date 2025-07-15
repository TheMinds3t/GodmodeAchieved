local monster = {}
monster.name = "Market Man"
monster.type = GODMODE.registry.entities.market_man.type
monster.variant = GODMODE.registry.entities.market_man.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.persistent_state = GODMODE.persistent_state.single_room
	end
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	
	if not sprite:IsPlaying("Idle") then
		sprite:Play("Idle", false)
	end

	ent.Velocity = ent.Velocity * 0.25
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		for i=1,ent:GetDropRNG():RandomInt(3)+5 do
			Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,0,ent.Position,Vector(ent:GetDropRNG():RandomFloat()-0.5,ent:GetDropRNG():RandomFloat()-0.5)*2,ent)   
		end

		Isaac.Spawn(EntityType.ENTITY_BOMBDROP,BombVariant.BOMB_GIGA,0,ent.Position,Vector.Zero,ent)   
		GODMODE.game:BombExplosionEffects(ent.Position,20.0)
		GODMODE.game:ShakeScreen(20)
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if enthit.Type == monster.type and enthit.Variant == monster.variant then 
        return flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION
    end
end

return monster