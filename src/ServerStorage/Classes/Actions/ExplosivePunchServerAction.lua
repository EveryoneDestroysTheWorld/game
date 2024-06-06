--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local ExplosivePunchClientAction = require(ReplicatedStorage.Client.Classes.Actions.ExplosivePunchClientAction);

local ExplosivePunchServerAction = {
  ID = ExplosivePunchClientAction.ID;
  name = ExplosivePunchClientAction.name;
  description = ExplosivePunchClientAction.description;
};

function ExplosivePunchServerAction.new(contestant: ServerContestant): ServerAction

  assert(contestant.character, "No character");

  -- Set up the explosive parts.
  local explosiveParts = {};
  local humanoid = contestant.character:FindFirstChild("Humanoid");
  assert(humanoid and humanoid:IsA("Humanoid"), "Couldn't find contestant's humanoid");

  local isHumanoidR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
  local leftHand = contestant.character:FindFirstChild(if isHumanoidR15 then "LeftHand" else "LeftArm");
  local rightHand = contestant.character:FindFirstChild(if isHumanoidR15 then "RightHand" else "RightArm");
  for _, hand in ipairs({leftHand, rightHand}) do

    if hand and hand:IsA("BasePart") then

      local explosivePart = Instance.new("Part");
      explosivePart.Name = `{hand.Name}ExplosivePart`;
      explosivePart.CanCollide = false;
      explosivePart.Size = Vector3.new(1, 1, 1);
      -- explosivePart.Transparency = 1;

      local explosiveWeldConstraint = Instance.new("WeldConstraint");
      explosiveWeldConstraint.Part0 = explosivePart;
      explosiveWeldConstraint.Part1 = hand;
      explosiveWeldConstraint.Parent = explosivePart;

      explosivePart.Position = hand.CFrame.Position - (if not isHumanoidR15 then Vector3.new(0, hand.Size.Y / 2 + explosivePart.Size.Y / 2, 0) else Vector3.new(0, 1.5, 0));
      explosivePart.Parent = contestant.character;

      table.insert(explosiveParts, explosivePart);

    end;

  end;

  local latestActivationTime = 0;
  local currentAnimationTrack = nil;
  local function activate(self: ServerAction)

    -- Run the animation.
    local animator = humanoid:FindFirstChild("Animator");
    assert(animator and animator:IsA("Animator"), "Animator not found");

    local punchAnimation = Instance.new("Animation");
    local shouldUseRightPunch = latestActivationTime > DateTime.now().UnixTimestampMillis - 500;
    punchAnimation.AnimationId = `rbxassetid://{if shouldUseRightPunch then "17758648029" else "17758265394"}`;
    if currentAnimationTrack then currentAnimationTrack:Stop(0.0001) end; 
    currentAnimationTrack = animator:LoadAnimation(punchAnimation);
    currentAnimationTrack:Play();
    latestActivationTime = if latestActivationTime == 0 then DateTime.now().UnixTimestampMillis else 0;
    task.wait(0.1);

    -- Start the
    local explosivePart = explosiveParts[if shouldUseRightPunch then 2 else 1];
    local explosion = Instance.new("Explosion");
    explosion.BlastPressure = 0;
    explosion.BlastRadius = 5;
    explosion.DestroyJointRadiusPercent = 0;
    explosion.Position = explosivePart.Position;
    explosion.Hit:Connect(function(basePart)

      -- Damage any parts or contestants that get hit.
      local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
      if basePartCurrentDurability and basePartCurrentDurability > 0 then

        ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, contestant);

      end;

    end);
    explosion.Parent = explosivePart;

  end;
  
  local actionRemoteFunction;
  
  local function breakdown()

    for _, explosivePart in ipairs(explosiveParts) do

      explosivePart:Destroy();

    end;

    if actionRemoteFunction then
      
      actionRemoteFunction:Destroy();

    end;
    
  end;

  local action = ServerAction.new({
    ID = ExplosivePunchServerAction.ID;
    name = ExplosivePunchServerAction.name;
    description = ExplosivePunchServerAction.description;
    activate = activate;
    breakdown = breakdown;
  });
  
  if contestant.player then
    
    actionRemoteFunction = Instance.new("RemoteFunction");
    actionRemoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
    actionRemoteFunction.OnServerInvoke = function(player)

      if player == contestant.player then

        action:activate();

      else

        -- That's weird.
        error("Unauthorized.");

      end

    end;
    actionRemoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;

  end;
  
  return action;

end;

return ExplosivePunchServerAction;