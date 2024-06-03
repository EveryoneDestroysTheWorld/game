--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local GameMode = require(script.Parent.Parent.GameMode);

-- This is the class.
local TurfWarGameMode = setmetatable({
  __index = {} :: GameMode.GameModeMethods<TurfWarGameMode>; -- Keeps IntelliSense working in the methods.
  defaultProperties = {
    ID = 1;
    name = "Turf War";
    description = "";
    stats = {};
    events = {};
  };
}, GameMode);

export type TurfWarGameModeProperties = {
  events: {RBXScriptConnection}; 
  totalStageParts: number?;
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

local actionProperties: GameMode.GameModeProperties<TurfWarGameModeProperties, TurfWarStats> = TurfWarGameMode.defaultProperties;

-- Although it has the same name, this is the object type.
export type TurfWarGameMode = typeof(setmetatable(GameMode.new(actionProperties), {__index = TurfWarGameMode.__index}));

-- Returns a new action based on the user.
-- @since v0.1.0
function TurfWarGameMode.new(participantIDs: {number}): TurfWarGameMode

  local gameMode = setmetatable(GameMode.new(actionProperties), TurfWarGameMode.__index);

  for _, participantID in ipairs(participantIDs) do

    gameMode.stats[participantID] = setmetatable({
      place = 1;
      partsClaimed = 0;
      partsDestroyed = 0;
      partsRestored = 0;
      playersDowned = 0;
      timesDowned = 0;
    }, {
      __newindex = function(self: typeof(gameMode), index: string, value: number)

        if index == "partsClaimed" then

          local standings: {{number}} = {};
          for participantID, stats in pairs(self.stats) do

            -- Find the standing that the player has.
            local newStanding = 1;
            for _, playerIDs in ipairs(standings) do

              if self.stats[participantID].partsClaimed >= self.stats[playerIDs[1]].partsClaimed then

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

              self.stats[participantID].place = standing;

            end;

          end;

        end;

        return value;

      end;
    });

  end;

  return gameMode;

end

-- @since v0.1.0
function TurfWarGameMode.__index:start(stageModel: Model): ()

  -- 
  local restoredStage = stageModel:Clone();
  restoredStage.Name = "RestoredStage";
  restoredStage.Parent = ServerStorage;

  -- Keep track of destroyed parts.
  local totalStageParts = 0;
  for _, child in ipairs(restoredStage:GetChildren()) do

    if child:IsA("BasePart") and child:GetAttribute("BaseDurability") then

      table.insert(self.events, child:GetAttributeChangedSignal("CurrentDurability"):Connect(function()
      
        local destroyerID = child:GetAttribute("DestroyerID") :: number?;
        if destroyerID then

          -- Add this to the score.
          self.stats[destroyerID].partsDestroyed += 1;
          self.stats[destroyerID].partsClaimed += 1;

          -- Give players a chance to restore the part.
          local restorablePart = restoredStage:FindFirstChild(child.Name);

          local proximityPrompt = Instance.new("ProximityPrompt");
          proximityPrompt.HoldDuration = 1.25;
          proximityPrompt.MaxActivationDistance = 40;
          proximityPrompt.RequiresLineOfSight = false;
          proximityPrompt.ObjectText = `Destroyed by {Players:GetPlayerByUserId(destroyerID).Name}`
          proximityPrompt.ActionText = "Restore";
          proximityPrompt.Parent = restorablePart;

          proximityPrompt.Triggered:Connect(function(restorer)
          
            -- Verify that the restorer is a participant.


            -- Restore the part.
            proximityPrompt:Destroy();
            child:SetAttribute("CurrentDurability", child:GetAttribute("BaseDurability"));

            -- Update scores.
            self.stats[destroyerID].partsClaimed -= 1;
            self.stats[restorer.UserId].partsRestored += 1;

          end);

        end;

      end));

      totalStageParts += 1;

    end;

  end;

  self.totalStageParts = totalStageParts;

  -- Keep track of downed players.
  table.insert(self.events, ServerStorage.Events.ParticipantDowned.Event:Connect(function(victim: Player, downer: Player?)
  
    -- Add it to their score.
    self.stats[victim.UserId].playersDowned += 1;
    self.stats[victim.UserId].timesDowned += 1;

  end));

end;

function TurfWarGameMode.__index:breakdown()

  -- Delete the restored stage.
  local restoredStage = workspace:FindFirstChild("RestoredStage");
  if restoredStage then

    restoredStage:Destroy();

  end;

  -- Disconnect all events.
  for _, event in ipairs(self.events) do

    event:Disconnect();

  end;

end;

function TurfWarGameMode.__index:toString()

  return HttpService:JSONDecode({
    ID = self.ID;
    stats = self.stats;
  });

end;

return TurfWarGameMode;