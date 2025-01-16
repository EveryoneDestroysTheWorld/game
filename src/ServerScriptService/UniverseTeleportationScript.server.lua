--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local TeleportService = game:GetService("TeleportService");
local ServerStorage = game:GetService("ServerStorage");
local RunService = game:GetService("RunService");

local places = require(ServerStorage.PlaceMap) :: {[string]: number};

ReplicatedStorage.Shared.Functions.TeleportToArena.OnServerInvoke = function(player: Player)

  assert(not RunService:IsStudio(), "Roblox currently doesn't allow Studio players to teleport to other servers.");

  TeleportService:TeleportAsync(places.arena, {player});

end;