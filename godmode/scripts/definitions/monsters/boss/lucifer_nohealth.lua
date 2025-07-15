local ret = require("monsters/boss/lucifer.lua")
ret.name = "Lucifer Parts"
ret.type = Isaac.GetEntityTypeByName(ret.name)
ret.variant = Isaac.GetEntityVariantByName(ret.name)
return ret