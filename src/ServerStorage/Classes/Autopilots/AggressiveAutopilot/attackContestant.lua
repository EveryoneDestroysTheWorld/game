--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerArchetype = require(ServerStorage.Classes.ServerArchetype);
local types = require(ServerStorage.Modules.types);

local findAction = require(script.Parent.findAction);

local function attackContestant(autopilotContestant: types.ServerContestant)

  local archetype = autopilotContestant.archetype;

  if not archetype then

    archetype = ServerArchetype.get("ExplosiveMimic").new({
      contestant = autopilotContestant;
    });

    autopilotContestant:updateArchetype(archetype);

  end

  if archetype then

    local explosivePunchAction = findAction(archetype.actions, "ExplosivePunch");
    if explosivePunchAction then

      local contestantHasEnoughStamina = typeof(explosivePunchAction.requiredStamina) == "number" and autopilotContestant.currentStamina >= explosivePunchAction.requiredStamina;
      if not explosivePunchAction.requiredStamina or contestantHasEnoughStamina then

        explosivePunchAction:activate();

      end;

    end;

  end;

end;

return attackContestant;