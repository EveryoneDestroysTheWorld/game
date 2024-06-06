--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;

local DetachLimbAction = {
  ID = 4;
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
};

function DetachLimbAction.new(): ClientAction

  local lastJumpTime = 0;

  local action: ClientAction;

  local jumpButtonClickEvent;

  local function breakdown(self: ClientAction)

    ContextActionService:UnbindAction("ActivateRocketFeet");
    if jumpButtonClickEvent then

      jumpButtonClickEvent:Disconnect();

    end

  end;

  local function activate(self: ClientAction)

    ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, script.Parent.Name);

  end;

  local function checkJump()

    if lastJumpTime > DateTime.now().UnixTimestampMillis - 1500 then
        
      action:activate();

    end;

    lastJumpTime = DateTime.now().UnixTimestampMillis;

  end;

  ContextActionService:BindActionAtPriority("ActivateRocketFeet", checkJump, false, 2, Enum.KeyCode.Space, Enum.KeyCode.ButtonA, Enum.KeyCode.ButtonX);

  if UserInputService.TouchEnabled then

    local jumpButton = Players.LocalPlayer.PlayerGui:FindFirstChild("TouchGui"):FindFirstChild("TouchControlFrame"):FindFirstChild("JumpButton");
    if jumpButton then

      jumpButtonClickEvent = jumpButton.MouseButton1Click:Connect(function()
      
        action:activate();

      end);

    end;

  end;

  action = ClientAction.new({
    ID = DetachLimbAction.ID;
    name = DetachLimbAction.name;
    description = DetachLimbAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  return action;

end

return DetachLimbAction;