--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local DetachLimbClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetachLimbClientAction);
local types = require(ServerStorage.Modules.types);

local assertContestantIsNotActionLocked = require(ServerStorage.Modules.assertContestantIsNotActionLocked);
local createInventoryRemoteFunction = require(ServerStorage.Modules.createInventoryRemoteFunction);
local removeDetachLimbBaseModifiers = require(ServerStorage.Modules.removeDetachLimbBaseModifiers);

local DetachLimbServerAction = {
  id = DetachLimbClientAction.id;
  name = DetachLimbClientAction.name;
  description = DetachLimbClientAction.description;
  __index = {} :: types.DetachLimbServerAction;
};

function DetachLimbServerAction.new(properties: types.ServerActionConstructorProperties): types.DetachLimbServerAction

  local overwrittenProperties = {
    id = DetachLimbServerAction.id;
    name = DetachLimbServerAction.name;
    description = DetachLimbServerAction.description;
    contestant = properties.contestant;
    detachedLimbs = {};
    bindableFunction = Instance.new("BindableFunction");
  };
  
  local action = (setmetatable(overwrittenProperties, DetachLimbServerAction) :: any) :: types.DetachLimbServerAction;

  action.bindableFunction.Name = `{action.contestant.id}_GetDetachedLimbs`;
  action.bindableFunction.OnInvoke = function()

    return action.detachedLimbs;

  end;
  action.bindableFunction.Parent = ServerStorage.Functions.ActionFunctions;

  -- Create a remote function.
  if action.contestant.player then
    
    action.remoteFunction = createInventoryRemoteFunction(action.contestant.player, "Action", `{action.contestant.player.UserId}_{action.id}`, function(player: Player, limbName: string)

      assert(typeof(limbName) == "string", "Limb name must be a string");

      action:activate(limbName);

    end);

  end;

  return action;

end;

