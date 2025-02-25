--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientActionTypes = require(ReplicatedStorage.Client.Classes.ClientAction.types);

export type LockOnClientAction = ClientActionTypes.ClientAction<{
  previousTargets: {Instance};
  targetingGUI: BillboardGui;
  shouldLock: boolean;
}>;

return {};