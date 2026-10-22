local monster = {}

monster.name = "[GODMODE] Papal Flame"
monster.type = GODMODE.registry.entities.papal_flame.type
monster.variant = GODMODE.registry.entities.papal_flame.variant

local function set_kill_msgs() 
    monster.kill_msgs = {
        {"you have too much time", "on your hands don't you?"},
        {"jesus dude, wow.", "Go touch some grass man"},
        {"clock go brrr"},
        {"is it past midnight", "for you yet? damn"},
        {"get a life"},
        {"u r virgin"},
        {"is this your preferred", "way to spend time?"},
        {"well, there goes "}, -- autopopulated on fire death
        {"have you even eaten today?"},
        {"have you even showered today?", "i smell you from *my*", "screen..."},
        {"meehoy meenoy"},
        {"zoo wee mama!"},
        {"shabang!", "item, just like that!"},
        {"nice.", "anyways, how's", "that hangnail doin?"},
        {"L + time + waste + ratio"},
        {"W!!"},
        {"poggers!!"},
        {"that's some juice right there"},
        {"now that's that dirt"},
        {"yeet"},
        {"so it seems","you've discovered","my little secret."},
        {"ggwp"},
        {"doomfist lowkey", "holds lobbies", "hostage"},
        {"do you like my sword", "sword sword my", "diamond sword sword"},
        {"one day you", "will remember", "me by my name"},
        {"unavoidable damage"},
        {"irrecoverable damage"},
        {"FATALITY!"},
        {"try again next time?"},
        {"gg go next?"},
        {"gtfobibybau",">:()"},
        {"only you can", "prevent forest fires"},
        {"papal flame goes", "brrrrrrrrr"},
        {"you must construct", "additional pylons"},
        {"the cake is a lie"},
        {"do a barrel roll!"},
        {"it's dangerous", "to go alone!","take this."},
        {"stay awhile", "and listen."},
        {"live","laugh","love."},
        {"what do you have", "going on tonight?"},
        {"you win this time", "but i'll be back."},
        {"i am inevitable."},
        {"i am groot."},
        {"wakka wakka"},
        {"just keep", "swimming."},
        {"to infinity", "and beyond!"},
        {"may the force", "be with you."},
        {"i solemnly swear", "that i am up to no good."},
        {"expecto patronum!"},
        {"it's leviOsa,", "not levioSA."},
        {"you shall not pass!"},
        {"mewgenics hates you more"},
        {"meow meow meow meow", "meow meow meow meow meow"},
        {"thank you for your time"},
        {"good luck with COTV!"},
        {"nice buddy, nice"},
        {"spicy fireplace"},
        {"garlic is my enemy"},
        {"eat this, potato!"},
        {"my pleasure"},
        {"want a refill?"},
    }
end

set_kill_msgs()

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        data.persistent_state = GODMODE.persistent_state.single_room
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local anim = "DevilFlame"
    if ent.SubType == 1 then anim = "AngelFlame" end
    if ent.SubType == 2 then anim = "AdraFlame" end
    if ent.SubType == 3 then anim = "LightFlame" end
    if ent.SubType == 4 then anim = "FlameOut"
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
    
    if not sprite:IsPlaying(anim) then
        sprite:Play(anim,false)
        ent.SplatColor = Color(0,0,0,0,1,1,1)
        data.ori_position = ent.Position
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end
    
    if data.persistent_data and data.persistent_data.in_room == true then
        ent.Position = data.ori_position
    end

    if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
        ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    end

    if not GODMODE.sfx:IsPlaying(SoundEffect.SOUND_FIRE_BURN) then 
        ent:PlaySound(SoundEffect.SOUND_FIRE_BURN,1,1,true,0.9+ent:GetDropRNG():RandomFloat()*0.075)
    end

    ent.Velocity = Vector(0,0)
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType ~= 4 and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
        local flag = (GODMODE.room_type or GODMODE.room:GetType()) == RoomType.ROOM_BOSS and GODMODE.is_at_palace and GODMODE.is_at_palace()

        GODMODE.util.macro_on_enemies(nil,GODMODE.registry.entities.masked_angel_statue.type,GODMODE.registry.entities.masked_angel_statue.variant,nil,
            function(statue) flag = flag or (ent.Position - statue.Position):Length() < 256 end)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,1,ent.Position,Vector.Zero,ent)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,2,ent.Position,Vector.Zero,ent)

        if flag == false then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, ent.Position, Vector(0,0), ent)
            set_kill_msgs()

            if GODMODE.level:GetStage() > LevelStage.STAGE4_3 then
                monster.kill_msgs[8][1] = monster.kill_msgs[8][1].."even more time"
            elseif GODMODE.level:GetStage() > LevelStage.STAGE3_2 then
                monster.kill_msgs[8][1] = monster.kill_msgs[8][1].."hush"
            else
                monster.kill_msgs[8][1] = monster.kill_msgs[8][1].."boss rush"
            end
            
            local msg = ent:GetDropRNG():RandomInt(#monster.kill_msgs)+1
            GODMODE.game:GetHUD():ShowFortuneText(monster.kill_msgs[msg][1],monster.kill_msgs[msg][2],monster.kill_msgs[msg][3])
        else
            local place = Isaac.Spawn(ent.Type,ent.Variant,4,ent.Position,Vector.Zero,ent)
            place:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            place:Update()
        end

        GODMODE.sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS)
    end
end

return monster