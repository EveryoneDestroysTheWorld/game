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

local activate = require(script.activate);
local breakdown = require(script.breakdown);

local ChangeBallTypeClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Change Ball Type";
  description = "Do a change-up";
  iconImage = "rbxassetid://75206024784140";
};

function ChangeBallTypeClientAction.new(): SharedTypes.ChangeBallTypeClientAction

  local remoteName = `{Players.LocalPlayer.UserId}_{ChangeBallTypeClientAction.id}`;
  local action = {} :: SharedTypes.ChangeBallTypeClientAction;
  action.id = ChangeBallTypeClientAction.id;
  action.name = ChangeBallTypeClientAction.name;
  action.description = ChangeBallTypeClientAction.description;
  action.iconImage = ChangeBallTypeClientAction.iconImage;
  action.remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
  action.activate = activate;
  action.breakdown = breakdown;

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    -- shortcutCharacter = "0 - 9";
    description = action.name;
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = action.iconImage;
  });

  local function checkKey(_, inputState: Enum.UserInputState, inputObject: InputObject)

    if inputState == Enum.UserInputState.Begin then

      local map = {
        [Enum.KeyCode.One] = "Regular";
        [Enum.KeyCode.Two] = "Explosive";
        [Enum.KeyCode.Three] = "Electric";
        [Enum.KeyCode.Four] = "Poison";
      };

      local ballType = map[inputObject.KeyCode];
      if ballType then

        if action.attributes.gui then

          action.attributes.gui:Destroy();
          action.attributes.gui = nil;
    
        end;
    
        action.remoteFunction:InvokeServer(ballType);

        KeybindNotificationService:setMessage(`{ballType} Ball`);

      end;

    end;

  end;

  ContextActionService:BindAction("ActivateChangeBallTypeAction", checkKey, false, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four);

  return action;

end

return ChangeBallTypeClientAction;
