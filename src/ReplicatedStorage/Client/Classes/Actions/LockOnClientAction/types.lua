--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type LockOnClientAction = ClientAction.ClientAction<{
  previousTargets: {Instance};
  targetingGUI: BillboardGui;
  shouldLock: boolean;
}>;

return {};