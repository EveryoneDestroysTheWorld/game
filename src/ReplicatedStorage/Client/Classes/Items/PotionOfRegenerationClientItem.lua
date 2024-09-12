--!strict
-- This module represents a Potion of Regeneration on the client side. It should only be used for item activations.
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 Beastslash

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);

local PotionOfRegenerationClientItem = {
  ID = 1;
  name = "Potion of Regeneration";
  description = "Drinking this item for 3 seconds (which can be cancelled in the process) will regenerate your health by +4 HP per second for 20 seconds.";
  iconImage = "rbxassetid://97864489690791";
};

function PotionOfRegenerationClientItem.new(): ClientItem

  local _itemNumber: number?;

  local function breakdown(self: ClientItem)

    ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Item", `{self.ID}_{_itemNumber}`);

  end;

  local function activate(self: ClientItem)

    assert(_itemNumber);
    local player = Players.LocalPlayer;
    ReplicatedStorage.Shared.Functions.ItemFunctions:FindFirstChild(`{player.UserId}_{self.ID}_{_itemNumber}`):InvokeServer();

  end;

  local function initialize(self: ClientItem, itemNumber: number)

    local hudButton = React.createElement(HUDButton, {
      type = "Item";
      key = `{self.ID}_{itemNumber}`;
      onActivate = function() self:activate() end;
      iconImage = "rbxassetid://17551046771";
    });
    _itemNumber = itemNumber;
    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Item", hudButton);

  end;

  return ClientItem.new({
    ID = PotionOfRegenerationClientItem.ID;
    iconImage = PotionOfRegenerationClientItem.iconImage;
    name = PotionOfRegenerationClientItem.name;
    description = PotionOfRegenerationClientItem.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return PotionOfRegenerationClientItem;