--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientActionTypes = require(ReplicatedStorage.Client.Classes.ClientAction.types);

export type RocketFeetClientAction = ClientActionTypes.ClientAction<{
  jumpButtonClickEvent: RBXScriptConnection?;
  cFrameEvent: RBXScriptConnection?;
}>;

return {};