function DetachLimbServerAction.__index:activate(limbName: string?)

  -- Verify that actions aren't locked.
  assertContestantIsNotActionLocked(self.contestant);

  -- Verify variable types to maintain server security.
  local validLimbNames = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"};
  assert(typeof(limbName) == "string", "Limb name must be a string.");
  assert(table.find(validLimbNames, limbName), "Limb name is invalid.");
  
  -- Make the cloned limb look like the player's limb.
  local character = self.contestant.character;
  assert(character, `Contestant {self.contestant.id} doesn't have a character.`);

  local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?;
  assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {self.contestant.id}'s humanoid.`);

  local function toggleLimbHighlight(limb: BasePart, isEnabled: boolean)

    if isEnabled then

      limb.Transparency = 0.7;
      local highlight = Instance.new("Highlight");
      highlight.FillColor = Color3.new(1, 1, 1);
      highlight.FillTransparency = 0.8;
      highlight.OutlineColor = Color3.new(1, 1, 1);
      highlight.OutlineTransparency = 0.65;
      highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
      highlight.Parent = limb;

    else

      limb.Transparency = 0;
      local highlight = limb:FindFirstChild("Highlight");
      if highlight then

        highlight:Destroy();

      end;

    end;

  end;

  local primaryLimbClone;
  if humanoid.RigType == Enum.HumanoidRigType.R15 and limbName ~= "Head" then
    
    local cloneLimbContainer = Instance.new("Model");
    cloneLimbContainer.Name = `{self.contestant.id}_ExplosiveLimb_{limbName}`;

    local realLimbs: {BasePart} = {};
    if limbName == "Torso" then

      local upper = character:FindFirstChild("UpperTorso") :: BasePart;
      local lower = character:FindFirstChild("LowerTorso") :: BasePart;
      local upperClone = upper:Clone();
      upperClone.CanCollide = true;
      local lowerClone = lower:Clone();
      lowerClone.CanCollide = true;
      local upperMotor6D = upperClone:FindFirstChild("Waist") :: Motor6D;
      upperMotor6D.Part0 = lowerClone;
      upperMotor6D.Part1 = upperClone;

      local lowerMotor6D = lowerClone:FindFirstChild("Root") :: Motor6D;
      lowerMotor6D:Destroy();
      
      realLimbs = {upper, lower};

      upperClone.Parent = cloneLimbContainer;
      lowerClone.Parent = cloneLimbContainer;
      
      cloneLimbContainer.PrimaryPart = upperClone;
      primaryLimbClone = upperClone;

    else
      
      -- Connect the fake limbs together.
      local majorLimbName = limbName:sub(limbName:len() - 2);
      local direction = if limbName:sub(1, 4) == "Left" then "Left" else "Right";
      local upper = character:FindFirstChild(`{direction}Upper{majorLimbName}`) :: BasePart;
      local lower = character:FindFirstChild(`{direction}Lower{majorLimbName}`) :: BasePart;
      local ending = character:FindFirstChild(direction .. if majorLimbName == "Arm" then "Hand" else "Foot") :: BasePart;

      local upperClone = upper:Clone();
      upperClone.CanCollide = true;
      upperClone.Parent = cloneLimbContainer;

      local upperMotor6D = upperClone:FindFirstChild(direction .. if majorLimbName == "Arm" then "Shoulder" else "Hip") :: Motor6D;
      upperMotor6D:Destroy();

      local lowerClone = lower:Clone();
      lowerClone.CanCollide = true;
      lowerClone.Parent = cloneLimbContainer;

      local lowerMotor6D = lowerClone:FindFirstChild(direction .. if majorLimbName == "Arm" then "Elbow" else "Knee") :: Motor6D;
      lowerMotor6D.Part0 = upperClone;
      lowerMotor6D.Part1 = lowerClone;
      lowerMotor6D.Parent = lowerClone;

      local endingClone = ending:Clone();
      endingClone.CanCollide = true;
      endingClone.Parent = cloneLimbContainer;

      local endingMotor6D = endingClone:FindFirstChild(direction .. if majorLimbName == "Arm" then "Wrist" else "Ankle") :: Motor6D;
      endingMotor6D.Part0 = lowerClone;
      endingMotor6D.Part1 = endingClone;
      endingMotor6D.Parent = endingClone;

      realLimbs = {upper, lower, ending};
      cloneLimbContainer.PrimaryPart = upperClone;
      primaryLimbClone = upperClone;

    end;

    self.detachedLimbs[limbName] = cloneLimbContainer;

    -- Hide the real limbs.
    for _, limb in realLimbs do

      toggleLimbHighlight(limb, true);

    end;

    self.detachedLimbs[limbName].Destroying:Connect(function()
  
      for _, limb in realLimbs do

        toggleLimbHighlight(limb, false);

      end
      
      self.detachedLimbs[limbName] = nil;
      
    end);

    -- Show the fake limbs.
    cloneLimbContainer.Parent = workspace;

  else

    local realLimb = character:FindFirstChild(limbName) :: BasePart;
    assert(realLimb and realLimb:IsA("BasePart"), `Couldn't find {limbName}.`);

    local limbClone = realLimb:Clone() :: BasePart;
    limbClone.Name = `{self.contestant.id}_ExplosiveLimb_{limbClone.Name}`;
    limbClone.CanCollide = true;
    limbClone.Parent = workspace;

    local neck = limbClone:FindFirstChild("Neck");
    if neck then

      neck:Destroy();

    end;

    self.detachedLimbs[limbName] = limbClone;
    self.detachedLimbs[limbName].Destroying:Connect(function()
  
      toggleLimbHighlight(realLimb, false);
      self.detachedLimbs[limbName] = nil;
      
    end);

    -- Hide the real limb.
    toggleLimbHighlight(realLimb, true);

    primaryLimbClone = limbClone;

  end;

  -- Allow players to pick up the limb.
  local proximityPrompt = Instance.new("ProximityPrompt");
  proximityPrompt.ActionText = "Pick up";
  proximityPrompt.MaxActivationDistance = 7;
  proximityPrompt.Triggered:Connect(function(holdingPlayer)
  
    -- Disable the proximity prompt so no one can steal it.
    proximityPrompt.Enabled = false;
    local monitorScriptProxy = Instance.new("ScreenGui");
    local monitoringScript = script.LimbHoldingMonitorScript:Clone();
    monitoringScript.Parent = monitorScriptProxy;
    monitorScriptProxy.Parent = holdingPlayer.PlayerGui;

    -- Attach the limb to the contestant's hand.
    local character = holdingPlayer.Character;
    local humanoid = if character then character:FindFirstChild("Humanoid") :: Humanoid else nil;
    assert(character and humanoid, "Humanoid not found");
    local isUsingR15 = humanoid.RigType == Enum.HumanoidRigType.R15;
    local handName = `Right{if isUsingR15 then "Hand" else "Arm"}`;
    local hand = character:FindFirstChild(handName) :: BasePart;
    assert(hand, `{handName} not found`);
    primaryLimbClone.CFrame = hand.CFrame;
    
    local weldConstraint = Instance.new("WeldConstraint");
    weldConstraint.Part0 = hand;
    weldConstraint.Part1 = primaryLimbClone;
    weldConstraint.Parent = primaryLimbClone;

    monitoringScript.RemoteEvent.OnServerEvent:Connect(function(throwingPlayer: Player, targetPosition: Vector3)
    
      if holdingPlayer == throwingPlayer then

        monitorScriptProxy:Destroy();

        local parent = primaryLimbClone.Parent;
        local focusParts = if parent and parent:IsA("Model") and not parent:IsA("Workspace") then parent:GetChildren() else {primaryLimbClone};
        for _, part in ipairs(focusParts) do

          for _, throwerPart in ipairs(character:GetChildren()) do

            if throwerPart:IsA("BasePart") and throwerPart.CanCollide then

              local constraint = Instance.new("NoCollisionConstraint");
              constraint.Part0 = part;
              constraint.Part1 = throwerPart;
              constraint.Parent = part;
              task.delay(1, function()
              
                constraint:Destroy();

              end);

            end;

          end;

        end;
        
        assert(typeof(targetPosition) == "Vector3", "Mouse position must be a Vector3");
        weldConstraint:Destroy();

        local currentPosition = primaryLimbClone.Position;
        local direction = targetPosition - currentPosition;
        local clampedDirection = direction.Unit * math.min(direction.Magnitude, 5);
        local duration = math.log(1.001 + clampedDirection.Magnitude * 0.01);
        local force = clampedDirection / duration * Vector3.new(1, workspace.Gravity * 0.5 * duration, 1);
        primaryLimbClone:ApplyImpulse(force * primaryLimbClone.AssemblyMass);
        proximityPrompt.Enabled = true;

      end;

    end);

  end)
  proximityPrompt.Parent = primaryLimbClone;
  
  -- Make the player take damage.
  self.contestant:addBaseModifier("Health", {
    delta = -19;
    cause = {
      actionID = self.ID;
    };
  });

end;

function DetachLimbServerAction.__index:breakdown()

  self.bindableFunction:Destroy();

  for _, detachedLimb in pairs(self.detachedLimbs) do

    detachedLimb:Destroy();

  end;

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

  removeDetachLimbBaseModifiers(self.contestant);

end;

return DetachLimbServerAction;
