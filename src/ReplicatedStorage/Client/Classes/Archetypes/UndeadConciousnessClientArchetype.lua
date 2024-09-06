--!strict
local ClientArchetype = require(script.Parent.Parent.ClientArchetype);
local Contestant = require(script.Parent.Parent.Contestant);
type Contestant = Contestant.Contestant;
type ClientArchetype = ClientArchetype.ClientArchetype;
local UndeadConciousnessClientArchetype = {
  ID = 1;
  name = "Undead Conciousness";
  description = "You can be unfortunate enough that no one would save you while downed, but with undead yourself, you can hunt down your enemies for vengeance!";
  actionIDs = {};
  type = "Supporter" :: "Supporter";
};
function UndeadConciousnessClientArchetype.new(contestant: Contestant): ClientArchetype

  local function breakdown(self: ClientArchetype)

  end;

  return ClientArchetype.new({
    ID = UndeadConciousnessClientArchetype.ID;
    name = UndeadConciousnessClientArchetype.name;
    description = UndeadConciousnessClientArchetype.description;
    actionIDs = UndeadConciousnessClientArchetype.actionIDs;
    type = UndeadConciousnessClientArchetype.type;
    breakdown = breakdown;
  });

end;

return UndeadConciousnessClientArchetype;