--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type LockOnClientAction = ClientAction.ClientAction<{
  previousTargets: {Instance};
  targetingGUI: BillboardGui;
  shouldLock: boolean;
}>;

return {};