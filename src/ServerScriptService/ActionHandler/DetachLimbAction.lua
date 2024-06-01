--!strict
local ServerScriptService = game:GetService("ServerScriptService");
local DetachLimbAction = {};

local validLimbNames = {"Head", "LeftArm", "RightArm", "LeftLeg", "RightLeg"};

function DetachLimbAction:execute(player: Player, limbName: string?)

  -- Verify variable types to maintain server security.
  assert(typeof(limbName) == "string", "Limb name must be a string.");
  assert(table.find(validLimbNames, limbName), "Limb name is invalid.");
  
  -- Make the cloned limb look like the player's limb.
  local character = player.Character;
  assert(character, `{player.Name} doesn't have a character.`);

  local realLimb = character:FindFirstChild(limbName);
  assert(typeof(realLimb) == "BasePart", `Couldn't find {limbName}.`);

  local limbClone = realLimb:Clone() :: BasePart;
  limbClone.Name = `{player.Name}_Explosive{limbClone.Name}`;
  limbClone.CanCollide = true;
  limbClone.Parent = workspace;

  -- Hide the real limb.
  realLimb.Transparency = 1;

  -- Make the player take damage.
  local humanoid = character:FindFirstChild("Humanoid");
  assert(typeof(humanoid) == "Humanoid", "Humanoid not found.");
  humanoid.Health -= 10;

  -- Destroy the limb after the round ends.
  ServerScriptService.MatchManagementScript.AddDebris:Invoke(limbClone);

  -- Return the explosive limb's name.
  return limbClone.Name;

end;

return DetachLimbAction;