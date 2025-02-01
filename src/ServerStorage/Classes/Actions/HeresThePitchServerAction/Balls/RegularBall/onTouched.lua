--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function onTouched(action: types.HeresThePitchServerAction, ball: BasePart, part: BasePart)

  -- TODO: Verify that the ball is moving fast.
  local possibleContestantModel = part:FindFirstAncestorOfClass("Model");
  local didFindValidModel = possibleContestantModel and possibleContestantModel ~= action.contestant.character;
  if didFindValidModel then

    for _, contestant in action.contestant.round.contestants do

      if contestant.character == possibleContestantModel then

        local attributeName = `{action.id}_{tostring(contestant.id):gsub("%.", "_")}`;
        local latestValidHitTime = ball:GetAttribute(attributeName);
        local currentHitTime = os.time();
        local duplicateVictimCooldownSeconds = 3;
        if latestValidHitTime and type(latestValidHitTime) == "number" and currentHitTime >= latestValidHitTime + duplicateVictimCooldownSeconds then

          ball:SetAttribute(attributeName);

        end;

        if not latestValidHitTime then

          ball:SetAttribute(attributeName, currentHitTime);

          contestant:updateHealth(math.max(contestant.currentHealth - 20, 0), {
            contestantID = action.contestant.id;
            actionID = action.id;
          });
          
        end;

        break;

      end;

    end;

  end;

end;

return onTouched;