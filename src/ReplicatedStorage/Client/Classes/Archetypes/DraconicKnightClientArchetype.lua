--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local DraconicKnightClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Draconic Knight";
  description = "Fly above the enemy and let the vengeance flow";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {"LockOn", "TakeFlight", "DiveBomb", "BeastSlash", "TarBomb", "FireBeam"};
  type = "Defender" :: "Defender";
};

function DraconicKnightClientArchetype.new(): ClientArchetype

  local archetype: ClientArchetype = {
    id = DraconicKnightClientArchetype.id;
    iconImage = DraconicKnightClientArchetype.iconImage;
    name = DraconicKnightClientArchetype.name;
    description = DraconicKnightClientArchetype.description;
    actionIDs = DraconicKnightClientArchetype.actionIDs;
    type = DraconicKnightClientArchetype.type;
    breakdown = function(self: ClientArchetype)

    end;
  };

  return archetype;

end;

return DraconicKnightClientArchetype;