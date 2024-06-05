--!strict
local Archetype = require(script.Parent.Parent.Archetype);
type Archetype = Archetype.Archetype;
local ExplosiveMimicArchetype = {
  ID = 1;
  name = "Explosive Mimic";
  description = "You're the bomb! No, seriously. Your limbs are explosive, but don't worry: you regenerate them. You can also cause explosions with your hands and feet!";
  actionIDs = {1, 2, 3, 4};
};
function ExplosiveMimicArchetype.new(): Archetype

  local function breakdown(self: Archetype)

  end;

  -- Set up the self-destruct.
  -- contestant.onDisqualified:Connect(function()

    -- if contestant.character then

      -- Make the player progressively grow white for 3 seconds.
      -- task.spawn(function()

        -- local highlight = Instance.new("Highlight");
        -- highlight.Parent = contesta

      -- end)

      -- After the 3 seconds, produce a large explosion at the player's location.
      -- task.delay(3, function()
    
      -- );
      
    -- end;

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