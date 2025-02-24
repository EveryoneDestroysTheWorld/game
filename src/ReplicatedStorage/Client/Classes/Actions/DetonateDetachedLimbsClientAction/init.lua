--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local activate = require(script.activate);
local breakdown = require(script.breakdown);

local DetonateDetachedLimbsClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Detonate Detached Limbs";
  iconImage = "rbxassetid://17771918066";
  description = "Explodes all detached limbs and regenerates them.";
};

local player = Players.LocalPlayer;

function DetonateDetachedLimbsClientAction.new(): SharedTypes.DetonateDetachedLimbsClientAction

  local remoteName = `{player.UserId}_{DetonateDetachedLimbsClientAction.id}`;
  local action: SharedTypes.DetonateDetachedLimbsClientAction = {
    id = DetonateDetachedLimbsClientAction.id;
    iconImage = DetonateDetachedLimbsClientAction.iconImage;
    name = DetonateDetachedLimbsClientAction.name;
    description = DetonateDetachedLimbsClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = activate;
    breakdown = breakdown;
  };

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    onActivate = function() 
      
      action:activate();
    
    end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://136558858062155";
  });

  local function checkInput(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      action:activate();
    
    end;

  end;

  ContextActionService:BindAction("ActivateDetonateDetachedLimbsAction", checkInput, false, Enum.KeyCode.V);
  
  return action;

end

return DetonateDetachedLimbsClientAction;