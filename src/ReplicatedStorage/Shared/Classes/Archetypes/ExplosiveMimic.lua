--!strict
local Archetype = require(script.Parent.Parent.Parent.Interfaces.Archetype);
local DetachLimb = require(script.Parent.Parent.Actions.DetachLimb);
type Archetype = Archetype.Archetype;

local archetype: Archetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "You're the bomb! No, seriously. Your limbs are explosive, but don't worry: you regenerate them. You can also cause explosions with your hands and feet!";
  type = "Destroyer";
  actions = {DetachLimb};
}

return archetype;