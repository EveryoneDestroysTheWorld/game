--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local activate = require(script.activate);
local breakdown = require(script.breakdown);

local DetachLimbClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Detach Limb";
  iconImage = "rbxassetid://17551046771";
  description = "Detach a limb of your choice. It only hurts a little bit.";
};

local player = Players.LocalPlayer;

function DetachLimbClientAction.new(): SharedTypes.DetachLimbClientAction

  local remoteName = `{player.UserId}_{DetachLimbClientAction.id}`;
  local action: SharedTypes.DetachLimbClientAction = {
    id = DetachLimbClientAction.id;
    name = DetachLimbClientAction.name;
    iconImage = DetachLimbClientAction.iconImage;
    description = DetachLimbClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = activate;
    breakdown = breakdown;
  };

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    onActivate = function() action:activate() end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17551046771";
  });

  local function toggleGUI(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      action:activate()

    end;

  end;

  -- Listen for events.
  ContextActionService:BindActionAtPriority("ActivateDetachLimbAction", toggleGUI, false, 3, Enum.KeyCode.C);

  return action;

end

return DetachLimbClientAction;
