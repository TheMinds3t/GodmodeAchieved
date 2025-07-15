local tutorials = {}

--standardized text box creation function
tutorials.create_text = function(player, text, fill_spd) 
    if tutorials.text_box then 
        tutorials.text_box.cur_text = ""
    else 
        tutorials.text_box = {real_opacity = 1.0}
    end

    tutorials.set_text_box(function()
        local player_pos = Isaac.WorldToScreen(player.Position)
        local center = GODMODE.util.get_center_of_screen()
        local pos = Vector(((player_pos.X-45)+center.X)/2.0, center.Y)

        if player_pos.Y < center.Y then 
            pos.Y = pos.Y
        else 
            pos.Y = pos.Y / 2
        end

        return pos
    end, text, true,0.66,0.75,fill_spd)
end

-- list of all tutorials
tutorials.list = {
    ["CharacterLocked"] = {
        lock_doors = true, lock_controls = false, unlock = true,
    },
    ["FirstLoad"] = {
        lock_doors = true, lock_controls = false,
        validate_args = function(args) return args[1] and args[1]:ToPlayer() ~= nil end,
        
        timeline = {
            function(self,args)
                local player = args[1]
                tutorials.set_spotlight(player,true,0.5,1,Vector(0,-16))
                tutorials.spotlight.real_opacity = 0.0
                tutorials.spotlight.real_scale = 4.0
                tutorials.create_text(player, "Welcome to Godmode! MINDS3T here. I have a couple notes for you:", 2)
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player, "First: Don't be afraid to configure the mod! Press \'c\' by default.", 1)
                tutorials.set_spotlight(player,true,0.6,0.9,Vector(0,-16))
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player, "Just about every mechanic added is configurable!", 1)
                tutorials.set_spotlight(player,true,0.65,0.89,Vector(0,-16))
                GODMODE.util.schedule_function(function() args[1]:AnimateHappy() end, 50)
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player, "Second: Remember, lots of goods, lots of baddies too. Be safe", 1)
                tutorials.set_spotlight(player,true,0.75,0.875,Vector(0,-16))
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player, "Third: If you get down...", 3)
                tutorials.set_spotlight(player,true,0.95,0.7,Vector(0,-16))
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player, "The void will be calling your name!", 1)
                GODMODE.game:ShakeScreen(20)
                tutorials.set_spotlight(player,true,0.99,0.5,Vector(0,-16))
                GODMODE.util.schedule_function(function() args[1]:AnimateSad() end, 20)
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player, "Anyways...", 2)
                tutorials.set_spotlight(player,true,0.7,0.8,Vector(0,-16))

                -- manually proc this one
                GODMODE.util.schedule_function(function() tutorials.waiting_for_input = 1 end, 50)
            end,

            function(self,args)
                local player = args[1]
                tutorials.create_text(player,"Best of luck, and enjoy the mod! I hope you achieve Godmode :)", 2)
                tutorials.set_spotlight(player,true,0.5,1.25,Vector(0,-16))
            end,

            function(self,args)
                args[1]:AnimateHappy()
                GODMODE.util.schedule_function(function() tutorials.waiting_for_input = 1 end, 30)
            end,

            true,
        }
    },
    ["StatScore"] = {
        lock_doors = false, lock_controls = true,
        validate_args = function(args) return args[1] and args[1]:ToPlayer() ~= nil end,
        get_pos = function(args) return args[1] end,
        timeline = {
            function(self,args)
                local player = args[1]
                tutorials.set_arrow(self.get_pos(args),0,true,0.66,Vector(-36,-16))
                tutorials.set_spotlight(self.get_pos(args),true,0.5,1,Vector(0,-16))
                tutorials.spotlight.real_opacity = 0.0
                tutorials.spotlight.real_scale = 4.0
                GODMODE.get_ent_data(player).red_coin_display = 10000
                tutorials.create_text(player, "A quick overview of the bar to your left here...", 1)
            end,

            function(self,args)
                local player = args[1]
                tutorials.set_spotlight(self.get_pos(args),true,0.6,1,Vector(-24,-16))
                tutorials.set_arrow(self.get_pos(args),0,true,0.75,Vector(-24,20))
                GODMODE.get_ent_data(player).red_coin_display = 10000
                tutorials.create_text(player, "This represents your stat score. It keeps track of your run.", 1)
            end,

            function(self,args)
                local player = args[1]
                tutorials.set_spotlight(self.get_pos(args),true,0.65,0.9,Vector(0,-16))
                tutorials.set_arrow(self.get_pos(args),-45,true,1,Vector(-12,6))
                GODMODE.get_ent_data(player).red_coin_display = 10000
                tutorials.create_text(player, "If you are too weak, Godmode can help! Here's how:", 1)
            end,

            function(self,args)
                local player = args[1]
                tutorials.set_spotlight(self.get_pos(args),true,0.66,0.7,Vector(-26,-16))
                tutorials.set_arrow(self.get_pos(args),66,true,0.75,Vector(-30,-16))
                GODMODE.get_ent_data(player).red_coin_display = 10000
                tutorials.create_text(player, "If the blue bar goes below the red bar, a correction portal spawns!", 1)
            end,

            function(self,args)
                local player = args[1]
                tutorials.set_arrow(self.get_pos(args),20,true,0.6,Vector(-30,-16))
                GODMODE.get_ent_data(player).red_coin_display = 10000
                tutorials.create_text(player, "If there is no red bar, correction portals cannot spawn here!", 1)
            end,

            function(self,args)
                local player = args[1]
                tutorials.set_spotlight(self.get_pos(args),false,0.5,1.1,Vector(0,-16))
                tutorials.set_arrow(self.get_pos(args),120,false,0.4,Vector(-30,-16))
                GODMODE.get_ent_data(player).red_coin_display = math.min(50,GODMODE.get_ent_data(player).red_coin_display)
                tutorials.create_text(player, "You'll know if you see the portal!", 1)
            end,

            function(self,args)
                args[1]:AnimateHappy()
                GODMODE.util.schedule_function(function() tutorials.waiting_for_input = 1 end, 30)
            end,

            true,
        }
    }
}

