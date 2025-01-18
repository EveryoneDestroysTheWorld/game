--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
type ClientAction = ClientAction.ClientAction;

local ExplosivePunchAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  iconImage = "rbxassetid://17771917538";
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
};

function ExplosivePunchAction.new(): ClientAction

  local player = Players.LocalPlayer;

  local function breakdown(self: ClientAction)

    ContextActionService:UnbindAction("ActivateExplosivePunch");
		ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);

  end;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(`{player.UserId}_{self.id}`):InvokeServer();

  end;

  local function initialize(self: ClientAction)

    ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
      type = "Action";
      key = self.id;
      onActivate = function()
  
        self:activate();
  
      end;
      shortcutCharacter = "L";
      iconImage = "rbxassetid://17771917538";
    }));
  
    local function checkJump(_, inputState: Enum.UserInputState)
  
      if inputState == Enum.UserInputState.Begin then
  
        self:activate();
      
      end;
  
    end;
  
    ContextActionService:BindActionAtPriority("ActivateExplosivePunch", checkJump, false, 2, Enum.UserInputType.MouseButton1);

  end;

  local action = ClientAction.new({
    id = ExplosivePunchAction.id;
    iconImage = ExplosivePunchAction.iconImage;
    name = ExplosivePunchAction.name;
    description = ExplosivePunchAction.description;
    activate = activate;
    breakdown = breakdown;
    initialize = initialize;
  });

  return action;

end

return ExplosivePunchAction;
