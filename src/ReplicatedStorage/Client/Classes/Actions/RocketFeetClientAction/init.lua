--!strict
-- Programmers: Christian Toney (Christian_Toney)
-- Designers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local RocketFeetClientAction = {
  id = script.Name:sub(1, script.Name:gsub("ClientAction", ""):len());
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
  iconImage = "rbxassetid://18464513809";
};

function RocketFeetClientAction.new(): SharedTypes.RocketFeetClientAction

  local player = Players.LocalPlayer;
  local remoteName = `{player.UserId}_{RocketFeetClientAction.id}`

  local action: SharedTypes.RocketFeetClientAction = {
    id = RocketFeetClientAction.id;
    name = RocketFeetClientAction.name;
    iconImage = RocketFeetClientAction.iconImage;
    description = RocketFeetClientAction.description;
    remoteFunction = ReplicatedStorage.Shared.Functions.ActionFunctions:WaitForChild(remoteName);
    attributes = {};
    activate = function(self: SharedTypes.RocketFeetClientAction)

      self.remoteFunction:InvokeServer();
    
    end;
    breakdown = function(self: SharedTypes.RocketFeetClientAction)

      ContextActionService:UnbindAction("ActivateRocketFeet");
    
      if self.attributes.cFrameEvent then
    
        self.attributes.cFrameEvent:Disconnect();
    
      end;
    
      if self.attributes.jumpButtonClickEvent then
    
        self.attributes.jumpButtonClickEvent:Disconnect();
    
      end
      
      HUDService:removeHUDButton("Action", self.id);
    
    end;
  }

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

      action.attributes.jumpButtonClickEvent = jumpButton.MouseButton1Click:Connect(function()
      
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

return RocketFeetClientAction;
