--!strict
-- This module represents a Super Hammer on the client side. It should only be used for item activations.
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash

local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;

local SuperHammerClientItem = {
  ID = 3;
  name = "Super Hammer";
  description = "Players can use the Giant Hammer to destroy structures and give their enemies a nice facial. Can be thrown, but the player gotta get it back themself!";
  iconImage = "rbxassetid://131350242938144";
};

function SuperHammerClientItem.new(): ClientItem

  local function breakdown(self: ClientItem)

  end;

  local function activate(self: ClientItem)

  end;

  local function initialize(self: ClientItem)

  end;

  return ClientItem.new({
    ID = SuperHammerClientItem.ID;
    iconImage = SuperHammerClientItem.iconImage;
    name = SuperHammerClientItem.name;
    description = SuperHammerClientItem.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return SuperHammerClientItem;