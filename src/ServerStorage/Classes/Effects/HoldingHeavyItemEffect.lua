--!strict
local ServerStorage = game:GetService("ServerStorage");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

local Cause = require(ServerStorage.Types["Cause.types"]);
type Cause = Cause.Cause;
local ServerEffect = require(script.Parent.Parent.ServerEffect);
type ServerEffect = ServerEffect.ServerEffect;
local ServerContestant = require(script.Parent.Parent.ServerContestant);
type ServerContestant = ServerContestant.ServerContestant;

return function(): ServerEffect

  local function toggleClientLocks(contestant: ServerContestant, shouldLock: boolean)

    if contestant.player then

      ReplicatedStorage.Shared.Functions.ToggleActionLock:InvokeClient(contestant.player, shouldLock);
      ReplicatedStorage.Shared.Functions.ToggleArchetypeLock:InvokeClient(contestant.player, shouldLock);
      ReplicatedStorage.Shared.Functions.ToggleItemLock:InvokeClient(contestant.player, shouldLock);

    end;

  end;

  local function activate(effect: ServerEffect, contestant: ServerContestant): ()

    toggleClientLocks(contestant, true);

  end;

  local function deactivate(effect: ServerEffect, contestant: ServerContestant): ()

    toggleClientLocks(contestant, false);

  end;

  return {
    name = "Holding heavy item";
    id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
    activate = activate;
    deactivate = deactivate;
  };

end;