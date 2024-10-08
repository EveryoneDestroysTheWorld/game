--!strict
local TweenService = game:GetService("TweenService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");
local ServerArchetype = require(script.Parent.Parent.ServerArchetype);
local ServerContestant = require(script.Parent.Parent.ServerContestant);
local ExplosiveMimicClientArchetype = require(ReplicatedStorage.Client.Classes.Archetypes.ExplosiveMimicClientArchetype);
local ServerRound = require(script.Parent.Parent.ServerRound);
local ServerAction = require(script.Parent.Parent.ServerAction);
type ServerRound = ServerRound.ServerRound;
type ServerContestant = ServerContestant.ServerContestant;
type ServerArchetype = ServerArchetype.ServerArchetype;
type ServerAction = ServerAction.ServerAction;
local downContestant = require(ServerStorage.Modules.downContestant);

local ExplosiveMimicServerArchetype = {
  ID = ExplosiveMimicClientArchetype.ID;
  name = ExplosiveMimicClientArchetype.name;
  description = ExplosiveMimicClientArchetype.description;
  actionIDs = ExplosiveMimicClientArchetype.actionIDs;
  type = ExplosiveMimicClientArchetype.type;
};

function ExplosiveMimicServerArchetype.new(): ServerArchetype

  local contestant: ServerContestant = nil;
  local round: ServerRound = nil;
  local disqualificationEvent: RBXScriptConnection;

  local function breakdown(self: ServerArchetype)

    disqualificationEvent:Disconnect();

  end;

  local function runAutoPilot(self: ServerArchetype, actions: {ServerAction})

    -- Make sure the contestant has a character.
    local character = contestant.character
    assert(character, "Character not found");

    -- STRATEGIC DEFENSE
      -- If the bot gets attacked while destroying a part, determine the damage taken per hit and the amount of time to the bot's disqualification.
      -- If the bot can break the part at least 3 seconds before it gets disqualified, continue breaking the part and escape the enemy's trajectory;
      -- otherwise, escape immediately.
    local contestantToAttack: ServerContestant?;
    local timeEnemyAttacked: number = 0;
    local targetPart: BasePart?;
    local forgivenessTask;
    local healthUpdateEvent = contestant.onHealthUpdated:Connect(function(newHealth, oldHealth, cause)

      local primaryPart = character.PrimaryPart;
      local targetPartDurability = targetPart and targetPart:GetAttribute("CurrentDurability") :: number?;
      local isTargetPartAlmostDestroyed = not contestantToAttack and not targetPart or targetPartDurability and targetPartDurability <= 35;
      local enemyCharacter = cause and cause.contestant and cause.contestant.character;
      if isTargetPartAlmostDestroyed and primaryPart and newHealth < oldHealth and cause and cause.contestant and enemyCharacter and cause.actionID and cause.actionID ~= 2 then

        -- Determine if it is possible to get to the player before they kill the NPC.
        local enemyPrimaryPart = enemyCharacter.PrimaryPart;
        if enemyPrimaryPart then

          local function cleanupTask()

            if forgivenessTask and coroutine.status(forgivenessTask) == "suspended" then
  
              task.cancel(forgivenessTask);
  
            end;

          end;

          local function forgiveEnemy()

            cleanupTask();

            local isEnemyInCriticalCondition = cause.contestant.currentHealth < 25;
            local hasEnemyAttackedPlayerAgain = DateTime.now().UnixTimestampMillis <= timeEnemyAttacked + 3000;
            local shouldForgiveEnemy = not isEnemyInCriticalCondition and not hasEnemyAttackedPlayerAgain;
            if shouldForgiveEnemy then

              contestantToAttack = nil;
              targetPart = nil;
              timeEnemyAttacked = 0;

            end;

          end;

          cleanupTask();

          contestantToAttack = cause.contestant;
          timeEnemyAttacked = DateTime.now().UnixTimestampMillis;

          -- Forgive the enemy after 3 seconds of peace or when they get disqualified.
          forgivenessTask = task.delay(3, forgiveEnemy);

        end;

      end
    
    end);

    repeat

      -- Notes: Since Explosive Mimic is a Destroyer class archetype, the bot should focus on 
      --        destroying instead of fighting, supporting, or defending. However, there may be times
      --        when the bot should act outside its class. For example, when an enemy attacks the bot [fight], 
      --        when a nearby teammate is at low HP [support], or when the bot's team is ahead [defend].
      --        Revert back to Destroyer mode when possible.

      local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?;
      local head = character:FindFirstChild("Head") :: BasePart?;
      if not humanoid or not head or humanoid.Health == 0 then continue; end;

      local defaultRaycastParams: RaycastParams = RaycastParams.new();
      defaultRaycastParams.FilterType = Enum.RaycastFilterType.Exclude;
      defaultRaycastParams.FilterDescendantsInstances = {character};

      local function seekAndSelfDestruct()

        -- Look for enemies and head into that direction.
        local closestEnemyHRP: BasePart?;
        for _, possibleEnemyContestant in ipairs(round.contestants) do

          -- TODO: Check if the contestant is on a different team (when teams are implemented).
          local isOnSameTeam = possibleEnemyContestant == contestant or (possibleEnemyContestant.teamID and possibleEnemyContestant.teamID == contestant.teamID);
          local possibleEnemyCharacter = possibleEnemyContestant.character;
          if not possibleEnemyContestant.isDisqualified and not isOnSameTeam and possibleEnemyCharacter then

            -- Check if the contestant is in view.
            local enemyHumanoidRootPart = possibleEnemyCharacter:FindFirstChild("HumanoidRootPart") :: BasePart?;
            if enemyHumanoidRootPart then

              local result = workspace:Raycast(head.CFrame.Position, enemyHumanoidRootPart.CFrame.Position - head.CFrame.Position, defaultRaycastParams);
              local selfHRP = character:FindFirstChild("HumanoidRootPart") :: BasePart?;
              local selfPosition = selfHRP and selfHRP.CFrame.Position;
              local isEnemyClosest = selfPosition and (not closestEnemyHRP or (closestEnemyHRP.CFrame.Position - selfPosition).Magnitude > (enemyHumanoidRootPart.CFrame.Position - selfPosition).Magnitude);
              if result and result.Instance:IsDescendantOf(possibleEnemyCharacter) and isEnemyClosest then  
                
                closestEnemyHRP = enemyHumanoidRootPart;
                break;

              end

            end

          end;

        end;

        if closestEnemyHRP then

          humanoid:MoveTo(closestEnemyHRP.CFrame.Position, closestEnemyHRP);
          humanoid.MoveToFinished:Wait();
          contestant:updateHealth(0);

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
      
      -- TROLL SELF-DESTRUCT
        -- If the round is 10 seconds to ending and the bot's team is significantly ahead, the bot should approach an enemy and disqualify itself 
        -- when it is three seconds away from the enemy. Prioritize enemies who haven't moved in a while, if any.
      local isRoundEndingSoon = round.timeStarted and round.duration and DateTime.now().UnixTimestampMillis >= round.timeStarted + round.duration * 1000 - 10000;
      if isRoundEndingSoon or contestant.isDisqualified then

        seekAndSelfDestruct();
        continue;

      end;

      -- STRATEGIC LIMB DETONATION
        -- If the bot sees an enemy nearby its detached limb, detonate it.
      local detachLimbFunction = ServerStorage.Functions.ActionFunctions:FindFirstChild(`{contestant.ID}_GetDetachedLimbs`) :: BindableFunction?;
      if detachLimbFunction then

        local detachedLimbs = detachLimbFunction:Invoke();
        for _, limb in pairs(detachedLimbs) do

          local didDetonateAllLimbs = false;
          for _, possibleEnemyContestant in ipairs(round.contestants) do

            local possibleEnemyCharacter = contestant.character;
            if possibleEnemyContestant ~= contestant and possibleEnemyCharacter then
              
              local enemyPrimaryPart = possibleEnemyCharacter.PrimaryPart;
              local isEnemyInRangeOfExplosion = enemyPrimaryPart and (enemyPrimaryPart.CFrame.Position - limb.CFrame.Position).magnitude < 10;
              if enemyPrimaryPart and isEnemyInRangeOfExplosion then
              
                local raycastResult = workspace:Raycast(head.CFrame.Position, enemyPrimaryPart.CFrame.Position - head.CFrame.Position, defaultRaycastParams);
                local canNPCSeeEnemy = raycastResult and raycastResult.Instance == enemyPrimaryPart;
                if canNPCSeeEnemy then

                  actions[3]:activate();
                  didDetonateAllLimbs = true;
                  break;

                end;

              end;

            end;

          end;

          if didDetonateAllLimbs then

            break;

          end;

        end;

      end;

      local path = PathfindingService:CreatePath({
        WaypointSpacing = 100;
      });
      local primaryPart = character.PrimaryPart;
      if not primaryPart then continue; end;

      local waypoints = {};
      local originalPartPosition = Vector3.zero;
      local function updatePath()

        return pcall(function()

          originalPartPosition = (targetPart :: BasePart).CFrame.Position;
          path:ComputeAsync(primaryPart.CFrame.Position, originalPartPosition);
          waypoints = path:GetWaypoints()
  
        end);

      end;
      
      local enemyContestantCharacter = contestantToAttack and contestantToAttack.character;
      local enemyContestantPrimaryPart = enemyContestantCharacter and enemyContestantCharacter.PrimaryPart;
      if contestantToAttack and contestantToAttack.currentHealth < 0 then

        contestantToAttack = nil;
        targetPart = nil;
        continue;

      elseif enemyContestantPrimaryPart then

        targetPart = enemyContestantPrimaryPart;

      else

        -- [Default Loop]
        -- 1.) Search for massive, destroyable structures. Go to the biggest one and detach a random limb on the way.
        --     Although the server has access to all destroyable parts, take a guess to ensure the round is fair.
        repeat

          -- Search for a visible, destroyable structure.
          -- TODO: Search for *massive* structures.
          local currentPartDurability = targetPart and targetPart:GetAttribute("CurrentDurability") :: number?;
          if currentPartDurability and currentPartDurability <= 0 then

            targetPart = nil;

          end;

          local visibleDestroyableParts = {};
          if not round.stage.model then continue end;
          for _, destroyablePart in ipairs(round.stage.model:GetChildren()) do

            local currentDurability = destroyablePart:GetAttribute("CurrentDurability") :: number?;
            if destroyablePart:IsA("BasePart") and currentDurability and currentDurability > 0 then

              -- Ensure the part is in visible range.
              local result = workspace:Raycast(head.CFrame.Position, destroyablePart.CFrame.Position - head.CFrame.Position, defaultRaycastParams);
              if result and result.Instance == destroyablePart then

                table.insert(visibleDestroyableParts, destroyablePart);

              end;

            end;

          end;

          for _, destroyablePart in ipairs(visibleDestroyableParts) do

            local headPosition = head.CFrame.Position;
            local isPartCloserThanTargetPart = not targetPart or (targetPart.CFrame.Position - headPosition).Magnitude > (destroyablePart.CFrame.Position - headPosition).Magnitude;
            if isPartCloserThanTargetPart then

              targetPart = destroyablePart;

            end;
            
          end;

          -- If there is no part, move into a random direction and search again.
          if not targetPart then

            
          end;

        until task.wait() and targetPart;

      end;

      -- 2.) Go to the destroyable part.
      local didSuccessfullyComputePath, errorMessage = updatePath();
      local checkEvent = game:GetService("RunService").Heartbeat:Connect(function() 
      
        if targetPart and math.abs(((targetPart :: BasePart).CFrame.Position - originalPartPosition).Magnitude) > 3 then

          updatePath();

        end;

      end);
      if not didSuccessfullyComputePath or path.Status ~= Enum.PathStatus.Success then

        warn(errorMessage);
        continue;

      end;

      local blockedEvent = path.Blocked:Connect(updatePath);

      while waypoints[1] do

        local originalWaypoint = waypoints[1];
        humanoid:MoveTo(waypoints[1].Position);

        local shouldContinue = false;
        local moveToEvent = humanoid.MoveToFinished:Connect(function() 
        
          shouldContinue = true;

        end);

        local shouldBreak = false;
        repeat task.wait() until shouldContinue or waypoints[1] ~= originalWaypoint;
        moveToEvent:Disconnect();

        if shouldBreak then

          break;

        end;

        table.remove(waypoints, 1);

      end;

      checkEvent:Disconnect();
      blockedEvent:Disconnect();

      -- 3.) If the part is in front of the player, use Explosive Punch until the part is destroyed.
      local frontResult = workspace:Raycast(primaryPart.CFrame.Position, primaryPart.CFrame.LookVector * 3, defaultRaycastParams);
      local isByEnemy = frontResult and enemyContestantPrimaryPart and frontResult.Instance:IsDescendantOf(enemyContestantPrimaryPart.Parent);
      if frontResult and frontResult.Instance == targetPart or isByEnemy then

        actions[1]:activate();

      else

        -- Else, if the part is under the player, use Rocket Feet until the part is destroyed.
        local bottomResult = workspace:Raycast(primaryPart.CFrame.Position, -head.CFrame.UpVector * 3, defaultRaycastParams);
        isByEnemy = bottomResult and enemyContestantPrimaryPart and bottomResult.Instance:IsDescendantOf(enemyContestantPrimaryPart.Parent);
        if bottomResult and bottomResult.Instance == targetPart then

          actions[4]:activate();

        end;

      end;

    until task.wait() and round.timeEnded;

    healthUpdateEvent:Disconnect();

  end;

  local function initialize(self: ServerArchetype, newContestant: ServerContestant, newRound: ServerRound)

    -- Set up the self-destruct.
    contestant = newContestant;
    round = newRound;
    local isExploding = false;
    disqualificationEvent = contestant.onHealthUpdated:Connect(function()

      if not isExploding and contestant.currentHealth <= 0 and contestant.character then
  
        -- Make the player progressively grow white for 3 seconds.
        isExploding = true;
        local highlight = Instance.new("Highlight");
        highlight.FillTransparency = 1;
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
        highlight.FillColor = Color3.new(1, 1, 1);
        highlight.Parent = contestant.character;
        
        local humanoid = contestant.character:FindFirstChild("Humanoid") :: Humanoid?;
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
          local primaryPart = contestant.character.PrimaryPart;
          assert(primaryPart, "PrimaryPart not found.");
  
          local explosion = Instance.new("Explosion");
          explosion.BlastPressure = 50000;
          explosion.BlastRadius = 20;
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
                  possibleEnemyContestant:updateHealth(possibleEnemyContestant.currentHealth - 50, {
                    contestant = contestant;
                    archetypeID = ExplosiveMimicServerArchetype.ID;
                  });
  
                end;
  
              end);
  
            end;
  
            local basePartCurrentDurability = basePart:GetAttribute("CurrentDurability") :: number?;
            if basePartCurrentDurability and basePartCurrentDurability > 0 then
    
              ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(basePart, basePartCurrentDurability - 100, contestant);
    
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
            
            for _, part in ipairs(contestant.character:GetDescendants()) do
  
              if part:IsA("BasePart") then
  
                part:SetNetworkOwner(nil);
  
              end;
  
            end;
            changedEvent:Disconnect();

            downContestant(contestant);
  
          end;

          explosion.Parent = workspace;
          highlight:Destroy();
  
        end);
  
        tween:Play();
  
      end;
  
    end);

    if contestant.player then

      ReplicatedStorage.Shared.Functions.InitializeArchetype:InvokeClient(contestant.player, self.ID);

    end;

  end;

  return ServerArchetype.new({
    ID = ExplosiveMimicServerArchetype.ID;
    name = ExplosiveMimicServerArchetype.name;
    description = ExplosiveMimicServerArchetype.description;
    actionIDs = ExplosiveMimicServerArchetype.actionIDs;
    type = ExplosiveMimicServerArchetype.type;
    breakdown = breakdown;
    runAutoPilot = runAutoPilot;
    initialize = initialize;
  });

end;

return ExplosiveMimicServerArchetype;