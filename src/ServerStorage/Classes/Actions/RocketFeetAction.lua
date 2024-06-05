--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local Contestant = require(script.Parent.Parent.Contestant);
type Contestant = Contestant.Contestant;

local contestantExecutionTimes: {[Contestant]: number} = {};
return function(contestant: Contestant)

  if contestant.character then

    if contestantExecutionTimes[contestant] and contestantExecutionTimes[contestant] > DateTime.now().UnixTimestampMillis - 500 then

      -- Activate rockets under the contestant's feet.


    else

      -- Produce an explosion under the contestant's feet.
      local primaryPart = contestant.character.PrimaryPart;
      assert(primaryPart, "PrimaryPart not found.");

      local explosion = Instance.new("Explosion");
      explosion.BlastPressure = 5000000;
      explosion.BlastRadius = 20;
      explosion.DestroyJointRadiusPercent = 0;
      explosion.Position = primaryPart.CFrame.Position - Vector3.new(0, 5, 0);
      explosion.Hit:Connect(function(basePart)
      
        -- Make sure the part isn't a part of the player.

        -- Damage any parts or contestants that get hit.
        local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
        if basePartCurrentDurability and basePartCurrentDurability > 0 then

          ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 35, contestant);

        end;

      end);
      explosion.Parent = workspace;

    end;

    contestantExecutionTimes[contestant] = DateTime.now().UnixTimestampMillis;

  end;

end;