--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerAction = ServerAction.ServerAction;
local DetonateDetachedLimbsClientAction = require(ReplicatedStorage.Client.Classes.Actions.DetonateDetachedLimbsClientAction);

local DetonateDetachedLimbsServerAction = {
  ID = DetonateDetachedLimbsClientAction.ID;
  name = DetonateDetachedLimbsClientAction.name;
  description = DetonateDetachedLimbsClientAction.description;
};

function DetonateDetachedLimbsServerAction.new(contestant: ServerContestant): ServerAction

  local function activate()

    for _, limb in ipairs(ServerStorage.Functions.GetDetachedLimbs:Invoke(contestant)) do

      -- Use task.spawn so that they all explode at the same time.
      task.spawn(function()
        
        -- Create an explosion at the limb's location.
        local explosion = Instance.new("Explosion");
        explosion.BlastPressure = 5000000;
        explosion.BlastRadius = 20;
        explosion.DestroyJointRadiusPercent = 0;
        explosion.Position = limb.CFrame.Position;
        explosion.Hit:Connect(function(basePart)
  
          -- Damage any parts or contestants that get hit.
          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 25, contestant);
  
          end;
  
        end);
        explosion.Parent = workspace;
        limb:Destroy();

        if contestant.character then

          
          -- Add the limb and HP back to the player.
          local humanoid = contestant.character:FindFirstChild("Humanoid");
          assert(humanoid and humanoid:IsA("Humanoid"), `Couldn't find {contestant.character.Name}'s humanoid`);

          humanoid.MaxHealth += 19;

        end;

      end);

    end;

  end;

  local function breakdown()



  end;

  return ServerAction.new({
    name = DetonateDetachedLimbsServerAction.name;
    ID = DetonateDetachedLimbsServerAction.ID;
    description = DetonateDetachedLimbsServerAction.description;
    breakdown = breakdown;
    activate = activate;
  })

end;

return DetonateDetachedLimbsServerAction;