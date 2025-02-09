--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
local types = require(ReplicatedStorage.Client.Modules.types);

local id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
local name = "Change Modes";
local description = "Do a change-up";
local iconImage = "rbxassetid://18464513809";

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

  ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
    type = "Action";
    key = action.id;
    shortcutCharacter = "L";
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = "rbxassetid://75206024784140";
  }));

  return action;

end

function ChangeModesClientAction.__index:activate()

  local requestedMode = if self.currentMode == "Pitcher" then "Batter" else "Pitcher";
  self.remoteFunction:InvokeServer(requestedMode);

end

function ChangeModesClientAction.__index:breakdown()
    
  ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end;

return ChangeModesClientAction;
