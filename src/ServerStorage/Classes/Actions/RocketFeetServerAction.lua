--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local RocketFeetClientAction = require(ReplicatedStorage.Client.Classes.Actions.RocketFeetClientAction);

local RocketFeetServerAction = {
  ID = RocketFeetClientAction.ID;
  name = RocketFeetClientAction.name;
  description = RocketFeetClientAction.description;
};

function RocketFeetServerAction.new(contestant: ServerContestant): ServerAction

  local contestantExecutionTime: number? = nil;

  local function activate()

    if contestant.character then

      if contestantExecutionTime and contestantExecutionTime > DateTime.now().UnixTimestampMillis - 500 then
  
        -- Enable flying for the player.

        -- Activate rockets under the contestant's feet.
  
  
      else
  
        -- Produce an explosion under the contestant's feet.
        local primaryPart = contestant.character.PrimaryPart;
        assert(primaryPart, "PrimaryPart not found.");
  
        local explosion = Instance.new("Explosion");
        explosion.BlastPressure = 5000000;
        explosion.BlastRadius = 20;
        explosion.DestroyJointRadiusPercent = 0;
        explosion.Position = primaryPart.CFrame.Position - Vector3.new(0, 5, 0);
        explosion.Hit:Connect(function(basePart)
        
          -- Make sure the part isn't a part of the player.
  
          -- Damage any parts or contestants that get hit.
          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, contestant);
  
          end;
  
        end);
        explosion.Parent = workspace;
  
      end;
  
      contestantExecutionTime = DateTime.now().UnixTimestampMillis;
  
    end;

  end;

  local humanoidJumpingEvent: RBXScriptConnection? = nil;

  local function breakdown()

    if humanoidJumpingEvent then

      humanoidJumpingEvent:Disconnect();

    end;

  end;

  if contestant.character then

    local humanoid = contestant.character:FindFirstChild("Humanoid");
    assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");
    local lastJumpTime = nil;
    humanoidJumpingEvent = humanoid.Jumping:Connect(function()
  
      if lastJumpTime and lastJumpTime > DateTime.now().UnixTimestampMillis - 500 then
        
        activate();

      end;

      lastJumpTime = DateTime.now().UnixTimestampMillis;

    end);

  end;

  return ServerAction.new({
    name = RocketFeetServerAction.name;
    ID = RocketFeetServerAction.ID;
    description = RocketFeetServerAction.description;
    breakdown = breakdown;
    activate = activate;
  })

end;

return RocketFeetServerAction;