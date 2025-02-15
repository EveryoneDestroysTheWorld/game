--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local approachTargetPart = require(script.Parent.approachTargetPart);
local attackContestant = require(script.Parent.attackContestant);
local destroyPart = require(script.Parent.destroyPart);

--[[
  Launches an offense against the contestant's rivals.
]]
local function launchOffense(autopilot: types.AggressiveAutopilot, targetContestant: types.ServerContestant?, targetPart: BasePart?)

  -- Prioritize parts over contestants, unless the contestants attack the user.
  local shouldTargetRival = autopilot.rivalContestantID and targetContestant and targetContestant.id == autopilot.rivalContestantID;
  local targetPrimaryPart = if targetContestant and targetContestant.character then targetContestant.character.PrimaryPart else nil;
  local character = autopilot.contestant.character;
  if not character then return end;

  if targetPrimaryPart and targetContestant and (shouldTargetRival or not targetPart) then

    local isActionInRange = approachTargetPart(character, targetPrimaryPart, 5, 0);
    if isActionInRange then

      attackContestant(autopilot.contestant);

    end;
  
  elseif targetPart then

    local isActionInRange = approachTargetPart(character, targetPart, 5, 0);
    if isActionInRange then

      destroyPart(autopilot.contestant);

    end;

  end;

end;

return launchOffense;