--!strict
local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
local ExplosiveMimicClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.ExplosiveMimicClientArchetype);

local ExplosiveMimicServerArchetype = {
  ID = ExplosiveMimicClientArchetype.ID;
  name = ExplosiveMimicClientArchetype.name;
  description = ExplosiveMimicClientArchetype.description;
  actionIDs = ExplosiveMimicClientArchetype.actionIDs;
  type = ExplosiveMimicClientArchetype.type;
};

function ExplosiveMimicServerArchetype.new(contestant: ServerContestant): ServerArchetype

  -- Set up the self-destruct.
  local disqualificationEvent = contestant.onDisqualified:Connect(function()

    if contestant.character then

      -- Make the player progressively grow white for 3 seconds.
      local highlight = Instance.new("Highlight");
      highlight.FillTransparency = 1;
      highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
      highlight.FillColor = Color3.new(1, 1, 1);
      highlight.Parent = contestant.character;
      
      local tween = TweenService:Create(highlight, TweenInfo.new(3), {FillTransparency = 0});
      tween.Completed:Connect(function()
      
        -- Engulf the player in an explosion.
        local primaryPart = contestant.character.PrimaryPart;
        assert(primaryPart, "PrimaryPart not found.");

        local explosion = Instance.new("Explosion");
        explosion.BlastPressure = 5000000;
        explosion.BlastRadius = 40;
        explosion.DestroyJointRadiusPercent = 0;
        explosion.Position = primaryPart.CFrame.Position - Vector3.new(0, 5, 0);
        explosion.Hit:Connect(function(basePart)
  
          -- Damage any parts or contestants that get hit.
          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 100, contestant);
  
          end;
  
        end);
        explosion.Parent = workspace;
        highlight:Destroy();

      end);

      tween:Play();

    end;

  end)

  local function breakdown(self: ServerArchetype)

    disqualificationEvent:Disconnect();

  end;

  return ServerArchetype.new({
    ID = ExplosiveMimicServerArchetype.ID;
    name = ExplosiveMimicServerArchetype.name;
    description = ExplosiveMimicServerArchetype.description;
    actionIDs = ExplosiveMimicServerArchetype.actionIDs;
    type = ExplosiveMimicServerArchetype.type;
    breakdown = breakdown;
  });

end;

return ExplosiveMimicServerArchetype;