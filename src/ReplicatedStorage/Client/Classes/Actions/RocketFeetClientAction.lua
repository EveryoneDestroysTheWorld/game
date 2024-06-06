--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");
local ClientAction = require(script.Parent.Parent.ClientAction);
type ClientAction = ClientAction.ClientAction;

local DetachLimbAction = {
  ID = 4;
  name = "Rocket Feet";
  description = "Fly, touch the sky!";
};

function DetachLimbAction.new(): ClientAction

  local humanoidJumpingEvent;
  local lastJumpTime = 0;

  local action: ClientAction;

  local function breakdown(self: ClientAction)

    

  end;

  local function activate(self: ClientAction)

    -- Listen for jumps.
    humanoidJumpingEvent = humanoid.Jumping:Connect(function()
  
      

    end);

    ReplicatedStorage.Shared.Functions.ExecuteAction:InvokeServer(self.ID, script.Parent.Name);

  end;

  local function checkJump()

    if lastJumpTime > DateTime.now().UnixTimestampMillis - 1500 then
        
      action:activate();

    end;

    lastJumpTime = DateTime.now().UnixTimestampMillis;

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