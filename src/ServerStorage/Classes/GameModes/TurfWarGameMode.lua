--!strict
-- Programmer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local GameMode = require(script.Parent.Parent.GameMode);
type GameMode = GameMode.GameMode;
local HttpService = game:GetService("HttpService");
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;
local Cause = require(ServerStorage.Types["Cause.types"]);
type Cause = Cause.Cause;

-- This is the class.
local TurfWarGameMode = {
  id = script.Name:sub(1, script.Name:gsub("GameMode", ""):len());
  name = "Turf War";
  description = "";
};

function TurfWarGameMode.new(round: ServerRound): GameMode

  local events = {};

  local totalStageParts = 0;

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

          totalStageParts += 1;

        end;

      end;

      for _, child in ipairs(round.stage.model:GetChildren()) do

        checkChild(child);

      end;

      table.insert(events, round.stage.model.ChildAdded:Connect(function(child)
      
        checkChild(child);

      end));

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

            while contestant.currentHealth > 0 and contestant.currentStamina < contestant.baseStamina and task.wait(1) do
              
              -- Recover the contestant's stamina if we can.
              contestant:updateStamina(math.min(contestant.currentStamina + 5, contestant.baseStamina));

            end;

            isRecoveringStamina = false;

          end;

        end;

        table.insert(events, contestant.onStaminaUpdated:Connect(recoverStamina));

        local function trackEliminations(newHealth: number, oldHealth: number, cause: Cause?)

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

        end;

        table.insert(events, contestant.onHealthUpdated:Connect(trackEliminations));

      end;

      table.insert(events, ReplicatedStorage.Shared.Events.ResetButtonPressed.OnServerEvent:Connect(function(player)
      
        for _, contestant in round.contestants do

          if contestant.player == player then

            contestant:updateHealth(0);

          end;

        end;

      end));
      
      ServerStorage.Functions.ModifyPartCurrentDurability.OnInvoke = function(basePart, newDurability, contestant)

        local currentDurability = basePart:GetAttribute("CurrentDurability");
        if currentDurability > 0 then

          if newDurability <= 0 then

            basePart:SetAttribute("DestroyerID", contestant.id);

          end;
          basePart:SetAttribute("CurrentDurability", newDurability);

        end;

      end;

      ReplicatedStorage.Shared.Functions.GetTotalStagePartCount.OnServerInvoke = function()

        return totalStageParts;
    
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

    end;
    toString = function(self)

      return HttpService:JSONDecode({
        id = self.id;
        totalStageParts = totalStageParts;
      })

    end;
  });

  return gameMode;

end

return TurfWarGameMode;