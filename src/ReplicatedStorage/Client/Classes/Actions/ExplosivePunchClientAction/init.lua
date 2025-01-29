--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
local types = require(ReplicatedStorage.Client.Modules.types);

local ExplosivePunchClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  iconImage = "rbxassetid://17771917538";
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
  __index = {} :: types.ExplosivePunchClientAction;
};

local player = Players.LocalPlayer;

function ExplosivePunchClientAction.new(): types.ExplosivePunchClientAction

  local remoteName = `{player.UserId}_{ExplosivePunchClientAction.id}`;
  local overwrittenProperties = {
    id = ExplosivePunchClientAction.id;
    iconImage = ExplosivePunchClientAction.iconImage;
    name = ExplosivePunchClientAction.name;
    description = ExplosivePunchClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName)
  }

  local action = (setmetatable(overwrittenProperties, ExplosivePunchClientAction) :: any) :: types.ExplosivePunchClientAction;

  ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
    type = "Action";
    key = action.id;
    onActivate = function()

      action:activate();

    end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17771917538";
  }));

  local function checkJump(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      action:activate();
    
    end;

  end;

  ContextActionService:BindActionAtPriority("ActivateExplosivePunch", checkJump, false, 2, Enum.UserInputType.MouseButton1);

  return action;

end

function ExplosivePunchClientAction.__index:activate()

  self.remoteFunction:InvokeServer();

end
  
function ExplosivePunchClientAction.__index:breakdown()

  ContextActionService:UnbindAction("ActivateExplosivePunch");
  ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

end

return ExplosivePunchClientAction;
