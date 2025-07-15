local ret = {}
-- this is necessary for Cloth of Gold otherwise the split damage isn't enough to counteract the damage scaling.
ret.entities = 
{
	{type=EntityType.ENTITY_HUSH},
	{type=EntityType.ENTITY_ISAAC, variant=2},
	{type=EntityType.ENTITY_ULTRA_GREED},
	{type=EntityType.ENTITY_DELIRIUM},
	{type=EntityType.ENTITY_MEGA_SATAN},
	{type=EntityType.ENTITY_MOTHER},
	{type=EntityType.ENTITY_DOGMA},
	{type=EntityType.ENTITY_BEAST},
	{type=EntityType.ENTITY_GUTTED_FATTY},
	{type=EntityType.ENTITY_GAPER_L2},
	{type=EntityType.ENTITY_CHARGER_L2},
	{type=EntityType.ENTITY_SHADY},
	{type=EntityType.ENTITY_POOTER, variant=2},
	{type=EntityType.ENTITY_HIVE, variant=3},
	{type=EntityType.ENTITY_BOOMFLY, variant=6},
	{type=EntityType.ENTITY_HOPPER, variant=3},
	{type=EntityType.ENTITY_SPITY, variant=1},
	{type=EntityType.ENTITY_ROUND_WORM, variant=2},
	{type=EntityType.ENTITY_ROUND_WORM, variant=3},
	{type=EntityType.ENTITY_SUCKER, variant=7},
	{type=EntityType.ENTITY_WALL_CREEP, variant=3},
	{type=EntityType.ENTITY_SUB_HORF, variant=1},
	{type=EntityType.ENTITY_FACELESS, variant=1},
	{type=EntityType.ENTITY_MOLE, variant=1},
	{type=EntityType.ENTITY_MOM, variant=0},
	{type=EntityType.ENTITY_GIDEON}, --softlock if not here, gets to 8/7 waves and doesn't die
}

ret.no_champ = {
	{type=EntityType.ENTITY_STONEHEAD},
	{type=EntityType.ENTITY_BRIMSTONE_HEAD},
	{type=EntityType.ENTITY_CONSTANT_STONE_SHOOTER},
	{type=EntityType.ENTITY_STONE_EYE},
	{type=EntityType.ENTITY_GAPING_MAW},
	{type=EntityType.ENTITY_BROKEN_GAPING_MAW},
	{type=EntityType.ENTITY_QUAKE_GRIMACE},
	{type=EntityType.ENTITY_BOMB_GRIMACE},
	{type=EntityType.ENTITY_SPIKEBALL},
	{type=EntityType.ENTITY_GRUDGE},
	{type=EntityType.ENTITY_POKY},
	{type=EntityType.ENTITY_WALL_HUGGER},
	{type=EntityType.ENTITY_DEATHS_HEAD},
	{type=EntityType.ENTITY_DUSTY_DEATHS_HEAD},
	{type=EntityType.ENTITY_MOCKULUS},
	{type=EntityType.ENTITY_MASK},
	{type=EntityType.ENTITY_BALL_AND_CHAIN},
	{type=EntityType.ENTITY_PEEP,variant=10},
	{type=EntityType.ENTITY_PEEP,variant=11},
	{type=EntityType.ENTITY_SPIDER},
	{type=EntityType.ENTITY_BIGSPIDER},
	{type=EntityType.ENTITY_SWARM_SPIDER},
	{type=EntityType.ENTITY_ETERNALFLY},
	{type=GODMODE.registry.entities.devil_lock.type,variant=GODMODE.registry.entities.devil_lock.variant},
	{type=GODMODE.registry.entities.bomb_barrel.type,variant=GODMODE.registry.entities.bomb_barrel.variant},
	{type=GODMODE.registry.entities.masked_angel_statue.variant,variant=GODMODE.registry.entities.masked_angel_statue.variant},
	{type=GODMODE.registry.entities.papal_flame.type,variant=GODMODE.registry.entities.papal_flame.variant},
	{type=GODMODE.registry.entities.elohims_throne.type,variant=GODMODE.registry.entities.elohims_throne.variant},
	{type=GODMODE.registry.entities.stone_beggar.type,variant=GODMODE.registry.entities.stone_beggar.variant},
	{type=GODMODE.registry.entities.golden_scale.type,variant=GODMODE.registry.entities.golden_scale.variant},
	{type=GODMODE.registry.entities.ooze_turret.type,variant=GODMODE.registry.entities.ooze_turret.variant},
	{type=GODMODE.registry.entities.door_hazard.type,variant=GODMODE.registry.entities.door_hazard.variant},
	{type=GODMODE.registry.entities.dynamite_rock.type,variant=GODMODE.registry.entities.dynamite_rock.variant},
	{type=GODMODE.registry.entities.delirious_pile.type,variant=GODMODE.registry.entities.delirious_pile.variant},
}

ret.story_bosses = {
	[EntityType.ENTITY_MOM] = 500,
	[EntityType.ENTITY_MOMS_HEART] = 750,
	[EntityType.ENTITY_SATAN] = 750,
	[EntityType.ENTITY_ISAAC] = 750,
	[EntityType.ENTITY_THE_LAMB] = 750,
	[EntityType.ENTITY_MEGA_SATAN] = 1000,
	[EntityType.ENTITY_MEGA_SATAN_2] = 1000,
}

ret.has_armor = function(self, ent)
	for i,arment in ipairs(self.entities) do
		if arment.type == ent.Type and (arment.variant == nil or arment.variant == ent.Variant) then
			return true
		end
	end
	return false
end

ret.can_be_champ = function(self, ent)
	if not ent:ToNPC() then return false end
	for i,entry in ipairs(self.no_champ) do
		if entry.type == ent.Type and (entry.variant == nil or entry.variant == ent.Variant) then
			return false
		end
	end
	return true
end

return ret