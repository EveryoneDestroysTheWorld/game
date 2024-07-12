--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ClientContestant = require(script.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type RoundStatus = "Waiting for players" | "Contestant selection";

export type RoundProperties = {
  ID: string;  
  
  -- This stage's ID.
  stageID: string;

  timeStarted: number?;

  duration: number?;

  timeEnded: number?;

  status: RoundStatus;

  contestants: {ClientContestant};
}

local ClientRound = {
  __index = {};
};

export type RoundEvents = {
  onContestantAdded: RBXScriptSignal;
  onContestantRemoved: RBXScriptSignal;
  onEnded: RBXScriptSignal;
  onStatusChanged: RBXScriptSignal;
}

export type ClientRound = typeof(setmetatable({}, ClientRound)) & RoundProperties & RoundEvents;

function ClientRound.new(properties: RoundProperties): ClientRound

  local round = properties;

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onEnded", "onStatusChanged", "onContestantAdded", "onContestantRemoved"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    round[eventName] = events[eventName].Event;

  end

  ReplicatedStorage.Shared.Events.ContestantAdded.OnClientEvent:Connect(function(roundID: string, contestant: ClientContestant)
  
    table.insert(round.contestants, contestant);
    events.onContestantAdded:Fire(contestant);

  end);

  ReplicatedStorage.Shared.Events.ContestantRemoved.OnClientEvent:Connect(function(roundID: string, contestant: ClientContestant)
  
    table.remove(round.contestants, table.find(round.contestants, contestant));
    events.onContestantRemoved:Fire(contestant);

  end);

  ReplicatedStorage.Shared.Events.RoundStatusChanged.OnClientEvent:Connect(function(roundID: string, newStatus: RoundStatus, oldStatus: RoundStatus)
  
    round.status = newStatus;
    events.onStatusChanged:Fire(newStatus, oldStatus);

  end);

  ReplicatedStorage.Shared.Events.RoundEnded.OnClientEvent:Connect(function(roundID: string)
  
    if roundID == round.ID then

      events.onEnded:Fire();

    end;

  end);

  return setmetatable(round, ClientRound) :: ClientRound;
  
end

return ClientRound;