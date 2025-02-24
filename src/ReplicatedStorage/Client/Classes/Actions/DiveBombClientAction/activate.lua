--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local targetingFramework = require(ReplicatedStorage.Client.Modules.EasyTargetingFramework);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function activate(self: SharedTypes.DiveBombClientAction)

  local coordinates, shouldUseTarget = targetingFramework:getData()
	self.remoteFunction:InvokeServer(coordinates, shouldUseTarget);

end;

return activate;