--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local ExplosivePunchClientAction = require(ReplicatedStorage.Client.Classes.Actions.ExplosivePunchClientAction);
local IExplosivePunchServerAction = require(ServerStorage.Interfaces.IExplosivePunchServerAction);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local IServerRound = require(ServerStorage.Interfaces.IServerRound);

local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);

type IExplosivePunchServerAction = IExplosivePunchServerAction.IExplosivePunchServerAction;
type IServerContestant = IServerContestant.IServerContestant;
type IServerRound = IServerRound.IServerRound;

local ExplosivePunchServerAction = {
  id = ExplosivePunchClientAction.id;
  name = ExplosivePunchClientAction.name;
  description = ExplosivePunchClientAction.description;
};

function ExplosivePunchServerAction.new(contestant: IServerContestant, round: IServerRound): IExplosivePunchServerAction
  
  local currentAnimationTrack: AnimationTrack = nil;
  local minimumRequiredStamina = 5;
  local latestActivationTimes = {0, 0};
  local explosiveParts: {BasePart} = {};

  local function activate(self: IExplosivePunchServerAction)

    -- Verify that actions aren't locked.
    assertContestantIsNotActionLocked(contestant);
  
    -- Ensure the contestant has enough stamina.
    assert(contestant.currentStamina >= minimumRequiredStamina, "Contestant doesn't have enough stamina.");
    contestant:setCurrentStamina(math.max(contestant.currentStamina - minimumRequiredStamina, 0), {
      contestantID = contestant.id;
      actionID = self.id;
    });
  
    -- Run the animation.
    local humanoid = if contestant.character then contestant.character:FindFirstChild("Humanoid") else nil;
    local animator = if humanoid then humanoid:FindFirstChild("Animator") else nil;
    assert(animator and animator:IsA("Animator"), "Animator not found");
  
    local punchAnimation = Instance.new("Animation");
    local shouldUseRightPunch = latestActivationTimes[1] > DateTime.now().UnixTimestampMillis - 500;
    local shouldUseBothArms = shouldUseRightPunch and latestActivationTimes[1] - latestActivationTimes[2] <= 500;
    punchAnimation.AnimationId = `rbxassetid://{if shouldUseBothArms then "17783699843" elseif shouldUseRightPunch then "17759014502" else "17758265394"}`;
    if currentAnimationTrack then currentAnimationTrack:Stop(0) end; 
    local currentAnimationTrack = animator:LoadAnimation(punchAnimation);
    currentAnimationTrack = currentAnimationTrack
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
        for _, possibleEnemyContestant in round:getContestants() do
  
          task.spawn(function()
  
            local possibleEnemyCharacter = possibleEnemyContestant.character;
            if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then
  
              table.insert(hitContestants, possibleEnemyContestant);
              possibleEnemyContestant:setCurrentHealth(possibleEnemyContestant.currentHealth - 50, {
                contestantID = contestant.id;
                actionID = self.id;
              });
  
            end;
  
          end);
  
        end;
        
        local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
        if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
          ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, {
            contestantID = contestant.id;
            actionID = self.id;
          });
  
        end;
  
      end);
      explosion.Parent = explosivePart;
  
    end;
   
    if shouldUseBothArms then
  
      latestActivationTimes = {0, 0};
      task.wait(0.1);
      activateExplosivePart(explosiveParts[1]);
      activateExplosivePart(explosiveParts[2]);
  
    else 
  
      table.insert(latestActivationTimes, 1, DateTime.now().UnixTimestampMillis);
      latestActivationTimes[3] = nil;
      task.wait(0.1);
      local explosivePart = explosiveParts[if shouldUseRightPunch then 2 else 1];
      activateExplosivePart(explosivePart);    
  
    end;
    
  end;

  local function breakdown(self: IExplosivePunchServerAction)

    for _, explosivePart in explosiveParts do
  
      explosivePart:Destroy();
  
    end;
  
    if self.remoteFunction then
      
      self.remoteFunction:Destroy();
  
    end;
  
    if contestant.player then
  
      ReplicatedStorage.Shared.Functions.BreakdownAction:InvokeClient(contestant.player, self.id);
  
    end;
    
  end;
  
  local action: IExplosivePunchServerAction = {
    attributes = {};
    contestantID = contestant.id;
    description = ExplosivePunchClientAction.description;
    id = ExplosivePunchClientAction.id;
    name = ExplosivePunchClientAction.name;
    activate = activate;
    breakdown = breakdown;
  }

  local character = contestant.character;
  assert(character, "Character required");

  local humanoid = character:FindFirstChild("Humanoid");
  assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");

  local isHumanoidR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
  local leftHand = character:FindFirstChild(if isHumanoidR15 then "LeftHand" else "LeftArm");
  local rightHand = character:FindFirstChild(if isHumanoidR15 then "RightHand" else "RightArm");
  for _, hand in {leftHand, rightHand} do

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

      explosivePart.Parent = contestant.character;

      table.insert(explosiveParts, explosivePart);

    end;

  end;

  local player = contestant.player;
  if player then

    action.remoteFunction = createInventoryRemoteFunction(player, "Action", `{contestant.id}_{action.id}`, function()
    
      action:activate();

    end);
    
    ReplicatedStorage.Shared.Functions.InitializeAction:InvokeClient(player, action.id);

  end;

  return action;

end;

return ExplosivePunchServerAction;
