--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local DefaultClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Choose an archetype";
  description = "";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {};
  type = "Supporter" :: "Supporter";
};

function DefaultClientArchetype.new(): ClientArchetype

  local archetype: ClientArchetype = {
    id = DefaultClientArchetype.id;
    iconImage = DefaultClientArchetype.iconImage;
    name = DefaultClientArchetype.name;
    description = DefaultClientArchetype.description;
    actionIDs = DefaultClientArchetype.actionIDs;
    type = DefaultClientArchetype.type;
    breakdown = function(self: ClientArchetype)
      
    end;
  };

  return archetype;

end;

return DefaultClientArchetype;