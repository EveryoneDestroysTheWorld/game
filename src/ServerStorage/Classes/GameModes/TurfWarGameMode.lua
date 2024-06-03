--!strict
-- Writer: Christian Toney (Sudobeast)
-- Designer: Christian Toney (Sudobeast)
local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");
local Players = game:GetService("Players");
local GameMode = require(script.Parent.Parent.GameMode);

-- This is the class.
local TurfWarGameMode = setmetatable({
  __index = {} :: GameMode.GameModeProperties<TurfWarGameMode>; -- Keeps IntelliSense working in the methods.
  defaultProperties = {
    ID = 1;
    name = "Turf War";
    description = "";
    stats = {};
    events = {};
  }
}, GameMode);

export type TurfWarStats = {
  [number]: {
    place: number;
    partsDestroyed: number;
    partsRestored: number;
    timesDowned: number;
    playersDowned: number;
  }
};

local actionProperties: GameMode.GameModeProperties<{stats: TurfWarStats; events: {RBXScriptConnection}; totalStageParts: number?}> = TurfWarGameMode.defaultProperties;

-- Although it has the same name, this is the object type.
export type TurfWarGameMode = typeof(setmetatable(GameMode.new(actionProperties), {__index = TurfWarGameMode.__index}));

-- Returns a new action based on the user.
-- @since v0.1.0
function TurfWarGameMode.new(participantIDs: {number}): TurfWarGameMode

  local gameMode = setmetatable(GameMode.new(actionProperties), TurfWarGameMode.__index);

  for _, participantID in ipairs(participantIDs) do

    (gameMode.stats :: TurfWarStats)[participantID] = {
      place = 1;
      partsDestroyed = 0;
      partsRestored = 0;
      playersDowned = 0;
      timesDowned = 0;
    }

  end;

  return gameMode;

end

function TurfWarGameMode.__index:updateStandings()

  local standings: {{number}} = {};
  for participantID, stats in pairs(self.stats) do

    local newStanding = 1;
    for _, standing in ipairs(standings) do


      
    end;
    -- stats.

    -- Add the player to this standing.
    standings[newStanding] = standings[newStanding] or {};
    table.insert(standings[newStanding], newStanding, participantID);

  end;

  for standing, participantID in ipairs(standings) do

    props.stats[participantID] = standing;

  end;

end;

-- @since v0.1.0
function TurfWarGameMode.__index:start(stageModel: Model): ()

  -- 
  local restoredStage = stageModel:Clone();
  restoredStage.Name = "RestoredStage";
  restoredStage.Parent = ServerStorage;

  -- Keep track of destroyed parts.
  local totalStageParts = 0;
  for _, child in ipairs(stageModel:GetChildren()) do

    if child:IsA("BasePart") and child:GetAttribute("BaseDurability") then

      table.insert(self.events, child:GetAttributeChangedSignal("CurrentDurability"):Connect(function()
      
        local destroyerID = child:GetAttribute("DestroyerID") :: number?;
        if destroyerID then

          -- Add this to the score.
          (self.stats :: {})[destroyerID].partsDestroyed += 1;

          -- Give players a chance to restore the part.
          local restorablePart = restoredStage:FindFirstChild(child.Name);

          local proximityPrompt = Instance.new("ProximityPrompt");
          proximityPrompt.HoldDuration = 1.25;
          proximityPrompt.MaxActivationDistance = 40;
          proximityPrompt.RequiresLineOfSight = false;
          proximityPrompt.ObjectText = `Destroyed by {Players:GetPlayerByUserId(destroyerID).Name}`
          proximityPrompt.ActionText = "Restore";
          proximityPrompt.Parent = restorablePart;

          proximityPrompt.Triggered:Connect(function(player)
          
            -- Restore the part.
            proximityPrompt:Destroy();
            child:SetAttribute("CurrentDurability", child:GetAttribute("BaseDurability"));

            -- Remove the part from the player's score.

          end);

        else

          -- Make sure no one has this part in their score.


        end;

      end));

      totalStageParts += 1;

    end;

  end;

  self.totalStageParts = totalStageParts;

  -- Keep track of downed players.
  table.insert(self.events, ServerStorage.Events.ParticipantDowned.Event:Connect(function(victim: Player, downer: Player?)
  
    -- Add it to their score.


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