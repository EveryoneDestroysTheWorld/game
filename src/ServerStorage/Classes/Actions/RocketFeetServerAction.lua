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

  local leftFootExplosivePart = Instance.new("Part");
  leftFootExplosivePart.Name = "LeftFootExplosivePart";
  leftFootExplosivePart.CanCollide = false;
  leftFootExplosivePart.Size = Vector3.new(1, 1, 1);

  local rightFootExplosivePart = Instance.new("Part");
  rightFootExplosivePart.Name = "RightFootExplosivePart";
  rightFootExplosivePart.CanCollide = false;
  rightFootExplosivePart.Size = Vector3.new(1, 1, 1);

  local areRocketsEnabled = false

  local function activate()

    if contestant.character then

      if contestantExecutionTime and contestantExecutionTime > DateTime.now().UnixTimestampMillis - 500 then
  
        -- Enable flying for the player.

        -- Activate rockets under the contestant's feet.
        areRocketsEnabled = true;
        task.spawn(function()

          repeat

            for _, explosivePart in ipairs({leftFootExplosivePart, rightFootExplosivePart}) do

              

            end;
            task.wait(0.25);

          until not areRocketsEnabled;

        end)
  
      else
  
        for _, explosivePart in ipairs({leftFootExplosivePart, rightFootExplosivePart}) do

          local explosion = Instance.new("Explosion");
          explosion.BlastPressure = 0;
          explosion.BlastRadius = 20;
          explosion.DestroyJointRadiusPercent = 0;
          explosion.Position = explosivePart.Position;
          explosion.Hit:Connect(function(basePart)
          
            -- Make sure the part isn't a part of the player.
    
            -- Damage any parts or contestants that get hit.
            local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
            if basePartCurrentDurability and basePartCurrentDurability > 0 then
    
              ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, contestant);
    
            end;
    
          end);
          explosion.Parent = explosivePart;

        end;
  
      end;
  
      contestantExecutionTime = DateTime.now().UnixTimestampMillis;
  
    end;

  end;

  local humanoidJumpingEvent: RBXScriptConnection? = nil;
  local executeActionRemoteFunction: RemoteFunction? = nil;

  local function breakdown()

    if humanoidJumpingEvent then

      humanoidJumpingEvent:Disconnect();

    end;

    if executeActionRemoteFunction then

      executeActionRemoteFunction:Destroy();

    end

    leftFootExplosivePart:Destroy();
    rightFootExplosivePart:Destroy();

  end;

  if contestant.character then

    -- Create the explosive attachments on both feet of the player.
    local humanoid = contestant.character:FindFirstChild("Humanoid");
    assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");

    local isHumanoidR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
    local leftFoot = contestant.character:FindFirstChild(if isHumanoidR15 then "LeftFoot" else "LeftLeg");
    local rightFoot = contestant.character:FindFirstChild(if isHumanoidR15 then "RightFoot" else "RightLeg");
    for _, footInfo in ipairs({{leftFoot, leftFootExplosivePart}, {rightFoot, rightFootExplosivePart}}) do

      local foot = footInfo[1];
      local explosivePart = footInfo[2];
      if foot and foot:IsA("BasePart") and explosivePart and explosivePart:IsA("BasePart") then

        local explosiveWeldConstraint = Instance.new("WeldConstraint");
        explosiveWeldConstraint.Part0 = explosivePart;
        explosiveWeldConstraint.Part1 = foot;
        explosiveWeldConstraint.Parent = explosivePart;

        explosivePart.Position = foot.CFrame.Position - (if not isHumanoidR15 then Vector3.new(0, -foot.Size.Y / 2 + -explosivePart.Size.Y / 2, 0) else Vector3.zero);
        explosivePart.Parent = contestant.character;

      end;
    
    end;

  end;

  if contestant.player then

    executeActionRemoteFunction = Instance.new("RemoteFunction");
    executeActionRemoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
    executeActionRemoteFunction.OnServerInvoke = function(player)

      if player == contestant.player then

        action:activate();

      else

        -- That's weird.
        error("Unauthorized.");

      end

    end;
    executeActionRemoteFunction.Parent = ReplicatedStorage.Shared.Functions.ExecuteActionFunctions;

  end

  return ServerAction.new({
    name = RocketFeetServerAction.name;
    ID = RocketFeetServerAction.ID;
    description = RocketFeetServerAction.description;
    breakdown = breakdown;
    activate = activate;
  })

end;

return RocketFeetServerAction;
