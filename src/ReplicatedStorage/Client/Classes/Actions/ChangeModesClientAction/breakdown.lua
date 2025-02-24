--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function breakdown(self: SharedTypes.ChangeModesClientAction)

  ContextActionService:UnbindAction("ActivateChangeModesAction");
	HUDService:removeHUDButton("Action", self.id);

end;

return breakdown;