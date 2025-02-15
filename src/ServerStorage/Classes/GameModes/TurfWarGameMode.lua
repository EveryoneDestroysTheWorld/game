--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local GameMode = require(script.Parent.Parent.GameMode);
local HttpService = game:GetService("HttpService");
local PhysicsService = game:GetService("PhysicsService");
local types = require(ServerStorage.Modules.types);

-- This is the class.
local TurfWarGameMode = {
  id = script.Name:sub(1, script.Name:gsub("GameMode", ""):len());
  name = "Turf War";
  description = "";
};

function TurfWarGameMode.new(round: types.ServerRound): types.GameMode

  local events = {};

  local vulnerableParts = {};

  local gameMode = GameMode.new({
    id = TurfWarGameMode.id;
    name = TurfWarGameMode.name;
    description = TurfWarGameMode.description;
    start = function(self)

      assert(round.stage and round.stage.model, "No stage provided.");
      local restoredStage = round.stage.model:Clone();
      restoredStage.Name = "RestoredStage";
      restoredStage.Parent = ServerStorage;

      local restorablePartsModel = Instance.new("Model");
      restorablePartsModel.Name = "RestorablePartsModel";
      restorablePartsModel.Parent = workspace;

      local function checkChild(child: Instance)

        if child:IsA("BasePart") and child:GetAttribute("BaseDurability") then

          local eventIndex = #events + 1;
          table.insert(events, child:GetAttributeChangedSignal("CurrentDurability"):Connect(function()
          
            local currentDurability = child:GetAttribute("CurrentDurability") :: number;
            if currentDurability <= 0 then

              -- Make sure this event doesn't get called again.
              events[eventIndex]:Disconnect();
            
              -- Add this to the score.
              local destroyerID = child:GetAttribute("DestroyerID") :: number?;
              if destroyerID then

                for _, contestant in round.contestants do

                  if contestant.id == destroyerID and contestant.statistics then

                    contestant:mergeStatistics({
                      partsDestroyed = contestant.statistics.partsDestroyed + 1;
                      partsClaimed = contestant.statistics.partsClaimed + 1;
                    }, {
                      contestantID = contestant.id
                    });
                    break;

                  end;

                end;

              end;

              -- Break the part.
              child.Anchored = false;

              -- Give players a chance to restore the part.
              local destroyerName;
              if destroyerID then

                for _, contestant in ipairs(round.contestants) do

                  if contestant.id == destroyerID then

                    destroyerName = contestant.name;
                    break;

                  end;

                end;

              end;

              local partReference = restoredStage:FindFirstChild(child.Name);
              assert(partReference and partReference:IsA("BasePart"), `Restorable Part {child.Name} was not found.`);
              local restorablePart = partReference:Clone();
              restorablePart.Transparency = 0.7;
              restorablePart.CanCollide = false;
              restorablePart.Anchored = true;
              restorablePart.Parent = restorablePartsModel;

              local proximityPrompt = Instance.new("ProximityPrompt");
              proximityPrompt.HoldDuration = 0;
              proximityPrompt.MaxActivationDistance = 40;
              proximityPrompt.RequiresLineOfSight = false;
              proximityPrompt.ObjectText = `Destroyed{if destroyerName then ` by {destroyerName}` else ""}`;
              proximityPrompt.ActionText = "Restore";
              proximityPrompt.Parent = restorablePart;

              proximityPrompt.Triggered:Connect(function(restorer)
              
                -- Verify that the restorer is a participant.
                for _, contestant in round.contestants do

                  if contestant.player == restorer then

                    -- Delete old parts.
                    child:Destroy();
                    proximityPrompt:Destroy();
                    restorablePart:Destroy();

                    -- Restore the part.
                    local restoredPart = partReference:Clone();
                    restoredPart.Parent = round.stage.model;

                    if contestant.statistics then

                      contestant:mergeStatistics({
                        partsRestored = contestant.statistics.partsRestored + 1
                      });

                    end

                  elseif destroyerID and destroyerID == contestant.id and contestant.statistics then

                    contestant.statistics.partsClaimed -= 1

                  end;

                end;

              end);

            end;

          end));

          table.insert(vulnerableParts, child);

        end;

      end;

      for _, child in ipairs(round.stage.model:GetChildren()) do

        checkChild(child);

      end;

      table.insert(events, round.stage.model.ChildAdded:Connect(function(child)
      
        checkChild(child);

      end));

      ServerStorage.Functions.GetVulnerableParts.OnInvoke = function()

        return vulnerableParts;

      end;

      -- Keep track of downed players.
      for _, contestant in round.contestants do

        contestant:mergeStatistics({
          partsClaimed = 0;
          partsDestroyed = 0;
          partsRestored = 0;
          recoveryCount = 0;
          eliminationCount = 0;
          deathCount = 0;
        });

        local isRecoveringStamina = false;
        local function recoverStamina()

          if not isRecoveringStamina then

            isRecoveringStamina = true;

            while contestant.currentHealth > 0 and contestant.currentStamina < contestant:getModifiedBaseValue("Stamina") and task.wait(1) do
              
              -- Recover the contestant's stamina if we can.
              contestant:updateStamina(math.min(contestant.currentStamina + 5, contestant:getModifiedBaseValue("Stamina")));

            end;

            isRecoveringStamina = false;

          end;

        end;

        table.insert(events, contestant.onStaminaUpdated:Connect(recoverStamina));

        local function trackEliminations(newHealth: number, oldHealth: number, cause: types.Cause?)

          if newHealth <= 0 and oldHealth > 0 and contestant.statistics then

            contestant:mergeStatistics({
              deathCount = contestant.statistics.deathCount + 1;
            }, cause);

            if cause and cause.contestantID then

              for _, possibleMurderer in round.contestants do

                if possibleMurderer.id == cause.contestantID and possibleMurderer.statistics then

                  possibleMurderer:mergeStatistics({
                    eliminationCount = possibleMurderer.statistics.eliminationCount + 1;
                  });

                end;

              end;

            end;

          end;

          -- Stop the round if all contestants on one team are eliminated.
          local isTeam1Eliminated = true;
          local isTeam2Eliminated = true;
          for _, otherContestant in contestant.round.contestants do

            if not otherContestant.isEliminated then

              if otherContestant.teamID == 1 then

                isTeam1Eliminated = false;

              elseif otherContestant.teamID == 2 then

                isTeam2Eliminated = false;

              end;

            end;

            if not isTeam1Eliminated and not isTeam2Eliminated then

              break;

            end;
            
          end;

          if isTeam1Eliminated or isTeam2Eliminated then

            contestant.round:stop();

          end;

        end;

        table.insert(events, contestant.onHealthUpdated:Connect(trackEliminations));

        if contestant.character then

          local shouldRegisterGroup = true;
          local collisionGroupName = `Contestant-{contestant.id}`;
          for _, collisionGroup in PhysicsService:GetRegisteredCollisionGroups() do

            if collisionGroup.name == collisionGroupName then

              shouldRegisterGroup = false;
              break;

            end;
          
          end

          if shouldRegisterGroup then

            PhysicsService:RegisterCollisionGroup(collisionGroupName);

          end;

          for _, instance in contestant.character:GetChildren() do

            if instance:IsA("BasePart") then

              instance.CollisionGroup = collisionGroupName;

            end;

          end;

        end;

      end;

      table.insert(events, ReplicatedStorage.Shared.Events.ResetButtonPressed.OnServerEvent:Connect(function(player)
      
        for _, contestant in round.contestants do

          if contestant.player == player then

            contestant:updateHealth(0);

          end;

        end;

      end));
      
      ServerStorage.Functions.ModifyPartCurrentDurability.OnInvoke = function(basePart, newDurability, cause: types.Cause)

        local currentDurability = basePart:GetAttribute("CurrentDurability");
        if currentDurability > 0 then

          if newDurability <= 0 then

            basePart:SetAttribute("DestroyerID", cause.contestantID);

          end;
          basePart:SetAttribute("CurrentDurability", newDurability);

        end;

      end;

      ReplicatedStorage.Shared.Functions.GetTotalStagePartCount.OnServerInvoke = function()

        return #vulnerableParts;
    
      end;

    end;
    breakdown = function(self)

      -- Disconnect all events.
      for _, event in ipairs(events) do

        event:Disconnect();

      end;

      -- Delete the restored stage.
      local restoredStage = workspace:FindFirstChild("RestoredStage");
      if restoredStage then

        restoredStage:Destroy();

      end;

      local restorablePartsModel = workspace:FindFirstChild("RestorablePartsModel");
      if restorablePartsModel then

        restorablePartsModel:Destroy();

      end;

      ServerStorage.Functions.ModifyPartCurrentDurability.OnInvoke = nil;
      ServerStorage.Functions.GetVulnerableParts.OnInvoke = nil;

    end;
    toString = function(self)

      return HttpService:JSONDecode({
        id = self.id;
        totalStageParts = #vulnerableParts;
      })

    end;
  });

  return gameMode;

end

return TurfWarGameMode;