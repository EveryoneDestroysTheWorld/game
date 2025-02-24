--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ContextActionService = game:GetService("ContextActionService");

local HUDService = require(ReplicatedStorage.Client.Modules.HUDService);
local SharedTypes = require(ReplicatedStorage.Client.Modules.SharedTypes);

local function breakdown(self: SharedTypes.DetachLimbClientAction)

  if self.attributes.gui then

    self.attributes.gui:Destroy();
    self.attributes.gui = nil;
    
  end;

  ContextActionService:UnbindAction("ActivateDetachLimbAction");
  HUDService:removeHUDButton("Action", self.id);

end;

return breakdown;