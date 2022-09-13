local item = {}
item.instance = Isaac.GetItemIdByName( "Gangrene" )
item.eid_description = "Leave a trail of poison tears that are 0.1x your damage behind you"
item.eid_transforms = GODMODE.util.eid_transforms.BOB
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Holding this item creates a trail of small tears that have a 10% chance, up to 75% chance at 12 luck, to be poisoned."},
      {str = "These tears do not collide with anything but enemies."},
	  {str = "Items that change the visual appearance of tears, like holy light, can be applied to the trail."},
    },
}

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
		if not player:IsDead() then
			local data = GODMODE.get_ent_data(player)
			data.gangrene_counter = (data.gangrene_counter or 0) + player:GetCollectibleRNG(item.instance):RandomFloat()

			if math.floor(data.gangrene_counter) % 3 == 0 then
				data.gangrene_counter = data.gangrene_counter + 1
				data.sign_not = true
				local tear = player:FireTear(player.Position+Vector(player:GetCollectibleRNG(item.instance):RandomInt(math.floor(player.Size*2))-player.Size,player:GetCollectibleRNG(item.instance):RandomInt(math.floor(player.Size*2))-player.Size),-player.Velocity:Resized(math.min(player.Velocity:Length(),1)) * math.max(0.1,player.ShotSpeed*0.5-0.4),false,true,false,player,1.0)
				data.sign_not = false
				
				if player:GetCollectibleRNG(item.instance):RandomFloat() < 0.1 + (math.min(12,player.Luck)/12*0.65) then 
					tear.TearFlags = TearFlags.TEAR_POISON 
					tear:SetColor(Color(0.25,1,0.25,1,0,0.0,0),200,99,false,false)
				else
					tear.TearFlags = TearFlags.TEAR_NORMAL 
					tear:SetColor(Color(0.2,0.3,0.2,1,0,0.0,0),200,99,false,false)
				end

				tear.FallingSpeed = 0.0
				tear.FallingAcceleration = -(3/60.0)
				tear.Height = -20
				tear.Scale = 1 * (player:GetCollectibleRNG(item.instance):RandomFloat()*0.25+0.25)
				tear.CollisionDamage = player.Damage * 0.1
				tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
				tear:ChangeVariant(0)
				tear:GetSprite():Play("RegularTear2",true)
			end
		end
	end
end

return item