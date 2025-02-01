--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local function onTouched(action: types.HeresThePitchServerAction, ball: BasePart, part: BasePart)

  -- The ball shouldn't stick to other parts after being initially glued.
  if ball:FindFirstChild("WeldConstraint") then

    return;

  end;

  local weldImmunityAttributeName = `{action.id}_WeldImmunity`;
  if not ball:FindFirstChild("WeldConstraint") and (not action.contestant.character or not part:IsDescendantOf(action.contestant.character)) then

    -- Stick the ball to the part.
    local function createWeldConstraint(): WeldConstraint

      local weldConstraint = Instance.new("WeldConstraint");
      weldConstraint.Part1 = part;
      weldConstraint.Part0 = ball;
      weldConstraint.Parent = ball;

      return weldConstraint;

    end;
    
    -- Create a poisonous cloud that damages everyone nearby.
    local function createPoisonousCloud()

    end;
    
    -- Especially damage contestants who are glued to the ball.
    local didFindContestant = false;
    local possibleContestantModel = part:FindFirstAncestorOfClass("Model");
    if possibleContestantModel then

      for _, contestant in action.contestant.round.contestants do

        if contestant.character == possibleContestantModel then

          didFindContestant = true;

          local immuneContestantID = ball:GetAttribute(weldImmunityAttributeName);
          if contestant.id ~= immuneContestantID then

            local weldConstraint = createWeldConstraint();

            for i = 1, 100 do

              contestant:updateHealth(math.max(contestant.currentHealth - 0.05, 0), {
                contestantID = action.contestant.id;
                actionID = action.id;
              });

              task.wait(0.05);

            end;

            ball:SetAttribute(weldImmunityAttributeName, contestant.id);

            weldConstraint:Destroy();

            break;

          end;

        end;

      end;

    end

    if not didFindContestant then

      createWeldConstraint();

    end;

  end;

end;

return onTouched;