--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientRound = require(ReplicatedStorage.Client.Interfaces.ClientRound);

local function waitForLocalPlayerContestant(): ()

  local localPlayerContestantInitializedEvent = Instance.new("BindableEvent");

  local function checkContestants()

    local round = ReplicatedStorage.Shared.Functions.GetRound:InvokeServer() :: ClientRound.ClientRound;
    for _, contestantID in round.contestantIDs do

      if contestantID == Players.LocalPlayer.UserId then
    
        localPlayerContestantInitializedEvent:Fire();

      end;

    end;

  end;

  local onContestantAdded = ReplicatedStorage.Shared.Events.ContestantAdded:Connect(checkContestants);
  task.spawn(checkContestants)

  localPlayerContestantInitializedEvent.Event:Wait();

  onContestantAdded:Disconnect();

end;

return waitForLocalPlayerContestant;