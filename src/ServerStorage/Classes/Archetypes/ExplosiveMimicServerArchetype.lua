--!strict

local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

local ExplosiveMimicClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.ExplosiveMimicClientArchetype);

local downContestant = require(ServerStorage.Modules.downContestant);

local types = require(ServerStorage.Classes.types);

local ExplosiveMimicServerArchetype = {
  id = ExplosiveMimicClientArchetype.id;
  name = ExplosiveMimicClientArchetype.name;
  description = ExplosiveMimicClientArchetype.description;
  actionIDs = ExplosiveMimicClientArchetype.actionIDs;
  type = ExplosiveMimicClientArchetype.type;
  __index = {} :: types.ExplosiveMimicServerArchetype;
};

function ExplosiveMimicServerArchetype.new(properties: types.ExplosiveMimicServerArchetypeConstructorProperties): types.ExplosiveMimicServerArchetype

  local overwrittenProperties = {
    id = ExplosiveMimicServerArchetype.id;
    name = ExplosiveMimicServerArchetype.name;
    description = ExplosiveMimicServerArchetype.description;
    actionIDs = ExplosiveMimicServerArchetype.actionIDs;
    type = ExplosiveMimicServerArchetype.type;
    round = properties.round;
    contestant = properties.contestant;
    events = {};
  };

  local archetype = (setmetatable(overwrittenProperties, ExplosiveMimicServerArchetype) :: any) :: types.ExplosiveMimicServerArchetype;

  if archetype.contestant.player then

    task.spawn(function()
    
      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(archetype.contestant.player, archetype.id);

    end);

  end;

  -- Set up the self-destruct.
  local isExploding = false;
  table.insert(archetype.events, archetype.contestant.onHealthUpdated:Connect(function()

    if not isExploding and archetype.contestant.currentHealth <= 0 and archetype.contestant.character then

      -- Make the player progressively grow white for 3 seconds.
      isExploding = true;
      local highlight = Instance.new("Highlight");
      highlight.FillTransparency = 1;
      highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
      highlight.FillColor = Color3.new(1, 1, 1);
      highlight.Parent = archetype.contestant.character;
      
      local humanoid = archetype.contestant.character:FindFirstChild("Humanoid") :: Humanoid?;
      local changedEvent;
      if humanoid and humanoid:IsA("Humanoid") then

        local humanoidDescription = humanoid:GetAppliedDescription();
        local sizeTween = TweenService:Create(humanoidDescription, TweenInfo.new(2.5), {
          DepthScale = humanoidDescription.DepthScale * 1.5;
          WidthScale = humanoidDescription.WidthScale * 1.5;
          HeightScale = humanoidDescription.HeightScale * 1.5;
          HeadScale = humanoidDescription.HeadScale * 1.5;
        });
        changedEvent = humanoidDescription.Changed:Connect(function()
        
          humanoid:ApplyDescription(humanoidDescription);

        end);
        sizeTween.Completed:Connect(function()
        
          changedEvent:Disconnect();

        end);
        sizeTween:Play();

      end;

      local tween = TweenService:Create(highlight, TweenInfo.new(3), {FillTransparency = 0});
      tween.Completed:Connect(function()
      
        -- Engulf the player in an explosion.
        local primaryPart = archetype.contestant.character.PrimaryPart;
        assert(primaryPart, "PrimaryPart not found.");

        local explosion = Instance.new("Explosion");
        explosion.BlastPressure = 50000;
        explosion.BlastRadius = 20;
        explosion.DestroyJointRadiusPercent = 0;
        explosion.Position = primaryPart.CFrame.Position - Vector3.new(0, 5, 0);
        local hitContestants = {};
        explosion.Hit:Connect(function(basePart)
  
          -- Damage any parts or contestants that get hit.
          for _, possibleEnemyContestant in archetype.round.contestants do

            task.spawn(function()

              local possibleEnemyCharacter = possibleEnemyContestant.character;
              if possibleEnemyContestant ~= archetype.contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                table.insert(hitContestants, possibleEnemyContestant);
                possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 50, {
                  contestantID = archetype.contestant.id;
                  archetypeID = ExplosiveMimicServerArchetype.id;
                });

              end;

            end);

          end;

          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
          if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 100, {
              contestantID = archetype.contestant.id;
            });
  
          end;
  
        end);

        if humanoid and humanoid:IsA("Humanoid") and changedEvent then

          local humanoidDescription = humanoid:GetAppliedDescription();
          humanoidDescription.DepthScale *= 0.75;
          humanoidDescription.WidthScale *= 0.75;
          humanoidDescription.HeightScale *= 0.75;
          humanoidDescription.HeadScale *= 0.75;
          humanoid:ApplyDescription(humanoidDescription);
          humanoid.AutomaticScalingEnabled = false;
          
          for _, part in archetype.contestant.character:GetDescendants() do

            if part:IsA("BasePart") then

              part:SetNetworkOwner();

            end;

          end;
          changedEvent:Disconnect();

          downContestant(archetype.contestant);

        end;

        explosion.Parent = workspace;
        highlight:Destroy();

      end);

      tween:Play();

    end;

  end));

  return archetype;

end;

function ExplosiveMimicServerArchetype.__index:breakdown()

  for _, event in self.events do

    event:Disconnect();

  end;

end;

return ExplosiveMimicServerArchetype;