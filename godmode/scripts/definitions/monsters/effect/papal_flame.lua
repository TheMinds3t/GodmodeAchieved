local monster = {}

monster.name = "Papal Flame"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

local function set_kill_msgs() 
    monster.kill_msgs = {
        {"You have too much time", "on your hands don't you?"},
        {"Jesus dude, wow.", "Go touch some grass man"},
        {"Clock go brrr"},
        {"Is it past midnight", "for you yet? Dang."},
        {"Get a life"},
        {"u r virgin"},
        {"Is this your preferred", "way to spend time?"},
        {"Well, there goes "},
        {"Have you even eaten today?"},
        {"Have you even showered today?", "I smell you from *my*", "screen..."},
    }
end

set_kill_msgs()

monster.data_init = function(self, params)
    params[2].persistent_state = GODMODE.persistent_state.single_room
end

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local anim = "DevilFlame"
    if ent.SubType == 1 then anim = "AngelFlame" end
    if ent.SubType == 2 then anim = "AdraFlame" end
    if ent.SubType == 3 then anim = "LightFlame" end
    if ent.SubType == 4 then anim = "FlameOut"
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
    

    if not ent:GetSprite():IsPlaying(anim) then
        ent:GetSprite():Play(anim,false)
        ent.SplatColor = Color(0,0,0,0,1,1,1)
        data.ori_position = ent.Position
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end
    
    if data.persistent_data and data.persistent_data.in_room == true then
        ent.Position = data.ori_position
    end

    if not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then 
		ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
	end

    ent.Velocity = Vector(0,0)
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType ~= 4 and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
        local flag = false 

        GODMODE.util.macro_on_enemies(nil,Isaac.GetEntityTypeByName("Masked Angel Statue"),Isaac.GetEntityVariantByName("Masked Angel Statue"),nil,function(statue) flag = (ent.Position - statue.Position):Length() < 256 end)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,1,ent.Position,Vector.Zero,ent)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,2,ent.Position,Vector.Zero,ent)

        if flag == false then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, ent.Position, Vector(0,0), ent)
            set_kill_msgs()

            if Game():GetLevel():GetStage() > LevelStage.STAGE4_3 then
                monster.kill_msgs[8][1] = monster.kill_msgs[8][1].."even more time"
            elseif Game():GetLevel():GetStage() > LevelStage.STAGE3_2 then
                monster.kill_msgs[8][1] = monster.kill_msgs[8][1].."Hush"
            else
                monster.kill_msgs[8][1] = monster.kill_msgs[8][1].."Boss Rush"
            end
            
            local msg = ent:GetDropRNG():RandomInt(#monster.kill_msgs)+1
            Game():GetHUD():ShowFortuneText(monster.kill_msgs[msg][1],monster.kill_msgs[msg][2],monster.kill_msgs[msg][3])
        else
            local place = Isaac.Spawn(ent.Type,ent.Variant,4,ent.Position,Vector.Zero,ent)
            place:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            place:Update()
        end

        SFXManager():Play(SoundEffect.SOUND_FIREDEATH_HISS)
    end
end
return monster