--!strict

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Modules.types);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

local function onTouched(action: types.HeresThePitchServerAction, ball: Model, part: BasePart)

  local function detonateBall()

    if ball.Parent then

      local mesh = ball.PrimaryPart;
      assert(mesh);

      local ballPosition = mesh.Position;
      ball:Destroy();

      -- TODO: Implement custom explosion.
      local immuneContestants = {};
      local explosion = Instance.new("Explosion");
      explosion.Position = ballPosition;
      explosion.DestroyJointRadiusPercent = 0;
      explosion.Hit:Connect(function(hitPart: BasePart)

        local contestant = findContestantFromPart(action.contestant.round.contestants, hitPart);
        if not contestant or table.find(immuneContestants, contestant) then

          return;

        end;

        table.insert(immuneContestants, contestant);

        contestant:updateHealth(math.max(contestant.currentHealth - 15, 0), {
          contestantID = action.contestant.id;
          actionID = action.id;
        });
      
      end);
      explosion.Parent = workspace;

    end;

  end;

  -- Any contestant hit with the ball should take extra bludgeoning damage.
  local contestant = findContestantFromPart(action.contestant.round.contestants, part);
  if contestant then

    if contestant ~= action.contestant then

      contestant:updateHealth(math.max(contestant.currentHealth - 5, 0), {
        contestantID = action.contestant.id;
        actionID = action.id;
      });

      detonateBall();

    end;

  else

    detonateBall();

  end;

end;

return onTouched;