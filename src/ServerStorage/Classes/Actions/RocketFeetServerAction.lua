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

  local areRocketsEnabled = false;
  local rocketFeetToggledEvent: RemoteEvent? = nil;

  local action: ServerAction = nil;

  local function activate()

    if contestant.character then

      local humanoid = contestant.character:FindFirstChild("Humanoid");
      assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character}'s Humanoid`);

      if humanoid:GetAttribute("Stamina") >= 10 then

        local function activateFeetExplosions(staminaReduction: number)

          for _, explosivePart in ipairs({leftFootExplosivePart, rightFootExplosivePart}) do

            local explosion = Instance.new("Explosion");
            explosion.BlastPressure = 0;
            explosion.BlastRadius = 10;
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

          -- Reduce the player's stamina.
          humanoid:SetAttribute("Stamina", humanoid:GetAttribute("Stamina") - staminaReduction);

        end;

        if not areRocketsEnabled and contestantExecutionTime and contestantExecutionTime > DateTime.now().UnixTimestampMillis - 500 then

          -- Enable flying for the player.
          local humanoidRootPart = contestant.character:FindFirstChild("HumanoidRootPart");
          assert(humanoidRootPart, "Couldn't find humanoidRootPart.");
          areRocketsEnabled = true;
          task.spawn(function()

            local directionVelocity = Instance.new("LinearVelocity");
            directionVelocity.Name = "Direction";
            directionVelocity.Attachment0 = humanoidRootPart:FindFirstChild("RootAttachment") :: Attachment;
            directionVelocity.MaxForce = math.huge;
            directionVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0;
            directionVelocity.Parent = humanoidRootPart;

            local alignOrientation = Instance.new("AlignOrientation");
            alignOrientation.Name = "Angle";
            alignOrientation.Attachment0 = humanoidRootPart:FindFirstChild("RootAttachment") :: Attachment;
            alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment;
            alignOrientation.Responsiveness = math.huge;
            alignOrientation.MaxTorque = math.huge;
            alignOrientation.Parent = humanoidRootPart;

            local toggleEvent;
            if contestant.player and rocketFeetToggledEvent then

              toggleEvent = rocketFeetToggledEvent.OnServerEvent:Connect(function(player: Player, cameraOrientation: CFrame, vectorVelocity: Vector3)

                if player == contestant.player then

                  assert(typeof(cameraOrientation) == "CFrame", "Camera orientation is not a CFrame");
                  assert(typeof(vectorVelocity) == "Vector3", "VectorVelocity is not a Vector3");

                  alignOrientation.CFrame = cameraOrientation;
                  directionVelocity.VectorVelocity = vectorVelocity;

                end;

              end);
              rocketFeetToggledEvent:FireClient(contestant.player, true);

            end;

            -- Add explosion effects.
            repeat

              activateFeetExplosions(2);
              task.wait(0.25);

            until humanoid:GetAttribute("Stamina") < 2 or not areRocketsEnabled;
            areRocketsEnabled = false;

            if contestant.player and rocketFeetToggledEvent and toggleEvent then

              rocketFeetToggledEvent:FireClient(contestant.player, false);
              toggleEvent:Disconnect();

            end;

          end)
    
        else
    
          areRocketsEnabled = false;
          activateFeetExplosions(10);
    
        end;
    
        contestantExecutionTime = DateTime.now().UnixTimestampMillis;

      end;
  
    end;

  end;

  local executeActionRemoteFunction: RemoteFunction? = nil;

  local function breakdown()

    if rocketFeetToggledEvent then

      rocketFeetToggledEvent:Destroy();

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

    local remoteEvent = Instance.new("RemoteEvent");
    remoteEvent.Name = `{contestant.player.UserId}_{action.ID}`;
    remoteEvent.Parent = ReplicatedStorage.Shared.Events.ActionEvents;
    rocketFeetToggledEvent = remoteEvent;

  end

  return action;

end;

return RocketFeetServerAction;
