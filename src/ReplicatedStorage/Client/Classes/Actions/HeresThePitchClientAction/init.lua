--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local React = require(ReplicatedStorage.Shared.Packages.react);
local HUDButton = require(script.Parent.Parent.Parent.ReactComponents.HUDButton);
local types = require(ReplicatedStorage.Client.Modules.types);

local HeresThePitchClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Here's the Pitch";
  description = "Strike them out";
  iconImage = "rbxassetid://18464513809";
  __index = {} :: types.HeresThePitchClientAction;
};

local player = Players.LocalPlayer;

function HeresThePitchClientAction.new(): types.HeresThePitchClientAction

  local remoteName = `{player.UserId}_{HeresThePitchClientAction.id}`;
  local overwrittenProperties = {
    id = HeresThePitchClientAction.id;
    name = HeresThePitchClientAction.name;
    iconImage = HeresThePitchClientAction.iconImage;
    description = HeresThePitchClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
  };

  local action = (setmetatable(overwrittenProperties, HeresThePitchClientAction) :: any) :: types.HeresThePitchClientAction;

  ReplicatedStorage.Client.Functions.AddHUDButton:Invoke("Action", React.createElement(HUDButton, {
    type = "Action";
    key = action.id;
    shortcutCharacter = "L";
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = "rbxassetid://90434649353486";
  }));

  action.remoteFunction.OnClientInvoke = function(ballName: string)

    local ball = workspace:FindFirstChild(ballName);
    assert(ball);

    local weld = ball:FindFirstChild("WeldConstraint");
    assert(weld and weld:IsA("WeldConstraint"));

    -- TODO: Run animations
    local throwingHand = weld.Part1;

  end;

  local function checkInput(_, inputState: Enum.UserInputState, inputType: Enum.UserInputType)

    if inputState == Enum.UserInputState.Begin then

      action:activate(if inputType then player:GetMouse().Hit.Position else nil);

    end;

  end;

  ContextActionService:BindAction("ActivateFoulBallBlitz", checkInput, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.X);

  return action;

end

function HeresThePitchClientAction.__index:activate(coordinates: Vector3?)

  -- Ask the server to create the ball.
  self.remoteFunction:InvokeServer(coordinates);

end

function HeresThePitchClientAction.__index:breakdown()
    
  ReplicatedStorage.Client.Functions.DestroyHUDButton:Invoke("Action", self.id);
  ContextActionService:UnbindAction("ActivateFoulBallBlitz");

end;

return HeresThePitchClientAction;
