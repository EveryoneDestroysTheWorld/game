--!strict
local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
local ExplosiveMimicClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.ExplosiveMimicClientArchetype);
local Round = require(script.Parent.Parent.Round);
local ServerAction = require(script.Parent.Parent.ServerAction);
type Round = Round.Round;
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
type ServerAction = ServerAction.ServerAction;

local ExplosiveMimicServerArchetype = {
  ID = ExplosiveMimicClientArchetype.ID;
  name = ExplosiveMimicClientArchetype.name;
  description = ExplosiveMimicClientArchetype.description;
  actionIDs = ExplosiveMimicClientArchetype.actionIDs;
  type = ExplosiveMimicClientArchetype.type;
};

function ExplosiveMimicServerArchetype.new(contestant: ServerContestant, round: Round, stageModel: Model): ServerArchetype

  -- Set up the self-destruct.
  local disqualificationEvent = contestant.onDisqualified:Connect(function()

    if contestant.character then

      -- Make the player progressively grow white for 3 seconds.
      local highlight = Instance.new("Highlight");
      highlight.FillTransparency = 1;
      highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
      highlight.FillColor = Color3.new(1, 1, 1);
      highlight.Parent = contestant.character;
      
      local humanoid = contestant.character:FindFirstChild("Humanoid");
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

        end)
        sizeTween:Play();

      end;

      local tween = TweenService:Create(highlight, TweenInfo.new(3), {FillTransparency = 0});
      tween.Completed:Connect(function()
      
        -- Engulf the player in an explosion.
        local primaryPart = contestant.character.PrimaryPart;
        assert(primaryPart, "PrimaryPart not found.");

        local explosion = Instance.new("Explosion");
        explosion.BlastPressure = 50000;
        explosion.BlastRadius = 40;
        explosion.DestroyJointRadiusPercent = 0;
        explosion.Position = primaryPart.CFrame.Position - Vector3.new(0, 5, 0);
        local hitContestants = {};
        explosion.Hit:Connect(function(basePart)
  
          -- Damage any parts or contestants that get hit.
          for _, possibleEnemyContestant in ipairs(round.contestants) do

            task.spawn(function()

              local possibleEnemyCharacter = possibleEnemyContestant.character;
              if possibleEnemyContestant ~= contestant and not table.find(hitContestants, possibleEnemyContestant) and possibleEnemyCharacter and basePart:IsDescendantOf(possibleEnemyCharacter) then

                table.insert(hitContestants, possibleEnemyContestant);
                local enemyHumanoid = possibleEnemyCharacter:FindFirstChild("Humanoid");
                if enemyHumanoid then

                  enemyHumanoid:SetAttribute("CurrentHealth", enemyHumanoid:GetAttribute("CurrentHealth") - 50);

                end;

              end;

            end);

          end;

          local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability");
          if basePartCurrentDurability and basePartCurrentDurability > 0 then
  
            ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 100, contestant);
  
          end;
  
        end);

        if humanoid and humanoid:IsA("Humanoid") and changedEvent then

          humanoid.Health = 0;
          changedEvent:Disconnect();

        end;

        explosion.Parent = workspace;
        highlight:Destroy();

      end);

      tween:Play();

    end;

  end)

  local function breakdown(self: ServerArchetype)

    disqualificationEvent:Disconnect();

  end;

  local function runAutoPilot(self: ServerArchetype, actions: {ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    repeat

      -- Notes: Since Explosive Mimic is a Destroyer class archetype, the bot should focus on 
      --        destroying instead of fighting, supporting, or defending. However, there may be times
      --        when the bot should act outside its class. For example, when an enemy attacks the bot [fight], 
      --        when a nearby teammate is at low HP [support], or when the bot's team is ahead [defend].
      --        Revert back to Destroyer mode when possible.

      local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?;
      local head = character:FindFirstChild("Head") :: BasePart?;
      if not humanoid or not head then continue; end;

      
      local defaultRaycastParams: RaycastParams = RaycastParams.new();
      defaultRaycastParams.FilterType = Enum.RaycastFilterType.Exclude;
      defaultRaycastParams.FilterDescendantsInstances = {character};

      local function seekAndSelfDestruct()

        -- Look for enemies and head into that direction.
        for _, possibleEnemyContestant in ipairs(round.contestants) do

          -- TODO: Check if the contestant is on a different team (when teams are implemented).
          local isOnSameTeam = possibleEnemyContestant == contestant;
          local possibleEnemyCharacter = possibleEnemyContestant.character;
          if not isOnSameTeam and possibleEnemyCharacter then

            -- Check if the contestant is in view.
            local enemyHumanoidRootPart = possibleEnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?;
            if enemyHumanoidRootPart then

              local result = workspace:Raycast(head.CFrame.Position, enemyHumanoidRootPart.CFrame.Position - head.CFrame.Position, defaultRaycastParams);
              if result and result.Instance:IsDescendantOf(possibleEnemyCharacter) then  
                
                humanoid:MoveTo(enemyHumanoidRootPart.CFrame.Position, enemyHumanoidRootPart);
                humanoid.MoveToFinished:Wait();

                if not contestant.isDisqualified then

                  contestant:disqualify();

                end;

                break;

              end

            end

          end;

        end;

      end;

      -- [Always Active]
      -- STRATEGIC SELF-DESTRUCT
        -- If the bot is about to die, look for a nearby crowd of enemies UNLESS one of exceptions hold true. Go to the biggest crowd. 
        -- If there are multiple crowds, prioritize the crowd with the highest ranking players. Regardless the decision, try to avoid attacks.
        -- Once the bot is close enough, the bot should disqualify itself, causing the Self-Destruct effect to activate.
        -- Keep close to the enemies for as long as possible as they might try to escape.

        -- Exceptions: 
          -- 1. The bot is currently destroying a part AND is at maximum 35 durability points to destroying it.
          -- 2. The bot has a healing item or is nearby a healing zone.
          -- 3. The bot is currently getting healed.
          -- 4. The bot can significantly recover its health before it gets hurt again.
      local criticalHealthPointsValue = 10;
      if humanoid:GetAttribute("CurrentHealth") <= criticalHealthPointsValue then

        seekAndSelfDestruct();

      end;

      -- TROLL SELF-DESTRUCT
        -- If the round is 10 seconds to ending and the bot's team is significantly ahead, the bot should approach an enemy and disqualify itself 
        -- when it is three seconds away from the enemy. Prioritize enemies who haven't moved in a while, if any.
      local isRoundEnding = round.timeStarted and round.duration and DateTime.now().UnixTimestampMillis >= round.timeStarted + round.duration * 1000 - 10000;
      if isRoundEnding then

        seekAndSelfDestruct();

      end;

      -- STRATEGIC DEFENSE
        -- If the bot gets attacked while destroying a part, determine the damage taken per hit and the amount of time to the bot's disqualification.
        -- If the bot can break the part at least 3 seconds before it gets disqualified, continue breaking the part and escape the enemy's trajectory;
        -- otherwise, escape immediately.

      -- STRATEGIC LIMB DETONATION
        -- If the bot sees an enemy nearby its detached limb, detonate it.

      -- [Default Loop]
      -- 1.) Search for massive, destroyable structures. Go to the biggest one and detach a random limb on the way.
      --     Although the server has access to all destroyable parts, take a guess to ensure the round is fair.
      local targetPart: BasePart;
      repeat

        for _, destroyablePart in ipairs(stageModel:GetChildren()) do

          local currentDurability = destroyablePart:GetAttribute("CurrentDurability");
          if destroyablePart:IsA("BasePart") and currentDurability and currentDurability > 0 then

            -- Ensure the part is in visible range.
            local result = workspace:Raycast(head.CFrame.Position, destroyablePart.CFrame.Position - head.CFrame.Position, defaultRaycastParams);
            if result and result.Instance == destroyablePart then

              targetPart = destroyablePart;

            end;

          end;

        end

        if not targetPart then

          -- Move into another direction.
          
        end;

        task.wait();

      until targetPart;

      -- 2.) Go to the destroyable part.
      humanoid:MoveTo(targetPart.Position, targetPart);
      humanoid.MoveToFinished:Wait();

      -- 3.) If the part is in front of the player, use Explosive Punch until the part is destroyed.
      local primaryPart = character.PrimaryPart;
      if not primaryPart then print("wait"); continue; end;

      local frontResult = workspace:Raycast(primaryPart.CFrame.Position, primaryPart.CFrame.LookVector * 3, defaultRaycastParams);
      if frontResult and frontResult.Instance == targetPart then

        actions[1]:activate();

      else

        -- Else, if the part is under the player, use Rocket Feet until the part is destroyed.
        local bottomResult = workspace:Raycast(primaryPart.CFrame.Position, -head.CFrame.UpVector * 3, defaultRaycastParams);
        if bottomResult and bottomResult.Instance == targetPart then

          actions[4]:activate();

        end;

      end;

    until round.timeEnded;

  end;

  return ServerArchetype.new({
    ID = ExplosiveMimicServerArchetype.ID;
    name = ExplosiveMimicServerArchetype.name;
    description = ExplosiveMimicServerArchetype.description;
    actionIDs = ExplosiveMimicServerArchetype.actionIDs;
    type = ExplosiveMimicServerArchetype.type;
    breakdown = breakdown;
    runAutoPilot = runAutoPilot;
  });

end;

return ExplosiveMimicServerArchetype;