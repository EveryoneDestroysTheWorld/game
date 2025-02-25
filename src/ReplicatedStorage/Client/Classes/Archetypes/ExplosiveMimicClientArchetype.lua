--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientArchetype = require(ReplicatedStorage.Client.Interfaces.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local ExplosiveMimicClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Explosive Mimic";
  description = "You're the bomb! No, seriously. Your limbs are explosive, but don't worry: you regenerate them. You can also cause explosions with your hands and feet!";
  iconImage = "rbxassetid://18463752295";
  actionIDs = {"ExplosivePunch", "DetachLimb", "DetonateDetachedLimbs", "RocketFeet"};
  type = "Destroyer" :: "Destroyer";
};

function ExplosiveMimicClientArchetype.new(): ClientArchetype

  local archetype: ClientArchetype = {
    id = ExplosiveMimicClientArchetype.id;
    iconImage = ExplosiveMimicClientArchetype.iconImage;
    name = ExplosiveMimicClientArchetype.name;
    description = ExplosiveMimicClientArchetype.description;
    actionIDs = ExplosiveMimicClientArchetype.actionIDs;
    type = ExplosiveMimicClientArchetype.type;
    breakdown = function(self: ClientArchetype)

    end;
  };

  return archetype;

end;

return ExplosiveMimicClientArchetype;