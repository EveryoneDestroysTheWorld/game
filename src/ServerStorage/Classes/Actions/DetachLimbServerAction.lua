--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local DetachLimbClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetachLimbClientAction);

local DetachLimbServerAction = {
  ID = DetachLimbClientAction.ID;
  name = DetachLimbClientAction.name;
  description = DetachLimbClientAction.description;
};

function DetachLimbServerAction.new(contestant: ServerContestant): ServerAction
  
  local validLimbNames = {"Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"};

  local action: ServerAction;

  local function activate(self: ServerAction, limbName: string?)

    -- Verify variable types to maintain server security.
    assert(typeof(limbName) == "string", "Limb name must be a string.");
    assert(table.find(validLimbNames, limbName), "Limb name is invalid.");
    
    -- Make the cloned limb look like the player's limb.
    local character = contestant.character;
    assert(character, `Contestant {contestant.ID} doesn't have a character.`);

    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?;
    assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.ID}'s humanoid.`);

    local function highlightRealLimb(limb: BasePart)

      limb.Transparency = 0.7;
      local highlight = Instance.new("Highlight");
      highlight.FillColor = Color3.new(1, 1, 1);
      highlight.FillTransparency = 0.8;
      highlight.OutlineColor = Color3.new(1, 1, 1);
      highlight.OutlineTransparency = 0.65;
      highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
      highlight.Parent = limb;

    end;

    if humanoid.RigType == Enum.HumanoidRigType.R15 and limbName ~= "Head" then

      local realLimbs = {};
      local cloneLimbs = {};
      if limbName == "Torso" then

        local upper = character:FindFirstChild("UpperTorso") :: BasePart;
        local lower = character:FindFirstChild("LowerTorso") :: BasePart;
        local upperClone = upper:Clone();
        local lowerClone = lower:Clone();
        local upperMotor6D = upperClone:FindFirstChild("Waist") :: Motor6D;
        upperMotor6D.Part0 = lowerClone;
        upperMotor6D.Part1 = upperClone;

        local lowerMotor6D = lowerClone:FindFirstChild("Root") :: Motor6D;
        lowerMotor6D:Destroy();

        upperClone.Parent = workspace;
        lowerClone.Parent = workspace;
        
        realLimbs = {upper, lower};
        cloneLimbs = {upperClone, lowerClone};

      else
        
        -- Connect the fake limbs together.
        local majorLimbName = limbName:sub(limbName:len() - 2);
        local direction = if limbName:sub(1, 4) == "Left" then "Left" else "Right";
        local upper = character:FindFirstChild(`{direction}Upper{majorLimbName}`) :: BasePart;
        local lower = character:FindFirstChild(`{direction}Lower{majorLimbName}`) :: BasePart;
        local ending = character:FindFirstChild(direction .. if majorLimbName == "Arm" then "Hand" else "Foot") :: BasePart;

        local upperClone = upper:Clone();
        local upperMotor6D = upperClone:FindFirstChild(direction .. if majorLimbName == "Arm" then "Shoulder" else "Hip") :: Motor6D;
        upperMotor6D:Destroy();

        local lowerClone = lower:Clone();
        local lowerMotor6D = lowerClone:FindFirstChild(direction .. if majorLimbName == "Arm" then "Elbow" else "Knee") :: Motor6D;
        lowerMotor6D.Part0 = upperClone;
        lowerMotor6D.Part1 = lowerClone;
        lowerMotor6D.Parent = lowerClone;

        local endingClone = ending:Clone();
        local endingMotor6D = endingClone:FindFirstChild(direction .. if majorLimbName == "Arm" then "Wrist" else "Ankle") :: Motor6D;
        endingMotor6D.Part0 = lowerClone;
        endingMotor6D.Part1 = endingClone;
        endingMotor6D.Parent = endingClone;

        realLimbs = {upper, lower, ending};
        cloneLimbs = {upperClone, lowerClone, endingClone};

      end;

      -- Hide the real limbs.
      for _, limb in ipairs(realLimbs) do

        highlightRealLimb(limb);

      end;

      -- Show the fake limbs.
      for _, clone in ipairs(cloneLimbs) do

        clone.Name = `{contestant.ID}ExplosiveLimb{clone.Name}`;
        clone.CanCollide = true;
        clone.Parent = workspace;
        -- ServerScriptService.MatchManagementScript.AddDebris:Invoke(clone);

      end;

    else

      local realLimb = character:FindFirstChild(limbName) :: BasePart;
      assert(realLimb and realLimb:IsA("BasePart"), `Couldn't find {limbName}.`);
  
      local limbClone = realLimb:Clone() :: BasePart;
      limbClone.Name = `{contestant.ID}ExplosiveLimb{limbClone.Name}`;
      limbClone.CanCollide = true;
      limbClone.Parent = workspace;

      local neck = limbClone:FindFirstChild("Neck");
      if neck then

        neck:Destroy();

      end;
  
      -- Hide the real limb.
      highlightRealLimb(realLimb);
  
      -- Destroy the limb after the round ends.
      -- ServerScriptService.MatchManagementScript.AddDebris:Invoke(limbClone);

    end;
    
    -- Make the player take damage.
    humanoid.MaxHealth -= 19;

  end;

  local remoteFunction: RemoteFunction?;
  local function breakdown()

    if remoteFunction then

      remoteFunction:Destroy();

    end;

  end;

  action = ServerAction.new({
    ID = DetachLimbServerAction.ID;
    name = DetachLimbServerAction.name;
    description = DetachLimbServerAction.description;
    activate = activate;
    breakdown = breakdown;
  });

  -- Create a remote function.
  if contestant.player then
    
    local actionRemoteFunction = Instance.new("RemoteFunction");
    actionRemoteFunction.Name = `{contestant.player.UserId}_{action.ID}`;
    actionRemoteFunction.OnServerInvoke = function(player, limbName: string)

      assert(typeof(limbName) == "string", "Limb name must be a string");  

      if player == contestant.player then

        action:activate(limbName);

      else

        -- That's weird.
        error("Unauthorized.");

      end

    end;
    actionRemoteFunction.Parent = ReplicatedStorage.Shared.Functions.ActionFunctions;
    remoteFunction = actionRemoteFunction;

  end;

  return action;

end;

return DetachLimbServerAction;