-- how fast to update the position of the spotlight graphic in world coordinates
local max_object_move_speed = 3
local opacity_shift_dampen = 30
local scale_shift_dampen = 35

-- in degrees per second
local rotate_shift_dampen = 33

local max_line_length = 132
local font_color = KColor(53.0/255.0,43.0/255.0,45.0/255.0,1.0)
tutorials.font = Font()
tutorials.font:Load("font/upheaval.fnt") -- load a font into the font object
-- added to the max_object_move_speed
local paper_move_dampen = 10

local skip_to_next_step_time = 310
-- how long to wait, minimum, for skip time. This decreases down to the next variable if the button is held down
local min_time_for_skip = 50
local min_min_skip_time = 10

-- In a render function on every frame:
 -- render string with loaded font on position (60, 50)

tutorials.set_spotlight = function(spotlight_pos,active,opacity,scale,live_offset)
    opacity = opacity == nil and 0.9 or opacity
    spotlight_pos = spotlight_pos == nil and GODMODE.util.get_center_of_screen() or spotlight_pos
    tutorials.spotlight = tutorials.spotlight or {}
    tutorials.spotlight.opacity = tonumber(opacity) or 0.9
    tutorials.spotlight.goal_pos = spotlight_pos 
    tutorials.spotlight.scale = scale 
    tutorials.spotlight.active = active == true 
    tutorials.spotlight.live_offset = live_offset
end

tutorials.set_arrow = function(arrow_pos,arrow_rot,active,scale,live_offset)
    arrow_pos = arrow_pos == nil and GODMODE.util.get_center_of_screen() or arrow_pos
    tutorials.arrow = tutorials.arrow or {}
    tutorials.arrow.goal_pos = arrow_pos 
    tutorials.arrow.scale = scale or 1.0
    tutorials.arrow.active = active == true 
    tutorials.arrow.live_offset = live_offset
    tutorials.arrow.rotation = arrow_rot
end

