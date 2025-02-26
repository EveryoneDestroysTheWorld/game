--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientArchetype = require(ReplicatedStorage.Client.Interfaces.IClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local UndeadConsciousnessClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Undead Consciousness";
  description = "You can be unfortunate enough that no one would save you while downed, but with undead yourself, you can hunt down your enemies for vengeance!";
  actionIDs = {};
  iconImage = "rbxassetid://130983727429334";
  type = "Supporter" :: "Supporter";
};

function UndeadConsciousnessClientArchetype.new(): ClientArchetype

  local archetype: ClientArchetype = {
    id = UndeadConsciousnessClientArchetype.id;
    name = UndeadConsciousnessClientArchetype.name;
    description = UndeadConsciousnessClientArchetype.description;
    actionIDs = UndeadConsciousnessClientArchetype.actionIDs;
    type = UndeadConsciousnessClientArchetype.type;
    iconImage = UndeadConsciousnessClientArchetype.iconImage;
    breakdown = function(self: ClientArchetype)

    end;
  };

  return archetype;

end;

return UndeadConsciousnessClientArchetype;