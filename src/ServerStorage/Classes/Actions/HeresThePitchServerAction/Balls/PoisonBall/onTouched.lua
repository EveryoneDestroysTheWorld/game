--!strict

local RunService = game:GetService("RunService");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local types = require(ServerStorage.Modules.types);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

local function onTouched(action: types.HeresThePitchServerAction, ball: Model, part: BasePart)

  -- The ball shouldn't stick to other parts after being initially glued.
  local mesh = ball:FindFirstChild("Mesh");
  assert(mesh and mesh:IsA("BasePart"));

  if mesh:FindFirstChild("WeldConstraint") then

    return;

  end;

  if part.Name ~= "Hitbox" and (not action.contestant.character or not part:IsDescendantOf(action.contestant.character)) and not part:IsDescendantOf(ball) then

    -- Create a poisonous cloud that damages everyone nearby.
    local hitboxEvent;

    local function createPoisonousCloud()

      local hitbox = ball:FindFirstChild("Hitbox");
      assert(hitbox and hitbox:IsA("BasePart"));

      local victimHistory = {};
      hitboxEvent = RunService.Heartbeat:Connect(function()
      
        for _, poisonedPart in workspace:GetPartsInPart(hitbox) do

          if not part:IsDescendantOf(ball) then

            task.spawn(function()

              local contestant = findContestantFromPart(action.contestant.round.contestants, poisonedPart);
              if contestant then

                local immunityMilliseconds = 1000;
                local latestAttackTime = victimHistory[contestant.id] or 0;
                local currentTimeMilliseconds = DateTime.now().UnixTimestampMillis;
                local canAttack = latestAttackTime + immunityMilliseconds < currentTimeMilliseconds;
                if canAttack then

                  victimHistory[contestant.id] = currentTimeMilliseconds;

                  contestant:updateHealth(math.max(contestant.currentHealth - 2, 0), {
                    actionID = action.id;
                    contestantID = action.contestant.id;
                  });

                end;

              end;

            end);

          end;

        end;

      end);

      -- TODO: Run this animation on the client.
      TweenService:Create(hitbox, TweenInfo.new(), {
        Transparency = 0.3;
      }):Play();

    end;

    -- Stick the ball to the part.
    local function createWeldConstraint(): WeldConstraint

      local weldConstraint = Instance.new("WeldConstraint");
      weldConstraint.Part1 = part;
      weldConstraint.Part0 = mesh;
      weldConstraint.Parent = mesh;

      createPoisonousCloud();

      return weldConstraint;

    end;
    
    -- Especially damage contestants who are glued to the ball.
    local weldImmunityAttributeName = `{action.id}_WeldImmunity`;
    local contestant = findContestantFromPart(action.contestant.round.contestants, part);
    if contestant and contestant.character then

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

        hitboxEvent:Disconnect();
        weldConstraint:Destroy();

      end;

    else

      createWeldConstraint();

    end;

  end;

end;

return onTouched;