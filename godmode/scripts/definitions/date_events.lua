local events = {}
events.dates = {
    {
        name="MINDS3T's birthday",
        date = {month=6, day=4},
        modifier = function() 
            GODMODE.birthday_mode = true 
        end 
    },
    {
        name="Harvester's birthday",
        date = {month=9, day=6},
        modifier = function() 
            GODMODE.birthday_mode = true 
        end 
    },
    {
        name="Busybody's birthday",
        date = {month=11, day=7},
        modifier = function() 
            GODMODE.birthday_mode = true 
        end 
    },

    {
        name="April Fool's",
        date = {month=4, day=1},
        modifier = function() 
            GODMODE.keepah_mode = true 
        end 
    },

    {
        name="Christmas Eve",
        date = {month=12, day=24},
        modifier = function() 
            GODMODE.christmas_mode = true 
        end 
    },
    {
        name="Christmas Day",
        date = {month=12, day=25},
        modifier = function() 
            GODMODE.christmas_mode = true 
        end 
    },
    {
        name="Post-Christmas Day",
        date = {month=12, day=26},
        modifier = function() 
            GODMODE.christmas_mode = true 
        end 
    },
}

events.get_active_events = function(activate) -- thank you @psi_starbean in MOI #resources for the date checking template!
    activate = activate == nil and false or activate
    if GODMODE.validate_rgon() then 
        local currentDate = os.date("*t") -- converts the current date to a table
        local active_events = {} 

        for _,event in ipairs(events.dates) do 
            if currentDate.month == event.date.month and currentDate.day == event.date.day then 
                table.insert(active_events, event)

                if activate == true then 
                    event.modifier()
                end
            end
        end

        events.active_events = active_events

        return active_events
    end

    return {}
end


return events

