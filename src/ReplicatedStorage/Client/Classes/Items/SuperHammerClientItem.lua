--!strict
-- This module represents a Super Hammer on the client side. It should only be used for item activations.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ClientItem = require(script.Parent.Parent.ClientItem);
type ClientItem = ClientItem.ClientItem;
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(ReplicatedStorage.Client.ReactComponents.HUDButton);
local ContextActionService = game:GetService("ContextActionService");

local SuperHammerClientItem = {
  ID = 3;
  name = "Super Hammer";
  description = "Players can use the Giant Hammer to destroy structures and give their enemies a nice facial. Can be thrown, but the player gotta get it back themself!";
  iconImage = "rbxassetid://131350242938144";
};

function SuperHammerClientItem.new(): ClientItem

  local _itemNumber: number?;
  local isActivated: boolean = false;

  local function toggleHotkeys(self: ClientItem)

    if isActivated then

      local function handleHotkeyActivation(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject)

        if inputState == Enum.UserInputState.Begin or inputState == Enum.UserInputState.End then

          self:activate();

        end;

      end;

      ContextActionService:BindActionAtPriority("ActivateSuperHammer", handleHotkeyActivation, false, 1, Enum.UserInputType.MouseButton1);

    else 

      ContextActionService:UnbindAction("ActivateSuperHammer");

    end;

  end

  local function breakdown(self: ClientItem)

    ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Item", `{self.ID}_{_itemNumber}`);

    isActivated = false;
    toggleHotkeys(self);

  end;

  local function activate(self: ClientItem): ()

    assert(_itemNumber);

    local player: Player = Players.LocalPlayer;
    ReplicatedStorage.Shared.Functions.ItemFunctions:FindFirstChild(`{player.UserId}_{self.ID}_{_itemNumber}`):InvokeServer(isActivated);

  end;

  local function initialize(self: ClientItem, itemNumber: number)

    _itemNumber = itemNumber;
    local hudButton = React.createElement(HUDButton, {
      type = "Item";
      key = `{self.ID}_{itemNumber}`;
      onActivate = function() 
        
        isActivated = not isActivated;
        toggleHotkeys(self);
        self:activate();
      
      end;
      iconImage = "rbxassetid://17551046771";
    });
    
    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Item", hudButton);

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