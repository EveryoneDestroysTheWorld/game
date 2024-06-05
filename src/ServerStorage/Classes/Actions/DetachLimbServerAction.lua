--!strict
local ServerScriptService = game:GetService("ServerScriptService");
local validLimbNames = {"Head", "LeftArm", "RightArm", "LeftLeg", "RightLeg"};

return function(player: Player, limbName: string?)

  -- Verify variable types to maintain server security.
  assert(typeof(limbName) == "string", "Limb name must be a string.");
  assert(table.find(validLimbNames, limbName), "Limb name is invalid.");
  
  -- Make the cloned limb look like the player's limb.
  local character = player.Character;
  assert(character, `{player.Name} doesn't have a character.`);

  local realLimb = character:FindFirstChild(limbName);
  assert(realLimb and realLimb:IsA("BasePart"), `Couldn't find {limbName}.`);

  local limbClone = realLimb:Clone() :: BasePart;
  limbClone.Name = `{player.Name}_ExplosiveLimb_{limbClone.Name}`;
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