--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local types = require(ReplicatedStorage.Client.Modules.types);

local function waitForLocalPlayerContestant(): types.ClientContestant

  local round = ClientRound.fromServerRound();
  local localPlayerContestant;

  local function checkContestants()

    for _, contestant in round.contestants do

      if contestant.player and contestant.player == Players.LocalPlayer then
    
        localPlayerContestant = contestant;
        break;

      end;

    end;

  end;

  local onContestantAdded = round.onContestantAdded:Connect(checkContestants);
  task.spawn(checkContestants)

  repeat task.wait() until localPlayerContestant;

  onContestantAdded:Disconnect();

  return localPlayerContestant;

end;

return waitForLocalPlayerContestant;