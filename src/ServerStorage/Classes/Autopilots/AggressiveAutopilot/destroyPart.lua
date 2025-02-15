--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);
local types = require(ServerStorage.Modules.types);

local findAction = require(script.Parent.findAction);

local function destroyPart(autopilotContestant: types.ServerContestant)

  local archetype = autopilotContestant.archetype;
  
  if not archetype then

    archetype = ServerArchetype.get("ExplosiveMimic").new({
      contestant = autopilotContestant;
    });

    autopilotContestant:updateArchetype(archetype);

  end

  if archetype then

    local rocketFeetAction = findAction(archetype.actions, "RocketFeet");
    if rocketFeetAction then

      rocketFeetAction:activate();

    end;

  end;

end;

return destroyPart;