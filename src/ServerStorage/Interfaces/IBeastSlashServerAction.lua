--!strict

local ServerStorage = game:GetService("ServerStorage");

local IServerAction = require(ServerStorage.Interfaces.IServerAction);

type Attributes = {
  animationTracks: {
    [string]: AnimationTrack;
  };
};

export type IBeastSlashServerAction = IServerAction.IServerAction<Attributes>;

return {};