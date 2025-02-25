--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

local ExplosivePunchClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  iconImage = "rbxassetid://17771917538";
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
};

local player = Players.LocalPlayer;

function ExplosivePunchClientAction.new(): ClientAction.ClientAction

  local remoteName = `{player.UserId}_{ExplosivePunchClientAction.id}`;
  local action: ClientAction.ClientAction = {
    id = ExplosivePunchClientAction.id;
    iconImage = ExplosivePunchClientAction.iconImage;
    name = ExplosivePunchClientAction.name;
    description = ExplosivePunchClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = function(self: ClientAction.ClientAction)

      self.remoteFunction:InvokeServer();
    
    end;
    breakdown = function(self: ClientAction.ClientAction)

      ContextActionService:UnbindAction("ActivateExplosivePunch");
      HUDService:removeHUDButton("Action", self.id);
    
    end;
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
