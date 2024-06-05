--!strict
local TweenService = game:GetService("TweenService");
local Archetype = require(script.Parent.Parent.Archetype);
local Contestant = require(script.Parent.Parent.Contestant);
type Contestant = Contestant.Contestant;
type Archetype = Archetype.Archetype;
local ExplosiveMimicArchetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "You're the bomb! No, seriously. Your limbs are explosive, but don't worry: you regenerate them. You can also cause explosions with your hands and feet!";
  actionIDs = {1, 2, 3, 4};
};
function ExplosiveMimicArchetype.new(contestant: Contestant): Archetype

  local function breakdown(self: Archetype)

  end;

  -- Set up the self-destruct.
  -- contestant.onDisqualified:Connect(function()

  --   if contestant.character then

  --     -- Make the player progressively grow white for 3 seconds.
  --     task.spawn(function()

  --       local highlight = Instance.new("Highlight");
  --       highlight.FillTransparency = 1;
  --       highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
  --       highlight.FillColor = Color3.new(1, 1, 1);
  --       highlight.Parent = contestant.character;
  --       local tween = TweenService:Create(highlight, TweenInfo.new(3), {FillTransparency = 0});
  --       tween.Completed:Connect(function()
        
  --         -- Engulf the player in an explosion.

  --       end);

  --     end)

  --   end;

  -- end)

  return Archetype.new({
    ID = ExplosiveMimicArchetype.ID;
    name = ExplosiveMimicArchetype.name;
    description = ExplosiveMimicArchetype.description;
    actionIDs = ExplosiveMimicArchetype.actionIDs;
    type = "Destroyer";
    breakdown = breakdown;
  });

end;

return ExplosiveMimicArchetype;