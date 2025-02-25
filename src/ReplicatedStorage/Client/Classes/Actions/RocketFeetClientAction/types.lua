--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.ClientAction);

export type RocketFeetClientAction = ClientAction.ClientAction<{
  jumpButtonClickEvent: RBXScriptConnection?;
  cFrameEvent: RBXScriptConnection?;
}>;

return {};