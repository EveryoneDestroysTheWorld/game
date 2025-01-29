--!strict

local ServerStorage = game:GetService("ServerStorage");
local PathfindingService = game:GetService("PathfindingService");

local searchForTargetContestant = require(script.searchForTargetContestant);
local searchForTargetPart = require(script.searchForTargetPart);
local healSelf = require(script.healSelf);

local types = require(ServerStorage.Modules.types);

local AggressiveAutopilot = {
  name = "Aggressive";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.AggressiveAutopilot;
};

function AggressiveAutopilot.new(properties: types.AggressiveAutopilotConstructorProperties)

  local autopilot = {
    contestant = properties.contestant;
    name = AggressiveAutopilot.name;
    id = AggressiveAutopilot.id;
  };

  return (setmetatable(autopilot, AggressiveAutopilot) :: unknown) :: types.AggressiveAutopilot

end;

function AggressiveAutopilot.__index:run(): ()

  local character = self.contestant.character;
  if not character then return end;

  if self.contestant.currentHealth > 0 then
    
    local targetContestant = searchForTargetContestant(self.contestant);
    local targetPart = searchForTargetPart(self.contestant);

    if targetPart or targetContestant then

      -- TODO: Choose the part or the contestant as the final target.

    else

      if self.contestant.currentHealth < self.contestant:getModifiedBaseValue("Health") then

        healSelf(self.contestant);
  
      end;

      -- TODO: Give the bot a hint.

    end;

  end;

end;

return AggressiveAutopilot;