--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local KeybindNotificationService = require(ReplicatedStorage.Client.Modules.KeybindNotificationService);
local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local ChangeModesClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Change Modes";
  description = "Do a change-up";
  iconImage = "rbxassetid://70575380921626";
};

function ChangeModesClientAction.new(): SharedTypes.ChangeModesClientAction

  local player = Players.LocalPlayer;
  local remoteName = `{player.UserId}_{ChangeModesClientAction.id}`;
  local action: SharedTypes.ChangeModesClientAction = {
    id = ChangeModesClientAction.id;
    name = ChangeModesClientAction.name;
    description = ChangeModesClientAction.description;
    iconImage = ChangeModesClientAction.iconImage;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {
      currentMode = "Pitcher" :: SharedTypes.BatterUpDemonMode;
    };
    activate = function(self: SharedTypes.ChangeModesClientAction)

      local requestedMode: SharedTypes.BatterUpDemonMode = if self.attributes.currentMode == "Pitcher" then "Batter" else "Pitcher";
      self.remoteFunction:InvokeServer(requestedMode);
      self.attributes.currentMode = requestedMode;
    
    end;
    breakdown = function(self: SharedTypes.ChangeModesClientAction)

      ContextActionService:UnbindAction("ActivateChangeModesAction");
      HUDService:removeHUDButton("Action", self.id);
    
    end;
  };

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    description = action.name;
    shortcutCharacter = "V";
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = action.iconImage;
  });

  local function checkKey(_, inputState: Enum.UserInputState, inputObject: InputObject)

    if inputState == Enum.UserInputState.Begin then

      action:activate();
      KeybindNotificationService:setMessage(action.attributes.currentMode);

    end;

  end;

  ContextActionService:BindAction("ActivateChangeModesAction", checkKey, false, Enum.KeyCode.V);

  return action;

end

return ChangeModesClientAction;
