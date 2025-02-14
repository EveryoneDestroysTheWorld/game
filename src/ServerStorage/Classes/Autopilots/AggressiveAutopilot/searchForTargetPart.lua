--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local listVisibleVulnerableParts = require(script.Parent.listVisibleVulnerableParts);
local sortPartsByDistance = require(script.Parent.sortPartsByDistance);

--[[
  Returns a part that the autopilot contestant should target. 
  
  This function only considers parts that are currently visible to the contestant and returns the closest, non-destroyed part.
]]
local function searchForTargetPart(autopilotContestant: types.ServerContestant): BasePart?

  local primaryPart = if autopilotContestant.character then autopilotContestant.character.PrimaryPart else nil;
  if not primaryPart then return end;

  local consideredParts = listVisibleVulnerableParts(autopilotContestant);
  sortPartsByDistance(primaryPart, consideredParts);

  for _, part in consideredParts do

    local currentDurability = part:GetAttribute("CurrentDurability");
    if typeof(currentDurability) == "number" and currentDurability > 0 then

      print("part")
      return part;

    end;

  end;

  return;

end;

return searchForTargetPart;