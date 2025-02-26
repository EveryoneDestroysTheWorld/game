
--!strict

local ServerStorage = game:GetService("ServerStorage");

local IServerAction = require(ServerStorage.Interfaces.IServerAction);
local SharedTypes = require(ServerStorage.Modules.SharedTypes);

type BallType = SharedTypes.BallType

export type IDetachLimbServerAction = IServerAction.IServerAction<{}, (string)>;

return {};