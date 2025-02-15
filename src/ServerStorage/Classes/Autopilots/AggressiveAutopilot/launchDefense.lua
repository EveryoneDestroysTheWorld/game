--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local approachTargetPart = require(script.Parent.approachTargetPart);
local searchForTargetContestant = require(script.Parent.searchForTargetContestant);
local searchForTargetPart = require(script.Parent.searchForTargetPart);

--[[
  Launches a defense for the contestant.
]]
local function launchDefense(autopilot: types.AggressiveAutopilot)

  local targetReviveContestant = searchForTargetContestant(autopilot, "Allies");
  local targetPrimaryPart = if targetReviveContestant and targetReviveContestant.character then targetReviveContestant.character.PrimaryPart else nil;
  local targetRestorePart = searchForTargetPart(autopilot.contestant, "RivalClaims");
  local character = autopilot.contestant.character;
  if not character then return end;

  if targetReviveContestant and targetPrimaryPart then

    local isActionInRange = approachTargetPart(character, targetPrimaryPart, 5, 0);
    if isActionInRange then

      targetReviveContestant:updateHealth(targetReviveContestant:getModifiedBaseValue("Health") / 2, {
        contestantID = autopilot.contestant.id;
      });

    end;
    
  elseif targetRestorePart then

    local isActionInRange = approachTargetPart(character, targetRestorePart, 5, 0);
    local baseDurability = targetRestorePart:GetAttribute("BaseDurability");
    if isActionInRange and typeof(baseDurability) == "number" then

      ServerStorage.Functions.ModifyPartCurrentDurability:Invoke(targetRestorePart, baseDurability, {
        contestantID = autopilot.contestant.id
      });

    end;

  else

    -- TODO: Patrol until they find someone or something. Include Undead Consciousness users.
    -- Note to developers: Do not directly tell the autopilot where the enemy is.

  end;

end;

return launchDefense;