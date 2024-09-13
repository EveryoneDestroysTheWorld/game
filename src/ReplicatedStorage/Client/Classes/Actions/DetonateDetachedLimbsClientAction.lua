--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
-- local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
type ClientAction = ClientAction.ClientAction;

local DetonateDetachedLimbsClientAction = {
  ID = 3;
  name = "Detonate Detached Limbs";
  iconImage = "rbxassetid://17771918066";
  description = "Explodes all detached limbs and regenerates them.";
};

function DetonateDetachedLimbsClientAction.new(): ClientAction

  local player = Players.LocalPlayer;

  local function breakdown(self: ClientAction)

    

  end;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(`{player.UserId}_{DetonateDetachedLimbsClientAction.ID}`):InvokeServer();

  end;

  local function initialize(self: ClientAction)

    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
      type = "Action";
      key = self.ID;
      onActivate = function() 
        
        self:activate();
      
      end;
      shortcutCharacter = "L";
      iconImage = "rbxassetid://17771918066";
    }));

  end;

  local action = ClientAction.new({
    ID = DetonateDetachedLimbsClientAction.ID;
    iconImage = DetonateDetachedLimbsClientAction.iconImage;
    name = DetonateDetachedLimbsClientAction.name;
    description = DetonateDetachedLimbsClientAction.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });
  
  return action;

end

return DetonateDetachedLimbsClientAction;