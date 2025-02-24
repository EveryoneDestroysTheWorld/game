--!strict
-- This module represents an Archetype, which contains a list of powers.
-- 
-- Programmers: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientContestant = require(script.Parent.ClientContestant);
local types = require(ReplicatedStorage.Client.Modules.SharedTypes);

export type RoundStatus = "Waiting for players" | "Contestant selection" | "Matchup preview" | "Initializing character models" | "Pre-round countdown" | "Active";

export type RoundProperties = {

  id: string;  
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  status: RoundStatus;

}

local ClientRound = {
  __index = {};
};

export type RoundEvents = {
  onContestantAdded: RBXScriptSignal<number>;
  onContestantRemoved: RBXScriptSignal<number>;
  onEnded: RBXScriptSignal;
  onStopped: RBXScriptSignal;
  onStatusChanged: RBXScriptSignal;
  onStarted: RBXScriptSignal;
}

export type ClientRound = typeof(setmetatable({}, ClientRound)) & RoundProperties & RoundEvents;

local serverRound: ClientRound;

function ClientRound.new(properties: RoundProperties): ClientRound

  local round = setmetatable(properties, ClientRound);
  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onStopped", "onStarted", "onEnded", "onStatusChanged", "onContestantAdded", "onContestantRemoved"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    round[eventName] = events[eventName].Event;

  end

  ReplicatedStorage.Shared.Events.ContestantAdded.OnClientEvent:Connect(function(roundID: string, contestantID: number)

    events.onContestantAdded:Fire(contestantID);

  end);

  ReplicatedStorage.Shared.Events.ContestantRemoved.OnClientEvent:Connect(function(roundID: string, contestantID: number)
  
    events.onContestantRemoved:Fire(contestantID);

  end);

  ReplicatedStorage.Shared.Events.RoundStatusChanged.OnClientEvent:Connect(function(roundID: string, newStatus: RoundStatus, oldStatus: RoundStatus)
  
    if roundID == round.id then

      round.status = newStatus;
      events.onStatusChanged:Fire(newStatus, oldStatus);

    end;

  end);

  ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function(roundID: string)
  
    if roundID == round.id then

      events.onEnded:Fire();

    end;

  end);

  ReplicatedStorage.Shared.Events.RoundStarted.OnClientEvent:Connect(function(roundID: string, startTime: number)
  
    if roundID == round.id then

      round.timeStarted = startTime;
      events.onStarted:Fire();

    end;

  end);

  ReplicatedStorage.Shared.Events.RoundStopped.OnClientEvent:Connect(function(roundID: string)
  
    if roundID == round.id then

      events.onStopped:Fire();

    end;

  end);

  return round :: ClientRound;
  
end

local queue = {};

-- Creates a ClientRound object from the current round.
-- Returns a new or cached ClientRound.
function ClientRound.fromServerRound(): ClientRound

  if not serverRound then

    local number = tick();
    table.insert(queue, number);
    while number ~= queue[1] and not serverRound do

      task.wait();
  
    end;

    if not serverRound then

      local roundConstructorProperties = ReplicatedStorage.Shared.Functions.GetRound:InvokeServer();

      local contestants = {}
      for _, contestant in roundConstructorProperties.contestants do

        table.insert(contestants, ClientContestant.new(contestant));

      end;
      roundConstructorProperties.contestants = contestants;

      serverRound = ClientRound.new(roundConstructorProperties);

    end;

    table.remove(queue, 1);

  end;

  return serverRound;

end;

function ClientRound.__index:getContestants(): {types.ClientContestant}

  local contestants = {};
  
  for _, properties in ReplicatedStorage.Shared.Functions.GetRound:InvokeServer().contestants do

    table.insert(contestants, ClientContestant.new(properties));

  end;

  return contestants;

end

return ClientRound;