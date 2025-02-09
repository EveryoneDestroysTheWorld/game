--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local types = require(ReplicatedStorage.Client.Modules.types);

local RocketFeetClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
  iconImage = "rbxassetid://18464513809";
  __index = {} :: types.RocketFeetClientAction;
};

function RocketFeetClientAction.new(): types.RocketFeetClientAction

  local player = Players.LocalPlayer;
  local remoteName = `{player.UserId}_{RocketFeetClientAction.id}`

  local overwrittenProperties = {
    id = RocketFeetClientAction.id;
    name = RocketFeetClientAction.name;
    iconImage = RocketFeetClientAction.iconImage;
    description = RocketFeetClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
  }

  local action = (setmetatable(overwrittenProperties, RocketFeetClientAction) :: any) :: types.RocketFeetClientAction;

  local function checkJump(_, inputState: Enum.UserInputState)

    if inputState == Enum.UserInputState.Begin then

      local humanoid = player.Character:FindFirstChild("Humanoid") :: Humanoid;
      if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        
        action:activate();

      end;
    
    end;

  end;

  ContextActionService:BindActionAtPriority("ActivateRocketFeet", checkJump, false, 2, Enum.KeyCode.Space, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonX);

  if UserInputService.TouchEnabled then

    local jumpButton = player.PlayerGui:FindFirstChild("TouchGui"):FindFirstChild("TouchControlFrame"):FindFirstChild("JumpButton");
    if jumpButton then

      action.jumpButtonClickEvent = jumpButton.MouseButton1Click:Connect(function()
      
        action:activate();

      end);

    end;

  end;

  HUDService:addHUDButton({
    type = "Action";
    key = action.id;
    onActivate = function() action:activate() end;
    shortcutCharacter = "L";
    iconImage = RocketFeetClientAction.iconImage;
  });

  return action;

end

function RocketFeetClientAction.__index:activate()

  self.remoteFunction:InvokeServer();

end

function RocketFeetClientAction.__index:breakdown()

  ContextActionService:UnbindAction("ActivateRocketFeet");

  if self.cFrameEvent then

    self.cFrameEvent:Disconnect();

  end;

  if self.jumpButtonClickEvent then

    self.jumpButtonClickEvent:Disconnect();

  end
  
  HUDService:removeHUDButton("Action", self.id);

end

return RocketFeetClientAction;
