--!strict
local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local ClientContestant = require(script.Parent.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
type ClientArchetype = ClientArchetype.ClientArchetype;

local BatterUpDemonClientArchetype = {
  ID = 2;
  name = "Batter-Up Demon";
  description = "You'll never strike out with this one.";
  iconImage = "rbxassetid://18584519829";
  actionIDs = {};
  type = "Fighter" :: "Fighter";
};

function BatterUpDemonClientArchetype.new(): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  local function initialize(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = BatterUpDemonClientArchetype.ID;
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