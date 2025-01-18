--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");

export type Lock = unknown;

export type LockListContainer = {
  [number]: {Lock};
};

local actionLocks: LockListContainer = {};
local archetypeLocks: LockListContainer = {};
local itemLocks: LockListContainer = {};

local function toggleLock(contestantID: number, lockList: LockListContainer, lock: Lock, shouldLock: boolean): ()

  if shouldLock then

    lockList[contestantID] = lockList[contestantID] or {};

    table.insert(lockList[contestantID], lock);

  else

    if lockList[contestantID] then
      
      table.remove(lockList[contestantID], table.find(lockList[contestantID], lock));

      if not lockList[contestantID][1] then

        lockList[contestantID] = nil

      end;

    end;

  end;

end;

ReplicatedStorage.Shared.Functions.GetActionLocks.OnServerInvoke = function(player: Player): {Lock}?

  return actionLocks[player.UserId];

end;

ReplicatedStorage.Shared.Functions.GetArchetypeLocks.OnServerInvoke = function(player: Player): {Lock}?

  return archetypeLocks[player.UserId];

end;

ReplicatedStorage.Shared.Functions.GetItemLocks.OnServerInvoke = function(player: Player): {Lock}?

  return itemLocks[player.UserId];

end;

ServerStorage.Functions.GetActionLocks.OnInvoke = function(contestantID: number): {Lock}?

  return actionLocks[contestantID];

end;

ServerStorage.Functions.GetArchetypeLocks.OnInvoke = function(contestantID: number): {Lock}?

  return archetypeLocks[contestantID];

end;

ServerStorage.Functions.GetItemLocks.OnInvoke = function(contestantID: number): {Lock}?

  return itemLocks[contestantID];

end;

ServerStorage.Functions.ToggleActionLock.OnInvoke = function(contestantID: number, lock: Lock, shouldLock: boolean): ()

  toggleLock(contestantID, actionLocks, lock, shouldLock);

  local player = game.Players:GetPlayerByUserId(contestantID);
  if player then
    
    ReplicatedStorage.Shared.Events.ActionLocksChanged:FireClient(player, actionLocks);

  end;

end;

ServerStorage.Functions.ToggleArchetypeLock.OnInvoke = function(contestantID: number, lock: Lock, shouldLock: boolean): ()

  toggleLock(contestantID, archetypeLocks, lock, shouldLock);
  
  local player = game.Players:GetPlayerByUserId(contestantID);
  if player then

    ReplicatedStorage.Shared.Events.ArchetypeLocksChanged:FireClient(player, archetypeLocks);

  end;

end;

ServerStorage.Functions.ToggleItemLock.OnInvoke = function(contestantID: number, lock: Lock, shouldLock: boolean): ()

  toggleLock(contestantID, itemLocks, lock, shouldLock);

  local player = game.Players:GetPlayerByUserId(contestantID);
  if player then

    ReplicatedStorage.Shared.Events.ItemLocksChanged:FireClient(player, itemLocks);

  end;

end;