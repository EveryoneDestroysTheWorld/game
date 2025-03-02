--!strict

local RunService = game:GetService("RunService");
local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local IPitchableBall = require(ServerStorage.Interfaces.IPitchableBall);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

type IPitchableBall = IPitchableBall.IPitchableBall;
type IServerContestant = IServerContestant.IServerContestant;

local PoisonBall = {};

function PoisonBall.new(pitcher: IServerContestant, contestantList: {IServerContestant}, actionID: string): IPitchableBall

  local function activate(self: IPitchableBall)

    local hitbox = self.model:FindFirstChild("Hitbox");
    assert(hitbox and hitbox:IsA("BasePart"), "Hitbox required");

    hitbox.Touched:Connect(function(part)

      -- The ball shouldn't stick to other parts after being initially glued.
      local mesh = self.model:FindFirstChild("Mesh");
      assert(mesh and mesh:IsA("BasePart"));

      if mesh:FindFirstChild("WeldConstraint") then

        return;

      end;

      if part.Name ~= "Hitbox" and (not pitcher.character or not part:IsDescendantOf(pitcher.character)) and not part:IsDescendantOf(self.model) then

        -- Create a poisonous cloud that damages everyone nearby.
        local hitboxEvent;

        local function createPoisonousCloud()

          local hitbox = self.model:FindFirstChild("Hitbox");
          assert(hitbox and hitbox:IsA("BasePart"));

          local victimHistory = {};
          hitboxEvent = RunService.Heartbeat:Connect(function()
          
            for _, poisonedPart in workspace:GetPartsInPart(hitbox) do

              if not part:IsDescendantOf(self.model) then

                task.spawn(function()

                  local contestant = findContestantFromPart(contestantList, poisonedPart);
                  if contestant then

                    local immunityMilliseconds = 1000;
                    local latestAttackTime = victimHistory[contestant.id] or 0;
                    local currentTimeMilliseconds = DateTime.now().UnixTimestampMillis;
                    local canAttack = latestAttackTime + immunityMilliseconds < currentTimeMilliseconds;
                    if canAttack then

                      victimHistory[contestant.id] = currentTimeMilliseconds;

                      contestant:updateHealth(math.max(contestant.currentHealth - 2, 0), {
                        actionID = actionID;
                        contestantID = pitcher.id;
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
        local weldImmunityAttributeName = `{actionID}_WeldImmunity`;
        local contestant = findContestantFromPart(contestantList, part);
        if contestant and contestant.character then

          local immuneContestantID = self.model:GetAttribute(weldImmunityAttributeName);
          if contestant.id ~= immuneContestantID then

            local weldConstraint = createWeldConstraint();

            for i = 1, 100 do

              contestant:updateHealth(math.max(contestant.currentHealth - 0.05, 0), {
                contestantID = pitcher.id;
                actionID = actionID;
              });

              task.wait(0.05);

            end;

            self.model:SetAttribute(weldImmunityAttributeName, contestant.id);

            hitboxEvent:Disconnect();
            weldConstraint:Destroy();

          end;

        else

          createWeldConstraint();

        end;

      end;

    end);

  end;

  local ball = {
    model = script.Ball:Clone();
    activate = activate;
  };

  return ball;

end;

return PoisonBall;