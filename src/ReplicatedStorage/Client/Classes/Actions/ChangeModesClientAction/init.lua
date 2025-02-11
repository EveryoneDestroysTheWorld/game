--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local types = require(ReplicatedStorage.Client.Modules.types);

local id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
local name = "Change Modes";
local description = "Do a change-up";
local iconImage = "rbxassetid://70575380921626";

local ChangeModesClientAction = {
  id = id;
  name = name;
  description = description;
  iconImage = iconImage;
  __index = {
    id = id;
    name = name;
    iconImage = iconImage;
    description = description;
  } :: types.ChangeModesClientAction;
};

local player = Players.LocalPlayer;

function ChangeModesClientAction.new(): types.ChangeModesClientAction

  local remoteName = `{player.UserId}_{ChangeModesClientAction.id}`;
  local overwrittenProperties = {
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    currentMode = "Pitcher";
  };

  local action = (setmetatable(overwrittenProperties, ChangeModesClientAction) :: any) :: types.ChangeModesClientAction;

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    shortcutCharacter = "L";
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = iconImage;
  });

  return action;

end

function ChangeModesClientAction.__index:activate()

  local requestedMode: types.BatterUpDemonMode = if self.currentMode == "Pitcher" then "Batter" else "Pitcher";
  self.remoteFunction:InvokeServer(requestedMode);
  self.currentMode = requestedMode;

end

function ChangeModesClientAction.__index:breakdown()
    
  HUDService:removeHUDButton("Action", self.id);

end;

return ChangeModesClientAction;
