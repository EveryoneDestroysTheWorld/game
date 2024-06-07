--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerScriptService = game:GetService("ServerScriptService");
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
  
  local validLimbNames = {"Head", "LeftArm", "RightArm", "LeftLeg", "RightLeg"};

  local function activate(self: ServerAction, limbName: string?)

    -- Verify variable types to maintain server security.
    assert(typeof(limbName) == "string", "Limb name must be a string.");
    assert(table.find(validLimbNames, limbName), "Limb name is invalid.");
    
    -- Make the cloned limb look like the player's limb.
    local character = contestant.character;
    assert(character, `Contestant {contestant.ID} doesn't have a character.`);

    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid;
    assert(humanoid and humanoid:IsA("Model"), `Couldn't find {contestant.ID}'s humanoid.`);

    local realLimb = character:FindFirstChild(limbName);
    assert(realLimb and realLimb:IsA("BasePart"), `Couldn't find {limbName}.`);

    local limbClone = realLimb:Clone() :: BasePart;
    limbClone.Name = `{character.Name}_ExplosiveLimb_{limbClone.Name}`;
    limbClone.CanCollide = true;
    limbClone.Parent = workspace;

    -- Hide the real limb.
    realLimb.Transparency = 1;

    -- Make the player take damage.
    local humanoid = character:FindFirstChild("Humanoid");
    assert(humanoid and humanoid:IsA("Humanoid"), "Humanoid not found.");
    humanoid.MaxHealth -= 19;

    -- Destroy the limb after the round ends.
    ServerScriptService.MatchManagementScript.AddDebris:Invoke(limbClone);

    -- Return the explosive limb's name.
    return limbClone.Name;

  end;

  local function breakdown()

  end;

  return ServerAction.new({
    ID = DetachLimbServerAction.ID;
    name = DetachLimbServerAction.name;
    description = DetachLimbServerAction.description;
    activate = activate;
    breakdown = breakdown;
  })

end;

return DetachLimbServerAction;
