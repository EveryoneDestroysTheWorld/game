--!strict

local ServerStorage = game:GetService("ServerStorage");

local ServerEffect = require(ServerStorage.Classes.ServerEffect);
local types = require(ServerStorage.Modules.types);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

local function onTouched(action: types.HeresThePitchServerAction, ball: Model, part: BasePart)

  local function electrocuteContestant(contestant: types.ServerContestant)

    local immunitySeconds = 3;
    local attributeName = `{action.id}_LatestElectrocutionTime_{tostring(contestant.id):gsub("%.", "_")}`;
    local latestDamage = ball:GetAttribute(attributeName);
    local currentTime = os.time();
    local isContestantImmune = type(latestDamage) == "number" and latestDamage + immunitySeconds > currentTime;
    if not isContestantImmune then

      ball:SetAttribute(attributeName, currentTime);

      local paralysisEffect = ServerEffect.get("Paralysis").new({
        contestant = contestant;
      })

      contestant:addEffect(paralysisEffect);

      local stunLengthSeconds = 2;
      task.delay(stunLengthSeconds, function()
      
        contestant:removeEffect(paralysisEffect);

      end);

      local electrocutionDamage = 5;
      contestant:updateHealth(math.max(contestant.currentHealth - electrocutionDamage, 0), {
        contestantID = action.contestant.id;
        actionID = action.id;
      });

    end;

  end;

  local contestantList = action.contestant.round.contestants;
  local contestant = findContestantFromPart(contestantList, part);
  if contestant then

    if contestant ~= action.contestant then

      electrocuteContestant(contestant);

    end;

  elseif part.Material == Enum.Material.Metal then

    local touchingParts = workspace:GetPartsInPart(part);
    for _, touchingPart in touchingParts do

      local touchingContestant = findContestantFromPart(contestantList, touchingPart);
      if touchingContestant then

        electrocuteContestant(touchingContestant);

      end;

    end;

  end;

end;

return onTouched;