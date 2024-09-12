--!strict
-- This module represents a Rocket Launcher on the client side. It should only be used for item activations.
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 Beastslash

local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;

local RocketLauncherClientItem = {
  ID = 2;
  name = "Rocket Launcher";
  description = "Equip a quad-barrel rocket launcher on pickup. Disables most actions, but allows you to fire up to 4 powerful shots capable of destroying terrain and enemies alike.";
  iconImage = "rbxassetid://97864489690791";
};

function RocketLauncherClientItem.new(): ClientItem

  local function breakdown(self: ClientItem)

  end;

  local function activate(self: ClientItem)

  end;

  local function initialize(self: ClientItem)

  end;

  return ClientItem.new({
    ID = RocketLauncherClientItem.ID;
    iconImage = RocketLauncherClientItem.iconImage;
    name = RocketLauncherClientItem.name;
    description = RocketLauncherClientItem.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return RocketLauncherClientItem;