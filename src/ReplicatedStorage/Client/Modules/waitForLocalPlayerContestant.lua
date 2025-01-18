--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local types = require(ReplicatedStorage.Client.Classes.types);

local function waitForLocalPlayerContestant(): types.ClientContestant

  local round = ClientRound.fromServerRound();
  local localPlayerContestant;
  local onLocalPlayerContestantPresent = Instance.new("BindableEvent");

  local function checkContestants()

    for _, contestant in round.contestants do

      if contestant.player and contestant.player == Players.LocalPlayer then
    
        localPlayerContestant = contestant;
        onLocalPlayerContestantPresent:Fire();
        break;

      end;

    end;

  end;

  task.spawn(checkContestants)

  local onContestantAdded = round.onContestantAdded:Connect(checkContestants);

  onLocalPlayerContestantPresent.Event:Wait();

  onContestantAdded:Disconnect();

  return localPlayerContestant;

end;

return waitForLocalPlayerContestant;