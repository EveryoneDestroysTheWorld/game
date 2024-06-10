--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
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

  local leftFootExplosivePart = Instance.new("Part");
  leftFootExplosivePart.Name = "LeftFootExplosivePart";
  leftFootExplosivePart.CanCollide = false;
  leftFootExplosivePart.Size = Vector3.new(1, 1, 1);
  leftFootExplosivePart.Transparency = 1;

  local rightFootExplosivePart = Instance.new("Part");
  rightFootExplosivePart.Name = "RightFootExplosivePart";
  rightFootExplosivePart.CanCollide = false;
  rightFootExplosivePart.Size = Vector3.new(1, 1, 1);
  rightFootExplosivePart.Transparency = 1;

  local action: ServerAction = nil;

  local function activate()

    if contestant.character then

      local humanoid = contestant.character:FindFirstChild("Humanoid");
      assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character}'s Humanoid`);

      if humanoid:GetAttribute("Stamina") >= 10 then

        for _, explosivePart in ipairs({leftFootExplosivePart, rightFootExplosivePart}) do

          local explosion = Instance.new("Explosion");
          explosion.BlastPressure = 0;
          explosion.BlastRadius = 5;
          explosion.DestroyJointRadiusPercent = 0;
          explosion.Position = explosivePart.Position;
          explosion.Hit:Connect(function(basePart)
          
            -- Make sure the part isn't a part of the player.

            -- Damage any parts or contestants that get hit.
            local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
            if basePartCurrentDurability and basePartCurrentDurability > 0 then
    
              basePart:SetAttribute("CurrentDurability", basePartCurrentDurability - 35);
    
            end;

          end);
          explosion.Parent = explosivePart;

        end;

        -- Activate double jump.
        local primaryPart = contestant.character.PrimaryPart;
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall and primaryPart then

          local linearVelocity = Instance.new("LinearVelocity");
          linearVelocity.VectorVelocity = Vector3.new(0, 60, 0);
          linearVelocity.MaxForce = math.huge;
          linearVelocity.Parent = primaryPart;
          linearVelocity.Attachment0 = primaryPart:FindFirstChild("RootAttachment") :: Attachment;
          task.delay(0.1, function()
          
            linearVelocity:Destroy();

          end);

        end;

        -- Reduce the player's stamina.
        humanoid:SetAttribute("Stamina", humanoid:GetAttribute("Stamina") - 10);

      end;
  
    end;

  end;

  local executeActionRemoteFunction: RemoteFunction? = nil;

  local function breakdown()

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

        explosivePart.Position = foot.CFrame.Position - (if not isHumanoidR15 then Vector3.new(0, foot.Size.Y / 2 + explosivePart.Size.Y / 2, 0) else Vector3.zero);
        explosivePart.Parent = contestant.character;

      end;
    
    end;

  end;

  action = ServerAction.new({
    name = RocketFeetServerAction.name;
    ID = RocketFeetServerAction.ID;
    description = RocketFeetServerAction.description;
    breakdown = breakdown;
    activate = activate;
  });

  if contestant.player then

    local remoteFunction = Instance.new("RemoteFunction");
    remoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
    remoteFunction.OnServerInvoke = function(player)

      if player == contestant.player then

        action:activate();

      else

        -- That's weird.
        error("Unauthorized.");

      end

    end;
    remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
    executeActionRemoteFunction = remoteFunction;

  end

  return action;

end;

return RocketFeetServerAction;
