--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local Players = game:GetService("Players");
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

export type TurfWarPlayerStats = typeof(setmetatable({} :: {
  place: number;
  partsClaimed: number;
  partsDestroyed: number;
  partsRestored: number;
  timesDowned: number;
  playersDowned: number;
}, {}));

export type TurfWarStats = {
  [number]: TurfWarPlayerStats;
};

function TurfWarGameMode.new(round: ServerRound): GameMode

  local stats: TurfWarStats = {};
  local totalStageParts = 0;
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

                stats[destroyerID].partsDestroyed += 1;
                stats[destroyerID].partsClaimed += 1;

              end;

              -- Break the part.
              child.Anchored = false;

              -- Give players a chance to restore the part.
              local partReference = restoredStage:FindFirstChild(child.Name);
              assert(partReference and partReference:IsA("BasePart"), `Restorable Part {child.Name} was not found.`);
              local restorablePart = partReference:Clone();
              restorablePart.Transparency = 0.7;
              restorablePart.CanCollide = false;
              restorablePart.Anchored = true;
              restorablePart.Parent = restorablePartsModel;

              local proximityPrompt = Instance.new("ProximityPrompt");
              proximityPrompt.HoldDuration = 1.25;
              proximityPrompt.MaxActivationDistance = 40;
              proximityPrompt.RequiresLineOfSight = false;
              proximityPrompt.ObjectText = `Destroyed{if destroyerID then ` by {Players:GetPlayerByUserId(destroyerID).Name}` else ""}`;
              proximityPrompt.ActionText = "Restore";
              proximityPrompt.Parent = restorablePart;

              proximityPrompt.Triggered:Connect(function(restorer)
              
                -- Verify that the restorer is a participant.
                if stats[restorer.UserId] then

                  -- Delete old parts.
                  child:Destroy();
                  proximityPrompt:Destroy();
                  restorablePart:Destroy();

                  -- Restore the part.
                  local restoredPart = partReference:Clone();
                  restoredPart.Parent = round.stage.model;

                  if destroyerID then

                    -- Update scores.
                    stats[destroyerID].partsClaimed -= 1;
                    stats[restorer.UserId].partsRestored += 1;

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
      table.insert(events, ServerStorage.Events.ParticipantDowned.Event:Connect(function(victim: Player, downer: Player?)
      
        -- Add it to their score.
        stats[victim.UserId].playersDowned += 1;
        stats[victim.UserId].timesDowned += 1;

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

    end;
    toString = function(self)

      return HttpService:JSONDecode({
        ID = self.ID;
        stats = stats;
        totalStageParts = totalStageParts;
      })

    end;
  });

  for _, contestant in ipairs(round.contestants) do

    stats[contestant.ID] = setmetatable({
      place = 1;
      partsClaimed = 0;
      partsDestroyed = 0;
      partsRestored = 0;
      playersDowned = 0;
      timesDowned = 0;
    }, {
      __newindex = function(self: TurfWarPlayerStats, index: string, value: number)

        if index == "partsClaimed" then

          -- Simulate the standings after the update.
          local newStats = table.clone(stats);
          newStats[contestant.ID][index] = value;

          local standings: {{number}} = {};
          for participantID, playerStats in pairs(newStats) do

            -- Find the standing that the player has.
            local newStanding = 1;
            for _, playerIDs in ipairs(standings) do

              if playerStats.partsClaimed >= newStats[playerIDs[1]].partsClaimed then

                break;

              end;

              newStanding += 1;
              
            end;

            -- Add the player to this standing.
            standings[newStanding] = standings[newStanding] or {};
            table.insert(standings[newStanding], newStanding, participantID);

          end;

          for standing, participantIDs in ipairs(standings) do

            for _, participantID in ipairs(participantIDs) do

              stats[participantID].place = standing;

            end;

          end;

        end;

        return value;

      end;
    });

    if contestant.character then

      local humanoid = contestant.character:FindFirstChild("Humanoid");
      if humanoid and humanoid:IsA("Humanoid") then

        humanoid:SetAttribute("CurrentHealth", 100);
        humanoid:SetAttribute("BaseHealth", 100);
        humanoid:SetAttribute("Stamina", 100);

        table.insert(events, humanoid:GetAttributeChangedSignal("CurrentHealth"):Connect(function()
        
          if not contestant.isDisqualified and humanoid:GetAttribute("CurrentHealth") <= 0 then

            contestant:disqualify();

          end;

        end));

      else 

        contestant:disqualify();

      end;

    else

      contestant:disqualify();

    end;

  end;

  return gameMode;

end

return TurfWarGameMode;