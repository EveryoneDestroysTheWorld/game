--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RocketFeetClientAction = require(ReplicatedStorage.Client.Classes.Actions.RocketFeetClientAction);
local ServerStorage = game:GetService("ServerStorage");

local IRocketFeetServerAction = require(ServerStorage.Interfaces.IRocketFeetServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);

local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

type IRocketFeetServerAction = IRocketFeetServerAction.IRocketFeetServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local RocketFeetServerAction = {
  id = RocketFeetClientAction.id;
  name = RocketFeetClientAction.name;
  description = RocketFeetClientAction.description;
};

function RocketFeetServerAction.new(contestant: IServerContestant, round: IServerRound): IRocketFeetServerAction

  local leftFootExplosivePart = Instance.new("Part");
  leftFootExplosivePart.Name = "LeftFootExplosivePart";
  leftFootExplosivePart.CanCollide = false;
  leftFootExplosivePart.Size = Vector3.new(1, 1, 1);
  leftFootExplosivePart.Transparency = 1;

  local rightFootExplosivePart = leftFootExplosivePart:Clone();
  rightFootExplosivePart.Name = "RightFootExplosivePart";

  local function activate(self: IRocketFeetServerAction)

    -- Verify that actions aren't locked.
    assertContestantIsNotActionLocked(contestant);

    if contestant.character then

      local humanoid = contestant.character:FindFirstChild("Humanoid");
      assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.name}'s Humanoid`);

      if contestant.currentStamina >= 10 then

        for _, explosivePart in {leftFootExplosivePart, rightFootExplosivePart} do

          local explosion = Instance.new("Explosion");
          explosion.BlastPressure = 0;
          explosion.BlastRadius = 5;
          explosion.DestroyJointRadiusPercent = 0;
          explosion.Position = explosivePart.Position;
          local hitContestants = {};
          explosion.Hit:Connect(function(basePart)

            -- Damage any parts or contestants that get hit.
            for _, possibleEnemyContestant in round:getContestants() do

              task.spawn(function()

                local possibleEnemyCharacter = possibleEnemyContestant.character;
                if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                  table.insert(hitContestants, possibleEnemyContestant);
                  possibleEnemyContestant:setCurrentHealth(possibleEnemyContestant.currentHealth - 15, {
                    contestantID = contestant.id;
                    actionID = self.id;
                  });

                end;

              end);

            end;
            local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number;
            if basePartCurrentDurability and basePartCurrentDurability > 0 then

              ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, {
                contestantID = contestant.id;
                actionID = self.id;
              });
    
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
        contestant:setCurrentStamina(math.max(0, contestant.currentStamina - 10), {
          contestantID = contestant.id;
          actionID = self.id
        });

      end;

    end;

  end;

  local function breakdown(self: IRocketFeetServerAction)

    if self.remoteFunction then

      self.remoteFunction:Destroy();
  
    end
  
    leftFootExplosivePart:Destroy();
    rightFootExplosivePart:Destroy();
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;

  end;

  local action: IRocketFeetServerAction = {
    attributes = {};
    contestantID = contestant.id;
    description = RocketFeetServerAction.description;
    id = RocketFeetServerAction.id;
    name = RocketFeetServerAction.name;
    activate = activate;
    breakdown = breakdown;
  }

  if contestant.character then

    -- Create the explosive attachments on both feet of the player.
    local humanoid = contestant.character:FindFirstChild("Humanoid");
    assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");

    local isHumanoidR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
    local leftFoot = contestant.character:FindFirstChild(if isHumanoidR15 then "LeftFoot" else "LeftLeg");
    local rightFoot = contestant.character:FindFirstChild(if isHumanoidR15 then "RightFoot" else "RightLeg");
    for _, footInfo in {{leftFoot, leftFootExplosivePart}, {rightFoot, rightFootExplosivePart}} do

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

  local player = contestant.player;
  if player then

    local remoteID = `{player.UserId}_{action.id}`;
    action.remoteFunction = createInventoryRemoteFunction(player, "Action", remoteID, function()
    
      action:activate();

    end);

    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end

  return action;

end;

return RocketFeetServerAction;
