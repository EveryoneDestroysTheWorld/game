--!strict

local ServerStorage = game:GetService("ServerStorage");

local launchDefense = require(script.launchDefense);
local launchOffense = require(script.launchOffense);
local searchForTargetContestant = require(script.searchForTargetContestant);
local searchForTargetPart = require(script.searchForTargetPart);

local types = require(ServerStorage.Modules.types);

local AggressiveAutopilot = {
  name = "Aggressive";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.AggressiveAutopilot;
};

function AggressiveAutopilot.new(properties: types.AggressiveAutopilotConstructorProperties)

  local autopilot = (setmetatable({}, AggressiveAutopilot) :: unknown) :: types.AggressiveAutopilot;
  autopilot.contestant = properties.contestant;
  autopilot.name = AggressiveAutopilot.name;
  autopilot.id = AggressiveAutopilot.id;
  autopilot.rivalForgivenessMinDelaySeconds = 1;
  autopilot.rivalForgivenessMaxDelaySeconds = 15;
  autopilot.events = {};
  
  table.insert(autopilot.events, autopilot.contestant.onHealthUpdated:Connect(function(_, oldHealth, cause)
  
    if not autopilot.rivalContestantID and autopilot.contestant.currentHealth < oldHealth and cause and cause.contestantID then

      for _, contestant in autopilot.contestant.round.contestants do

        if contestant.id == cause.contestantID then

          if not autopilot.contestant.teamID or contestant.teamID ~= autopilot.contestant.teamID then

            local declarationTime = DateTime.now().UnixTimestamp;
            autopilot.rivalContestantID = cause.contestantID;
            autopilot.rivalDeclaredSeconds = declarationTime;

            local forgivenessDelaySeconds = math.random(autopilot.rivalForgivenessMinDelaySeconds, autopilot.rivalForgivenessMaxDelaySeconds);
            task.delay(forgivenessDelaySeconds, function()
            
              if autopilot.rivalContestantID == cause.contestantID and autopilot.rivalDeclaredSeconds == declarationTime then

                autopilot.rivalContestantID = nil;
                autopilot.rivalDeclaredSeconds = nil;

              end;

            end);

          end;

          break;

        end;

      end;

    end;

  end));

  return autopilot;

end;

function AggressiveAutopilot.__index:run(): ()

  xpcall(function()
  
    if self.contestant.currentHealth > 0 then
    
      local targetDamageContestant = searchForTargetContestant(self, "Rivals");
      local targetDamagePart = searchForTargetPart(self.contestant, "Unclaimed");
      local shouldLaunchOffense = targetDamageContestant or targetDamagePart;
      if shouldLaunchOffense then

        launchOffense(self, targetDamageContestant, targetDamagePart);

      else

        launchDefense(self);

      end;

    else

      -- TODO: Implement Undead Consciousness.

    end;

  end, function(error)
  
    warn(error);
    debug.traceback();

  end);

end;

return AggressiveAutopilot;