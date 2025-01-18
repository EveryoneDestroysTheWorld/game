--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");

return function(contestantPlayer: Player, specificItemID: string): RemoteEvent

  local remoteEvent = Instance.new("RemoteEvent");
  remoteEvent.Name = specificItemID;
  remoteEvent.Parent = ReplicatedStorage.Shared.Events.ItemEvents;
  return remoteEvent;

end;