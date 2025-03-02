
--!strict

local ServerStorage = game:GetService("ServerStorage");

local IServerAction = require(ServerStorage.Interfaces.IServerAction);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);

type BallType = SharedTypes.BallType

export type ITarBombServerAction = IServerAction.IServerAction<{}, (boolean, Vector3?, boolean?, boolean?)>;

return {};