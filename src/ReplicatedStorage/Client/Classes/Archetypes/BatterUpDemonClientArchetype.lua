--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
type ClientArchetype = ClientArchetype.ClientArchetype;

local BatterUpDemonClientArchetype = {
  id = script.Name:sub(1, script.Name:gsub("ClientArchetype", ""):len());
  name = "Batter-Up Demon";
  description = "You'll never strike out with this one.";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {"ChangeBallType"};
  type = "Fighter" :: "Fighter";
};

function BatterUpDemonClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    id = BatterUpDemonClientArchetype.id;
    iconImage = BatterUpDemonClientArchetype.iconImage;
    name = BatterUpDemonClientArchetype.name;
    description = BatterUpDemonClientArchetype.description;
    actionIDs = BatterUpDemonClientArchetype.actionIDs;
    type = BatterUpDemonClientArchetype.type;
    breakdown = breakdown;
    initialize = initialize;
  });

end;

return BatterUpDemonClientArchetype;