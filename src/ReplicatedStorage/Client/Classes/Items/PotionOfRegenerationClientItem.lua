--!strict
-- This module represents a Potion of Regeneration on the client side. It should only be used for item activations.
--
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;
local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);

local PotionOfRegenerationClientItem = {
  id = script.Name:sub(1, script.Name:gsub("ClientItem", ""):len());
  name = "Potion of Regeneration";
  description = "Drinking this item for 3 seconds (which can be cancelled in the process) will regenerate your health by +4 HP per second for 20 seconds.";
  iconImage = "rbxassetid://97864489690791";
};

function PotionOfRegenerationClientItem.new(): ClientItem

  local _specificItemID: string?;

  local function breakdown(self: ClientItem)

    assert(_specificItemID);
    HUDService:removeHUDButton("Item", _specificItemID);

  end;

  local function activate(self: ClientItem)

    assert(_specificItemID);
    ReplicatedStorage.Shared.Functions.ItemFunctions:FindFirstChild(_specificItemID):InvokeServer();

  end;

  local function initialize(self: ClientItem, specificItemID: string)

    _specificItemID = specificItemID;
    HUDService:addHUDButton({
      type = "Item";
      key = specificItemID;
      onActivate = function() self:activate() end;
      iconImage = "rbxassetid://17551046771";
    });

  end;

  return ClientItem.new({
    id = PotionOfRegenerationClientItem.id;
    iconImage = PotionOfRegenerationClientItem.iconImage;
    name = PotionOfRegenerationClientItem.name;
    description = PotionOfRegenerationClientItem.description;
    breakdown = breakdown;
    activate = activate;
    initialize = initialize;
  });

end;

return PotionOfRegenerationClientItem;