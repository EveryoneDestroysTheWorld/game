--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function activate(self: SharedTypes.ChangeModesClientAction)

  local requestedMode: SharedTypes.BatterUpDemonMode = if self.attributes.currentMode == "Pitcher" then "Batter" else "Pitcher";
  self.remoteFunction:InvokeServer(requestedMode);
  self.attributes.currentMode = requestedMode;

end;

return activate;