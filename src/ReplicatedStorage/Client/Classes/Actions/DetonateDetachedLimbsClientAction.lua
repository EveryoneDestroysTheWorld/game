--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
-- local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ActionButton = require(script.Parent.Parent.Parent.ReactComponents.ActionButton);
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

  local action = ClientAction.new({
    ID = DetonateDetachedLimbsClientAction.ID;
    iconImage = DetonateDetachedLimbsClientAction.iconImage;
    name = DetonateDetachedLimbsClientAction.name;
    description = DetonateDetachedLimbsClientAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  ReplicatedStorage.Client.Functions.AddActionButton:Invoke(React.createElement(ActionButton, {
    onActivate = function() action:activate() end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17771918066";
  }));

  return action;

end

return DetonateDetachedLimbsClientAction;