--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientActionTypes = require(ReplicatedStorage.Client.Classes.ClientAction.types);

export type ChangeBallTypeClientAction = ClientActionTypes.ClientAction<{
  gui: ScreenGui?;
}>;

return {};