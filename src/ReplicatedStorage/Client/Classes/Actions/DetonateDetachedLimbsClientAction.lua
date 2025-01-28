--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
local types = require(ReplicatedStorage.Client.Modules.types);

local DetonateDetachedLimbsClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Detonate Detached Limbs";
  iconImage = "rbxassetid://17771918066";
  description = "Explodes all detached limbs and regenerates them.";
  __index = {} :: types.DetonateDetachedLimbsClientAction;
};

local player = Players.LocalPlayer;

function DetonateDetachedLimbsClientAction.new(): types.DetonateDetachedLimbsClientAction

  local remoteName = `{player.UserId}_{DetonateDetachedLimbsClientAction.id}`;
  local overwrittenProperties = {
    id = DetonateDetachedLimbsClientAction.id;
    iconImage = DetonateDetachedLimbsClientAction.iconImage;
    name = DetonateDetachedLimbsClientAction.name;
    description = DetonateDetachedLimbsClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName);
  };

  local action = (setmetatable(overwrittenProperties, DetonateDetachedLimbsClientAction) :: any) :: types.DetonateDetachedLimbsClientAction;

  ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
    type = "Action";
    key = action.id;
    onActivate = function() 
      
      action:activate();
    
    end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://136558858062155";
  }));
  
  return action;

end

function DetonateDetachedLimbsClientAction.__index:activate()

  self.remoteFunction:InvokeServer();

end;

function DetonateDetachedLimbsClientAction.__index:breakdown()
    
  ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end

return DetonateDetachedLimbsClientAction;