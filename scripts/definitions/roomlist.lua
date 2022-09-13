local rooms = {}

local prefix = "scripts.room_overrides."
local filenames = 
    {
        "first_treasure",
        "the_ritual",
        "the_sacred",
        "souleater",
        "grand_marshall",
        "hostess",
        "bathemo",
        "ludomaw",
        "bubble_plum",
        "megaworm"
    }

for _,name in ipairs(filenames) do
    rooms[prefix..name] = include(prefix..name)
end

return rooms