tutorials.set_text_box = function(text_box_pos,text,active,scale,font_scale,fill_speed,live_offset)
    text_box_pos = text_box_pos == nil and GODMODE.util.get_center_of_screen() or text_box_pos
    tutorials.text_box = tutorials.text_box or {}
    tutorials.text_box.goal_text = text 
    tutorials.text_box.cur_text = ""
    tutorials.text_box.real_opacity = 0
    tutorials.text_box.opacity = 1
    tutorials.text_box.goal_pos = text_box_pos 
    tutorials.text_box.scale = scale or 1.0
    tutorials.text_box.real_scale = tutorials.text_box.scale
    tutorials.text_box.active = active == true 
    tutorials.text_box.live_offset = live_offset
    tutorials.text_box.cur_char = 0
    tutorials.text_box.font_scale = font_scale or 0.66
    tutorials.text_box.fill_speed = fill_speed
    tutorials.text_box.line_list = nil
end

tutorials.update = function()
    -- tutorial is finished
    if tutorials.tutorial_time == nil then 
        -- allow the spotlight to fade out before despawning it 
        if tutorials.spotlight then 
            tutorials.spotlight.scale = 4.0
            tutorials.spotlight.opacity = 0.0

            -- opacity threshold
            if tutorials.spotlight.real_opacity < 0.05 then
                tutorials.spotlight = nil
            end
        end

        --allow the arrow to shrink out before despawning it 
        if tutorials.arrow then 
            tutorials.arrow.scale = 0

            -- scale threshold
            if tutorials.arrow.real_scale < 0.05 then 
                tutorials.arrow = nil
            end
        end

        -- fade text box out before despawning
        if tutorials.text_box then 
            tutorials.text_box.opacity = 0.0

            if tutorials.text_box.opacity <= 0.05 then 
                tutorials.text_box = nil 
            end
        end
    else 
        if tutorials.spotlight and not tutorials.spotlight.active then 
            tutorials.spotlight.scale = 4.0
            tutorials.spotlight.opacity = 0.0

            -- opacity threshold
            if tutorials.spotlight.real_opacity < 0.05 then
                tutorials.spotlight = nil
            end
        end

        if tutorials.arrow and not tutorials.arrow.active then 
            tutorials.arrow.scale = 0

            -- scale threshold
            if tutorials.arrow.real_scale < 0.05 then 
                tutorials.arrow = nil
            end
        end

        -- update text box text
        if tutorials.text_box then 
            if tutorials.text_box.active == false then 
                -- tutorials.spotlight.scale = 4.0
                tutorials.text_box.opacity = 0.0

                -- opacity threshold
                if tutorials.text_box.real_opacity < 0.05 then
                    tutorials.text_box = nil
                end
            end

            tutorials.text_box.text_anim_time = (tutorials.text_box.text_anim_time or -1) + 1
            
            if tutorials.text_box.cur_char <= tutorials.text_box.goal_text:len() + 1 then 
                if tutorials.text_box.text_anim_time % tutorials.text_box.fill_speed == 0 then 
                    local goal_text = tutorials.text_box.goal_text
                    local cur_char = tutorials.text_box.cur_char
                    local next_char = goal_text:sub(cur_char,cur_char)
                    local cur_text = tutorials.text_box.cur_text
                    local lines = GODMODE.util.string_split(cur_text, "\n")
                    local cur_line = lines[#lines]

                    local goal_word_index = cur_char

                    -- essentially is cur_line + the rest of the next word being generated. This is to prevent spillover.
                    local goal_word_line = cur_line..goal_text:sub(cur_char,goal_text:find(" ",(goal_text:find(" ",goal_word_index) or -1)+1))
                    -- GODMODE.log("Step "..cur_char..": \n->cur_text =  "..tutorials.text_box.cur_text:gsub("\n","\\n").."\n->goal_text = "..tutorials.text_box.goal_text.."\n->goal_word_line = "..goal_word_line.."\n",true)
                    tutorials.text_box.line_list = tutorials.text_box.line_list or {}

                    if tutorials.font:GetStringWidth(goal_word_line) * tutorials.text_box.font_scale > max_line_length and next_char == " " then 
                        next_char = next_char.."\n"
                        tutorials.text_box.line_list = lines
                    end

                    tutorials.text_box.cur_char = tutorials.text_box.cur_char + 1
                    tutorials.text_box.cur_text = tutorials.text_box.cur_text..next_char
                    tutorials.text_box.line_list[#lines] = lines[#lines]
                    GODMODE.sfx:Play(GODMODE.registry.sounds.tutorial_text)
                end

                tutorials.waiting_for_input = math.max(tutorials.waiting_for_input, skip_to_next_step_time-tutorials.min_skip_time-1)
            end
        end
    end

    -- if there are any active tutorials, run through the first one queued
    if tutorials.active_id_queue and #tutorials.active_id_queue > 0 then 
        local cur_entry = tutorials.active_id_queue[1]
        local dat = tutorials.list[cur_entry.id]
        local store_type = tonumber(GODMODE.save_manager.get_config("Tutorial"..cur_entry.id,"1"))
        local timeline_action = dat.timeline[tutorials.tutorial_time]
        local skip_button = Input.IsButtonPressed (tonumber(GODMODE.save_manager.get_config("TutorialSkipKey",Keyboard.KEY_ENTER)) or Keyboard.KEY_ENTER, Isaac.GetPlayer().ControllerIndex)
        
        -- add the ability to speed through if undesired
        if skip_button == true and tutorials.waiting_for_input < skip_to_next_step_time - min_min_skip_time then 
            tutorials.min_skip_time = math.max(min_min_skip_time, tutorials.min_skip_time - 1/3)
        else
            tutorials.min_skip_time = min_time_for_skip
        end

        if (tutorials.waiting_for_input or 0) > 0 then 
            tutorials.waiting_for_input = math.max(0,(tutorials.waiting_for_input or 0) - 1)

            if tutorials.waiting_for_input == 0 or skip_button == true and tutorials.waiting_for_input < skip_to_next_step_time - tutorials.min_skip_time then 
                tutorials.waiting_for_input = nil

                tutorials.tutorial_time = (tutorials.tutorial_time or -1) + 1
                timeline_action = dat.timeline[tutorials.tutorial_time]
            end
        else
            tutorials.tutorial_time = (tutorials.tutorial_time or -1) + 1
        end

        if timeline_action == true then -- signal the end 
            if store_type == 1 then -- once per file 
                GODMODE.save_manager.set_persistent_data("Tutorial"..cur_entry.id,1,true)
            elseif store_type == 2 then -- once per session
                GODMODE.tutorials.session_cache = GODMODE.tutorials.session_cache or {}
                GODMODE.tutorials.session_cache[cur_entry.id] = true 
            else -- once per run  
                GODMODE.save_manager.set_data("Tutorial"..cur_entry.id,1,true)
            end

            table.remove(tutorials.active_id_queue,1)
            tutorials.tutorial_time = nil
        elseif timeline_action ~= nil and type(timeline_action) == "function" and tutorials.waiting_for_input == nil then 
            -- GODMODE.log("playing action \'"..tutorials.tutorial_time.."\' for tutorial \'"..cur_entry.id.."\'",true)
            timeline_action(dat,cur_entry.args)
            tutorials.waiting_for_input = skip_to_next_step_time
        end
    end
end

tutorials.render = function()
    local center = GODMODE.util.get_center_of_screen()

    if GODMODE.sprites.tutorial_spotlight == nil then 
        GODMODE.sprites.tutorial_spotlight = Sprite()
        GODMODE.sprites.tutorial_spotlight:Load("godmode/gfx/ui/tutorial/spotlight.anm2",true)
    end

    if tutorials.spotlight then 
        tutorials.spotlight.real_opacity = ((tutorials.spotlight.real_opacity or 0.0) * (opacity_shift_dampen - 1) + tutorials.spotlight.opacity) / opacity_shift_dampen
        tutorials.spotlight.real_scale = ((tutorials.spotlight.real_scale or 1.0) * (scale_shift_dampen - 1) + tutorials.spotlight.scale) / scale_shift_dampen
        GODMODE.sprites.tutorial_spotlight:SetFrame("Spotlight",1)
        GODMODE.sprites.tutorial_spotlight.Color = Color(1,1,1,tutorials.spotlight.real_opacity)
        GODMODE.sprites.tutorial_spotlight.Scale = Vector(tutorials.spotlight.real_scale,tutorials.spotlight.real_scale)

        local goal_pos = tutorials.spotlight.goal_pos
        if goal_pos and goal_pos.Position then 
            goal_pos = Isaac.WorldToScreen(goal_pos.Position) + (tutorials.spotlight.live_offset or Vector.Zero)
        end
        
        tutorials.spotlight.cur_pos = tutorials.spotlight.cur_pos or goal_pos
        local targ = goal_pos - tutorials.spotlight.cur_pos
        tutorials.spotlight.cur_pos = tutorials.spotlight.cur_pos + targ:Resized(math.min(targ:Length(),max_object_move_speed))
        GODMODE.sprites.tutorial_spotlight:Render(tutorials.spotlight.cur_pos+GODMODE.room:GetRenderScrollOffset())
        GODMODE.sprites.tutorial_spotlight.Scale = Vector(1,1)
        GODMODE.sprites.tutorial_spotlight.Color = Color.Default
    end

    if tutorials.arrow then 
        tutorials.arrow.real_rotation = ((tutorials.arrow.real_rotation or 0.0) * (rotate_shift_dampen - 1) + tutorials.arrow.rotation) / rotate_shift_dampen
        tutorials.arrow.real_scale = ((tutorials.arrow.real_scale or 0.0) * (scale_shift_dampen - 1) + tutorials.arrow.scale) / scale_shift_dampen
        local goal_pos = tutorials.arrow.goal_pos

        if goal_pos then 
            if goal_pos and goal_pos.Position then 
                goal_pos = Isaac.WorldToScreen(goal_pos.Position) + (tutorials.arrow.live_offset or Vector.Zero)
            end

            tutorials.arrow.cur_pos = tutorials.arrow.cur_pos or goal_pos
            local targ = goal_pos - tutorials.arrow.cur_pos
            tutorials.arrow.cur_pos = tutorials.arrow.cur_pos + targ:Resized(math.min(targ:Length(),max_object_move_speed))
        end

        GODMODE.sprites.tutorial_spotlight.Color = Color(1,1,1,1)
        GODMODE.sprites.tutorial_spotlight.Rotation = tutorials.arrow.real_rotation
        GODMODE.sprites.tutorial_spotlight.Scale = Vector(tutorials.arrow.real_scale,tutorials.arrow.real_scale)
        GODMODE.sprites.tutorial_spotlight:SetFrame("Arrow",1)
        GODMODE.sprites.tutorial_spotlight:Render(tutorials.arrow.cur_pos+GODMODE.room:GetRenderScrollOffset())
        GODMODE.sprites.tutorial_spotlight.Rotation = 0
        GODMODE.sprites.tutorial_spotlight.Scale = Vector(1,1)
    end

    if tutorials.text_box then 
        GODMODE.sprites.tutorial_spotlight:SetFrame("Paper",1)
        tutorials.text_box.real_opacity = ((tutorials.text_box.real_opacity or 0.0) * (opacity_shift_dampen - 1) + tutorials.text_box.opacity) / opacity_shift_dampen
        tutorials.text_box.real_scale = ((tutorials.text_box.real_scale or 1.0) * (scale_shift_dampen - 1) + tutorials.text_box.scale) / scale_shift_dampen

        local goal_pos = tutorials.text_box.goal_pos
        if goal_pos and type(goal_pos) ~= "function" and goal_pos.Position then 
            goal_pos = Isaac.WorldToScreen(goal_pos.Position) + (tutorials.text_box.live_offset or Vector.Zero)
        end

        if goal_pos and type(goal_pos) == "function" then goal_pos = goal_pos() end 
        
        GODMODE.sprites.tutorial_spotlight.Color = Color(1,1,1,tutorials.text_box.real_opacity)
        GODMODE.sprites.tutorial_spotlight.Scale = Vector(tutorials.text_box.real_scale,tutorials.text_box.real_scale)
        
        tutorials.text_box.cur_pos = tutorials.text_box.cur_pos or goal_pos
        local targ = goal_pos - tutorials.text_box.cur_pos
        tutorials.text_box.cur_pos = tutorials.text_box.cur_pos + targ:Resized(math.min(targ:Length() / paper_move_dampen,max_object_move_speed))
        GODMODE.sprites.tutorial_spotlight:Render(tutorials.text_box.cur_pos+GODMODE.room:GetRenderScrollOffset())
        -- Isaac.RenderScaledText(tutorials.text_box.goal_text,tutorials.text_box.cur_pos.X,tutorials.text_box.cur_pos.Y,1,1,1,1,1,1)
        local text_color = KColor(font_color.Red,font_color.Green,font_color.Blue,tutorials.text_box.real_opacity)
        if tutorials.text_box.line_list then 
            for ind,line in ipairs(tutorials.text_box.line_list) do 
                tutorials.font:DrawStringScaled(
                    line,
                    tutorials.text_box.cur_pos.X,tutorials.text_box.cur_pos.Y + tutorials.font:GetLineHeight() * tutorials.text_box.font_scale * (ind - 1),
                    tutorials.text_box.font_scale * tutorials.text_box.real_scale,tutorials.text_box.font_scale * tutorials.text_box.real_scale,
                    text_color,0,true)
            end
        end

        GODMODE.sprites.tutorial_spotlight.Scale = Vector(1,1)

        local key = tonumber(GODMODE.save_manager.get_config("TutorialSkipKey",Keyboard.KEY_ENTER)) or Keyboard.KEY_ENTER
        if (tutorials.waiting_for_input or skip_to_next_step_time) < skip_to_next_step_time - min_min_skip_time then 
            tutorials.skip_hint = math.min((tutorials.skip_hint or -1) + 1,20)
            local text_shadow_col = KColor(0,0,0,0.5 * tutorials.text_box.real_opacity * tutorials.skip_hint / 20.0)
            local time_left = math.floor(tutorials.waiting_for_input * 10 / 30.0) / 10.0
            local str = "Press \'"..GODMODE.util.keyboard_enum_names()[key].."\' to continue.. ("..time_left.." s)"
            local pos = GODMODE.util.get_center_of_screen() * Vector(1,1.875) - Vector(tutorials.font:GetStringWidth(str) / 2.0 * 0.5,0)
            tutorials.font:DrawStringScaled(str,pos.X,  pos.Y-2,0.66,0.66,text_shadow_col)
            tutorials.font:DrawStringScaled(str,pos.X-6,pos.Y-2,0.66,0.66,text_shadow_col)
            tutorials.font:DrawStringScaled(str,pos.X+6,pos.Y-2,0.66,0.66,text_shadow_col)
            tutorials.font:DrawStringScaled(str,pos.X,  pos.Y  ,0.5,0.5,KColor(1,1,1,tutorials.text_box.real_opacity * tutorials.skip_hint / 15.0))
        else
            tutorials.skip_hint = 0
        end
    end
end

tutorials.activate_tutorial = function(tutorial_id, tutorial_args)
    if tutorials.list[tutorial_id] then 
        if tutorials.list[tutorial_id].validate_args(tutorial_args) == true then 
            local activate_state = tonumber(GODMODE.save_manager.get_config("Tutorial"..tutorial_id,"1"))

            if activate_state == 1 and GODMODE.save_manager.get_persistant_data("Tutorial"..tutorial_id,"0") == "0" or -- once per file
                active_state == 2 and (not tutorials.session_cache or tutorials.session_cache[tutorial_id] ~= true) or -- once per session
                active_state == 3 and GODMODE.save_manager.get_data("Tutorial"..tutorial_id,"0") == "0" then -- once per run

                tutorials.active_id_queue = tutorials.active_id_queue or {}
                table.insert(tutorials.active_id_queue, {id=tutorial_id,args=tutorial_args})
            end
        else
            GODMODE.log("Arguments failed to validate for \'"..tutorial_id.."\' activation, aborting...",true)
        end
    else 
        GODMODE.log("Non-existent tutorial ID \'"..tutorial_id.."\', cannot activate. Aborting...",true)
    end
end


return tutorials 