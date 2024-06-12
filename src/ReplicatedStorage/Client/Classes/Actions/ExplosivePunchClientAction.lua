--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
local React = require(ReplicatedStorage.Shared.Packages.react);
local ActionButton = require(script.Parent.Parent.Parent.ReactComponents.ActionButton);
type ClientAction = ClientAction.ClientAction;

local ExplosivePunchAction = {
  ID = 1;
  name = "Explosive Punch";
  description = "Land explosive punches to your enemies.";
};

function ExplosivePunchAction.new(): ClientAction

  local player = Players.LocalPlayer;
  local remoteName: string;

  local function breakdown(self: ClientAction)

    ContextActionService:UnbindAction("ActivateExplosivePunch");

  end;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ActionFunctions:FindFirstChild(remoteName):InvokeServer();

  end;

  local action = ClientAction.new({
    ID = ExplosivePunchAction.ID;
    name = ExplosivePunchAction.name;
    description = ExplosivePunchAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  ReplicatedStorage.Client.Functions.AddActionButton:Invoke(React.createElement(ActionButton, {
    onActivate = function()

      action:activate();

    end;
    shortcutCharacter = "L";
    iconImage = "rbxassetid://17771917538";
  }));
  
  remoteName = `{player.UserId}_{action.ID}`;

  local function checkJump(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      action:activate();
    
    end;

  end;

  ContextActionService:BindActionAtPriority("ActivateExplosivePunch", checkJump, false, 2, Enum.UserInputType.MouseButton1);

  return action;

end

return ExplosivePunchAction;
