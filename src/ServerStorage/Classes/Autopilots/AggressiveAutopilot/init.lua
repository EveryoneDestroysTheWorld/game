--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);

local attackContestant = require(script.attackContestant);
local destroyPart = require(script.destroyPart);
local searchForTargetContestant = require(script.searchForTargetContestant);
local searchForTargetPart = require(script.searchForTargetPart);

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

  local archetype = self.contestant.archetype;
  if archetype and archetype.id ~= "Default" then
    
    if archetype.id == "ExplosiveMimic" then
    
      -- Prioritize parts over contestants, unless the contestants attack the user.
      local targetContestant = searchForTargetContestant(self.contestant);
      local targetPart = searchForTargetPart(self.contestant);

      if targetPart then

        destroyPart(self.contestant, targetPart);

      elseif targetContestant then
        
        attackContestant(self.contestant, targetContestant)

      else

        -- TODO: Get out of harm's way to heal?

        -- TODO: Give the bot a hint.

      end;

    end;

  else

    archetype = ServerArchetype.get("ExplosiveMimic").new({
      contestant = self.contestant;
    });

    self.contestant:updateArchetype(archetype);

  end;

end;

return AggressiveAutopilot;