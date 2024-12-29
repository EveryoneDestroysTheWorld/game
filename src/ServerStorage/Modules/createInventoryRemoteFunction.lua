--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

return function(contestantPlayer: Player, specificItemID: string, onServerInvoke: (...unknown) -> (...unknown)): RemoteFunction

  local remoteFunction = Instance.new("RemoteFunction");
  remoteFunction.Name = specificItemID;
  remoteFunction.Parent = ReplicatedStorage.Shared.Functions.ItemFunctions;
  remoteFunction.OnServerInvoke = function(invokingPlayer: Player, ...: unknown): ()

    if contestantPlayer == invokingPlayer then

      onServerInvoke(...);

    else

      error(`{invokingPlayer.Name} ({invokingPlayer.UserId}) may not use another player's item.`, 0);

    end

  end;

  return remoteFunction;

end;