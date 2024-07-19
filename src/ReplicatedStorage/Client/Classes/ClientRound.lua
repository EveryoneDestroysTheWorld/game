--!strict
-- Written by Christian Toney (Sudobeast)
-- This module represents an Archetype, which contains a list of powers.
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ClientContestant = require(script.Parent.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;

export type RoundStatus = "Waiting for players" | "Contestant selection" | "Matchup preview";

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

local defaultRound: ClientRound;

function ClientRound.new(properties: RoundProperties): ClientRound

  local round = setmetatable(properties, ClientRound);

  -- Set up events.
  local events: {[string]: BindableEvent} = {};
  local eventNames = {"onEnded", "onStatusChanged", "onContestantAdded", "onContestantRemoved"};
  for _, eventName in ipairs(eventNames) do

    events[eventName] = Instance.new("BindableEvent");
    round[eventName] = events[eventName].Event;

  end

  ReplicatedStorage.Shared.Events.ContestantAdded.OnClientEvent:Connect(function(roundID: string, contestantProperties: ClientContestant.ClientContestantProperties)
  
    local contestant = ClientContestant.new(contestantProperties);
    table.insert(round.contestants, contestant);
    events.onContestantAdded:Fire(contestant);

  end);

  ReplicatedStorage.Shared.Events.ContestantRemoved.OnClientEvent:Connect(function(roundID: string, contestantID: number)
  
    for index, contestant in ipairs(round.contestants) do

      if contestant.ID == contestantID then

        table.remove(round.contestants, index);
        events.onContestantRemoved:Fire(contestant);
        break;

      end;

    end;

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

  return round :: ClientRound;
  
end

function ClientRound.get(): ClientRound

  if defaultRound then

    return defaultRound;

  end;

  local roundConstructorProperties = ReplicatedStorage.Shared.Functions.GetRound:InvokeServer();

  local contestants = {}
  for _, contestant in ipairs(roundConstructorProperties.contestants) do

    table.insert(contestants, ClientContestant.new(contestant));

  end;
  roundConstructorProperties.contestants = contestants;

  local round = ClientRound.new(roundConstructorProperties);
  defaultRound = round;
  return round;

end;

return ClientRound;