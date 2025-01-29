--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

return function(contestantPlayer: Player, eventContainerType: "Action" | "Item", specificItemID: string): RemoteEvent

  local remoteEvent = Instance.new("RemoteEvent");
  remoteEvent.Name = specificItemID;
  remoteEvent.Parent = if eventContainerType == "Action" then ReplicatedStorage.Shared.Events.ActionEvents else ReplicatedStorage.Shared.Events.ItemEvents;
  return remoteEvent;

end;