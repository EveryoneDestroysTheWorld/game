--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function activate(self: SharedTypes.DetonateDetachedLimbsClientAction)

  self.remoteFunction:InvokeServer();

end;

return activate;