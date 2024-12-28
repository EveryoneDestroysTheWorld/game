--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

return function(contestantPlayer: Player, inventoryID: number, onServerInvoke: () -> ()): (RemoteFunction, number)

  local itemName = `{contestantPlayer.UserId}_{inventoryID}`;
  local itemNumber = 1;
  while ReplicatedStorage.Shared.Functions.ItemFunctions:FindFirstChild(`{itemName}_{itemNumber}`) do

    itemNumber += 1;

  end;

  local remoteFunction = Instance.new("RemoteFunction");
  remoteFunction.Name = `{itemName}_{itemNumber}`;
  remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ItemFunctions;
  remoteFunction.OnServerInvoke = function(invokingPlayer: Player, ...: unknown): ()

    if contestantPlayer == invokingPlayer then

      onServerInvoke(...);

    else

      error(`{invokingPlayer.Name} ({invokingPlayer.UserId}) may not use another player's item.`, 0);

    end

  end;

  return remoteFunction, itemNumber;

end;