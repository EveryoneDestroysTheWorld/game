--!strict

local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
local types = require(ReplicatedStorage.Client.Classes.types);

local function waitForLocalPlayerContestant(): types.ClientContestant

  local round = ClientRound.fromServerRound();
  local onLocalPlayerContestantPresent = Instance.new("BindableEvent");

  local function checkContestant(contestant)

    if contestant.player and contestant.player == Players.LocalPlayer then
  
      onLocalPlayerContestantPresent:Fire(contestant);

    end;

  end;

  task.spawn(function()
  
    for _, contestant in round.contestants do

      checkContestant(contestant);
  
    end;

  end)

  local onContestantAdded = round.onContestantAdded:Connect(checkContestant);

  local playerContestant = onLocalPlayerContestantPresent.Event:Wait();

  print(playerContestant);

  onContestantAdded:Disconnect();

  return playerContestant;

end;

return waitForLocalPlayerContestant;