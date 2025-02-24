--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function breakdown(self: SharedTypes.DetonateDetachedLimbsClientAction)

  HUDService:removeHUDButton("Action", self.id);
  ContextActionService:UnbindAction("ActivateDetonateDetachedLimbsAction");

end;

return breakdown;