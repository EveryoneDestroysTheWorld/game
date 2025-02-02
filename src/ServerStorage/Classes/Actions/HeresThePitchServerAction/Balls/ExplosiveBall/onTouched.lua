--!strict

local ServerStorage = game:GetService("ServerStorage");

local RagdollService = require(ServerStorage.Modules.RagdollService);
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
      explosion.BlastPressure = 0;
      explosion.DestroyJointRadiusPercent = 0;
      explosion.Hit:Connect(function(hitPart: BasePart)

        local contestant = findContestantFromPart(action.contestant.round.contestants, hitPart);
        if contestant and not table.find(immuneContestants, contestant) then

          table.insert(immuneContestants, contestant);

          contestant:updateHealth(math.max(contestant.currentHealth - 15, 0), {
            contestantID = action.contestant.id;
            actionID = action.id;
          });

          local character = contestant.character;
          local primaryPart = if contestant.character then contestant.character.PrimaryPart else nil;
          local humanoid = if contestant.character then contestant.character:FindFirstChild("Humanoid") else nil;
          if character and primaryPart and humanoid and humanoid:IsA("Humanoid") then

            local ragdollKey = {};
            RagdollService:ragdollCharacter(character, ragdollKey);

            primaryPart.AssemblyLinearVelocity += primaryPart.CFrame:VectorToObjectSpace(primaryPart.Position - explosion.Position) * 500;

            task.delay(1, function()
            
              RagdollService:restoreCharacter(character, ragdollKey);

            end);

          else
  
            local force = hitPart.CFrame:VectorToObjectSpace(hitPart.Position - explosion.Position) * 500;
            hitPart:ApplyImpulse(force);

          end;

        end;
        
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