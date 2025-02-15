--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local ExplosivePunchClientAction = require(ReplicatedStorage.Client.Classes.Actions.ExplosivePunchClientAction);
local types = require(ServerStorage.Modules.types);

local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

local ExplosivePunchServerAction = {
  id = ExplosivePunchClientAction.id;
  name = ExplosivePunchClientAction.name;
  description = ExplosivePunchClientAction.description;
  __index = {} :: types.ExplosivePunchServerAction;
};

function ExplosivePunchServerAction.new(properties: types.ServerActionConstructorProperties): types.ExplosivePunchServerAction
  
  local overwrittenProperties = {};
  
  local action = (setmetatable(overwrittenProperties, ExplosivePunchServerAction) :: any) :: types.ExplosivePunchServerAction;
  action.contestant = properties.contestant;
  action.id = ExplosivePunchClientAction.id;
  action.name = ExplosivePunchClientAction.name;
  action.description = ExplosivePunchClientAction.description;
  action.minimumRequiredStamina = 5;
  action.latestActivationTimes = {0, 0};
  action.explosiveParts = {};

  local character = action.contestant.character;
  assert(character, "Character required");
  local humanoid = character:FindFirstChild("Humanoid");
  assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");
  local isHumanoidR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
  local leftHand = character:FindFirstChild(if isHumanoidR15 then "LeftHand" else "LeftArm");
  local rightHand = character:FindFirstChild(if isHumanoidR15 then "RightHand" else "RightArm");
  for _, hand in ipairs({leftHand, rightHand}) do

    if hand and hand:IsA("BasePart") then

      local explosivePart = Instance.new("Part");
      explosivePart.Name = `{hand.Name}ExplosivePart`;
      explosivePart.CanCollide = false;
      explosivePart.Size = Vector3.new(1, 1, 1);
      explosivePart.Transparency = 1;
      explosivePart.Position = hand.CFrame.Position - (if not isHumanoidR15 then Vector3.new(0, hand.Size.Y / 2 + explosivePart.Size.Y / 2, 0) else Vector3.new(0, 1.5, 0));

      local explosiveWeldConstraint = Instance.new("WeldConstraint");
      explosiveWeldConstraint.Part0 = explosivePart;
      explosiveWeldConstraint.Part1 = hand;
      explosiveWeldConstraint.Parent = explosivePart;

      explosivePart.Parent = action.contestant.character;

      table.insert(action.explosiveParts, explosivePart);

    end;

  end;

  local player = action.contestant.player;
  if player then

    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{action.contestant.id}_{action.id}`, function()
    
      action:activate();

    end);
    
    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

function ExplosivePunchServerAction.__index:activate()

  -- Verify that actions aren't locked.
  assertContestantIsNotActionLocked(self.contestant);

  -- Ensure the contestant has enough stamina.
  assert(self.contestant.currentStamina >= self.minimumRequiredStamina, "Contestant doesn't have enough stamina.");
  self.contestant:updateStamina(math.max(self.contestant.currentStamina - self.minimumRequiredStamina, 0), {
    actionID = self.id;
  });

  -- Run the animation.
  local humanoid = if self.contestant.character then self.contestant.character:FindFirstChild("Humanoid") else nil;
  local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;
  assert(animator and animator:IsA("Animator"), "Animator not found");

  local punchAnimation = Instance.new("Animation");
  local shouldUseRightPunch = self.latestActivationTimes[1] > DateTime.now().UnixTimestampMillis - 500;
  local shouldUseBothArms = shouldUseRightPunch and self.latestActivationTimes[1] - self.latestActivationTimes[2] <= 500;
  punchAnimation.AnimationId = `rbxassetid://{if shouldUseBothArms then "17783699843" elseif shouldUseRightPunch then "17759014502" else "17758265394"}`;
  if self.currentAnimationTrack then self.currentAnimationTrack:Stop(0) end; 
  local currentAnimationTrack = animator:LoadAnimation(punchAnimation);
  self.currentAnimationTrack = currentAnimationTrack
  currentAnimationTrack:Play(0.025);

  local function activateExplosivePart(explosivePart: BasePart)

    local explosion = Instance.new("Explosion");
    explosion.BlastPressure = 0;
    explosion.BlastRadius = 5;
    explosion.DestroyJointRadiusPercent = 0;
    explosion.Position = explosivePart.Position;
    local hitContestants = {};
    explosion.Hit:Connect(function(basePart)

      -- Damage any parts or contestants that get hit.
      for _, possibleEnemyContestant in self.contestant.round.contestants do

        task.spawn(function()

          local possibleEnemyCharacter = possibleEnemyContestant.character;
          if possibleEnemyContestant ~= self.contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

            table.insert(hitContestants, possibleEnemyContestant);
            possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 50, {
              contestantID = self.contestant.id;
              actionID = ExplosivePunchServerAction.id;
            });

          end;

        end);

      end;
      
      local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
      if basePartCurrentDurability and basePartCurrentDurability > 0 then

        ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, {
          contestantID = self.contestant.id;
        });

      end;

    end);
    explosion.Parent = explosivePart;

  end;
 
  if shouldUseBothArms then

    self.latestActivationTimes = {0, 0};
    task.wait(0.1);
    activateExplosivePart(self.explosiveParts[1]);
    activateExplosivePart(self.explosiveParts[2]);

  else 

    table.insert(self.latestActivationTimes, 1, DateTime.now().UnixTimestampMillis);
    self.latestActivationTimes[3] = nil;
    task.wait(0.1);
    local explosivePart = self.explosiveParts[if shouldUseRightPunch then 2 else 1];
    activateExplosivePart(explosivePart);    

  end;
  
end;

function ExplosivePunchServerAction.__index:breakdown()

  for _, explosivePart in self.explosiveParts do

    explosivePart:Destroy();

  end;

  if self.remoteFunction then
    
    self.remoteFunction:Destroy();

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(self.contestant.player, self.id);

  end;
  
end;

return ExplosivePunchServerAction;
