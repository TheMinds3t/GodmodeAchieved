local item = {}
item.instance = Isaac.GetItemIdByName( "Vajra" )
item.eid_description = "↑ Strike all enemies with electricity when you take damage, dealing 2x your damage + 10"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When damaged, spawns between 4 to 6 electric lasers that deal 2x your damage + 10 damage."},
      {str = "In addition to the above lasers, a laser is spawned for all hostile enemies in the room dealing your damage x the number of Vajra you currently hold."},
    },
}

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) then
        for _,ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:IsVulnerableEnemy() then
                local laser = EntityLaser.ShootAngle(10, enthit.Position, (ent.Position-enthit.Position):GetAngleDegrees()+enthit:GetDropRNG():RandomFloat() * 5 - 2.5, 10, Vector(0,10), enthit)
                laser.CollisionDamage = enthit:ToPlayer().Damage*enthit:ToPlayer():GetCollectibleNum(item.instance)
                laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                laser.OneHit = true
            end
        end

        for i=0,4+enthit:GetDropRNG():RandomInt(2) do 
            local laser = EntityLaser.ShootAngle(10, enthit.Position, enthit:GetDropRNG():RandomInt(360), 10, Vector(0,10), enthit)
            laser.CollisionDamage = enthit:ToPlayer().Damage*2 + 10
            laser.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            laser.MaxDistance = 64 + enthit:GetDropRNG():RandomFloat() * 256
            laser.OneHit = true
        end

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, 0, enthit.Position, Vector.Zero, enthit)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, enthit.Position, Vector.Zero, enthit)
        Game():ShakeScreen(10)
        SFXManager():Play(SoundEffect.SOUND_EXPLOSION_WEAK)
    end
end

return item