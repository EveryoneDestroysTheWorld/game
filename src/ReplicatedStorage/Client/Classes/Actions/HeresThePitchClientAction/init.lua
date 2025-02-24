--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local HeresThePitchClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Here's the Pitch";
  description = "Strike them out";
  iconImage = "rbxassetid://18464513809";
};

local player = Players.LocalPlayer;

function HeresThePitchClientAction.new(): SharedTypes.HeresThePitchClientAction

  local remoteName = `{player.UserId}_{HeresThePitchClientAction.id}`;
  local action: SharedTypes.HeresThePitchClientAction = {
    id = HeresThePitchClientAction.id;
    name = HeresThePitchClientAction.name;
    iconImage = HeresThePitchClientAction.iconImage;
    description = HeresThePitchClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = function(self: SharedTypes.HeresThePitchClientAction)

      -- Ask the server to create the ball.
      self.remoteFunction:InvokeServer(player:GetMouse().Hit.Position);
    
    end;
    breakdown = function(self: SharedTypes.HeresThePitchClientAction)
    
      HUDService:removeHUDButton("Action", self.id);
      ContextActionService:UnbindAction("ActivateFoulBallBlitz");
    
    end;
  };

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    shortcutCharacter = "L";
    onActivate = function() 
    
      action:activate();

    end;
    iconImage = action.iconImage;
  });

  action.remoteFunction.OnClientInvoke = function(ballName: string)

    -- local ball = workspace:FindFirstChild(ballName);
    -- assert(ball);

    -- local weld = ball:FindFirstChild("WeldConstraint");
    -- assert(weld and weld:IsA("WeldConstraint"));

    -- -- TODO: Run animations
    -- local throwingHand = weld.Part1;

  end;

  local function checkInput(_, inputState: Enum.UserInputState, inputType: Enum.UserInputType)

    if inputState == Enum.UserInputState.Begin then

      action:activate();

    end;

  end;

  ContextActionService:BindAction("ActivateFoulBallBlitz", checkInput, false, Enum.UserInputType.MouseButton1, Enum.KeyCode.X);

  return action;

end

return HeresThePitchClientAction;
