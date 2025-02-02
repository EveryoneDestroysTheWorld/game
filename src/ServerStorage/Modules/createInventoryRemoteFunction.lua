--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

return function(contestantPlayer: Player, type: "Item" | "Action", specificItemID: string, onServerInvoke: (...any) -> (...any)): RemoteFunction

  local remoteFunction = Instance.new("RemoteFunction");
  remoteFunction.Name = specificItemID;
  remoteFunction.Parent = if type == "Item" then ReplicatedStorage.Shared.Functions.ItemFunctions else ReplicatedStorage.Shared.Functions.ActionFunctions;
  remoteFunction.OnServerInvoke = function(invokingPlayer: Player, ...: unknown): ()

    if contestantPlayer == invokingPlayer then

      return onServerInvoke(...);

    else

      error(`{invokingPlayer.Name} ({invokingPlayer.UserId}) may not use another player's {type:lower()}.`, 0);

    end

  end;

  return remoteFunction;

end;