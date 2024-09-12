--!strict
-- This module represents a Potion of Regeneration on the client side. It should only be used for item activations.
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: InkyTheBlue (InkyTheBlue)
-- © 2024 Beastslash

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;

local PotionOfRegenerationClientItem = {
  ID = 1;
  name = "Potion of Regeneration";
  description = "Drinking this item for 3 seconds (which can be cancelled in the process) will regenerate your health by +4 HP per second for 20 seconds.";
  iconImage = "rbxassetid://97864489690791";
};

function PotionOfRegenerationClientItem.new(): ClientItem

  local function breakdown(self: ClientItem)

    ContextActionService:UnbindAction("Activate");

  end;

  local function activate(self: ClientItem)

    local player = Players.LocalPlayer;
    ReplicatedStorage.Shared.Functions.ItemFunctions:FindFirstChild(`{player.UserId}_{self.ID}`):InvokeServer();

  end;

  local function initialize(self: ClientItem)

    ContextActionService:BindAction("Activate", function(actionName, inputState, inputObject)

      if inputState == Enum.UserInputState.Begin then

        self:activate();

      end;

    end, false);

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