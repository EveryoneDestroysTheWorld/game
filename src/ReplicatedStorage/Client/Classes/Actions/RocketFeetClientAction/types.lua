--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientAction = require(ReplicatedStorage.Client.Interfaces.IClientAction);

export type RocketFeetClientAction = ClientAction.ClientAction<{
  jumpButtonClickEvent: RBXScriptConnection?;
  cFrameEvent: RBXScriptConnection?;
}>;

return {};