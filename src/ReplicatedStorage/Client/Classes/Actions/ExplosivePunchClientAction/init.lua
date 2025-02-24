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

local ExplosivePunchClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  iconImage = "rbxassetid://17771917538";
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
};

local player = Players.LocalPlayer;

function ExplosivePunchClientAction.new(): SharedTypes.ExplosivePunchClientAction

  local remoteName = `{player.UserId}_{ExplosivePunchClientAction.id}`;
  local action: SharedTypes.ExplosivePunchClientAction = {
    id = ExplosivePunchClientAction.id;
    iconImage = ExplosivePunchClientAction.iconImage;
    name = ExplosivePunchClientAction.name;
    description = ExplosivePunchClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = activate;
    breakdown = breakdown;
  }

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    onActivate = function()

      action:activate();

    end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17771917538";
  });

  local function checkInput(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      action:activate();
    
    end;

  end;

  ContextActionService:BindActionAtPriority("ActivateExplosivePunch", checkInput, false, 2, Enum.UserInputType.MouseButton1, Enum.KeyCode.X);

  return action;

end

return ExplosivePunchClientAction;
