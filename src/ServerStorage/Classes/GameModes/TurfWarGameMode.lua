--!strict
-- Writer: Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local GameMode = require(script.Parent.Parent.GameMode);
type GameMode = GameMode.GameMode;
local HttpService = game:GetService("HttpService");
local ServerRound = require(script.Parent.Parent.ServerRound);
type ServerRound = ServerRound.ServerRound;

-- This is the class.
local TurfWarGameMode = {
  ID = 1;
  name = "Turf War";
  description = "";
}; 

export type TurfWarPlayerStats = {
  partsClaimed: number; -- The parts that the player currently has.
  partsDestroyed: number;
  partsRestored: number;
  timesDowned: number;
  playersDowned: number;
};

export type TurfWarStats = {
  totalStageParts: number;
  contestants: {
    [string]: TurfWarPlayerStats;
  }
};

function TurfWarGameMode.new(round: ServerRound): GameMode

  local stats: TurfWarStats = {
    totalStageParts = 0;
    contestants = {};
  };
  local events = {};

  local gameMode = GameMode.new({
    ID = TurfWarGameMode.ID;
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

      ServerStorage.Functions.ModifyPartCurrentDurability.OnInvoke = function(basePart, newDurability, contestant)

        local currentDurability = basePart:GetAttribute("CurrentDurability");
        if currentDurability > 0 then

          if newDurability <= 0 then

            basePart:SetAttribute("DestroyerID", contestant.ID);

          end;
          basePart:SetAttribute("CurrentDurability", newDurability);

        end;

      end;

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

                stats.contestants[tostring(destroyerID)].partsDestroyed += 1;
                stats.contestants[tostring(destroyerID)].partsClaimed += 1;
                ReplicatedStorage.Shared.Events.GameModeStatsUpdated:FireAllClients();

              end;

              -- Break the part.
              child.Anchored = false;

              -- Give players a chance to restore the part.
              local destroyerName;
              if destroyerID then

                for _, contestant in ipairs(round.contestants) do

                  if contestant.ID == destroyerID then

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
                if stats.contestants[tostring(restorer.UserId)] then

                  -- Delete old parts.
                  child:Destroy();
                  proximityPrompt:Destroy();
                  restorablePart:Destroy();

                  -- Restore the part.
                  local restoredPart = partReference:Clone();
                  restoredPart.Parent = round.stage.model;

                  if destroyerID then

                    -- Update scores.
                    stats.contestants[tostring(destroyerID)].partsClaimed -= 1;
                    stats.contestants[tostring(restorer.UserId)].partsRestored += 1;
                    ReplicatedStorage.Shared.Events.GameModeStatsUpdated:FireAllClients();

                  end;

                end;

              end);

            end;

          end));

          stats.totalStageParts += 1;

        end;

      end;

      for _, child in ipairs(round.stage.model:GetChildren()) do

        checkChild(child);

      end;

      table.insert(events, round.stage.model.ChildAdded:Connect(function(child)
      
        checkChild(child);

      end));

      -- Keep track of downed players.
      table.insert(events, ServerStorage.Events.ParticipantDowned.Event:Connect(function(victim: Player, downer: Player?)
      
        -- Add it to their score.
        stats.contestants[tostring(victim.UserId)].playersDowned += 1;
        stats.contestants[tostring(victim.UserId)].timesDowned += 1;

      end));

      ReplicatedStorage.Shared.Functions.GetGameModeStats.OnServerInvoke = function()

        return stats;

      end;

      for _, contestant in round.contestants do

        local isRecoveringStamina = false;
        local function recoverStamina()

          if not isRecoveringStamina then

            isRecoveringStamina = true;

            while contestant.currentHealth > 0 and contestant.currentStamina < contestant.baseStamina do

              task.wait(1);
              contestant:updateStamina(math.min(contestant.currentStamina + 5, contestant.baseStamina));

            end;

            isRecoveringStamina = false;

          end;

        end;

        local isHandled = false;
        local ghostHighlight: Highlight? = nil;
        local function checkHealth()

          if contestant.currentHealth > 0 and ghostHighlight then

            ghostHighlight:Destroy();
          
          elseif not isHandled and contestant.currentHealth <= 0 then

            -- Remove all items.
            isHandled = true;
            contestant:updateInventory({});

            -- Turn the player transparent.
            if contestant.character then

              local highlight = Instance.new("Highlight");
              highlight.Name = "GhostHighlight";
              highlight.Parent = contestant.character;
              highlight.OutlineTransparency = 1;
              highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
              highlight.FillColor = Color3.fromRGB(152, 202, 248);
              highlight.FillTransparency = 0.5;
              ghostHighlight = highlight;

              local proximityPrompt = Instance.new("ProximityPrompt");
              proximityPrompt.Name = "RevivalProximityPrompt";
              proximityPrompt.ObjectText = "Downed contestant";
              proximityPrompt.ActionText = "Revive";
              proximityPrompt.HoldDuration = 3;
              proximityPrompt.Triggered:Once(function(player)
            
                -- Prevent the player from reviving themself.
                if player ~= contestant.player then

                  contestant:updateHealth(contestant.baseHealth / 2);
                  proximityPrompt:Destroy();

                end;

              end);
              proximityPrompt.Parent = contestant.character;

            end;

          end;

        end;

        table.insert(events, contestant.onHealthUpdated:Connect(checkHealth));
        table.insert(events, contestant.onStaminaUpdated:Connect(recoverStamina));

      end;

      table.insert(events, ReplicatedStorage.Shared.Events.ResetButtonPressed.OnServerEvent:Connect(function(player)
      
        for _, contestant in round.contestants do

          if contestant.player == player then

            contestant:updateHealth(0);

          end;

        end;

      end));

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

      ReplicatedStorage.Shared.Functions.GetGameModeStats.OnServerInvoke = nil;
      ServerStorage.Functions.ModifyPartCurrentDurability.OnInvoke = nil;

    end;
    toString = function(self)

      return HttpService:JSONDecode({
        ID = self.ID;
        stats = stats;
        totalStageParts = stats.totalStageParts;
      })

    end;
  });

  for _, contestant in ipairs(round.contestants) do

    stats.contestants[tostring(contestant.ID)] = {
      partsClaimed = 0;
      partsDestroyed = 0;
      partsRestored = 0;
      playersDowned = 0;
      timesDowned = 0;
    };

  end;

  return gameMode;

end

return TurfWarGameMode;