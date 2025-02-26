--!strict

local ServerStorage = game:GetService("ServerStorage");

local IServerAction = require(ServerStorage.Interfaces.IServerAction);

export type IBeastSlashServerAction = IServerAction.IServerAction<{
  animationTracks: {
    [string]: AnimationTrack;
  };
}>;

return {};