--!strict

local ServerStorage = game:GetService("ServerStorage");

local IPitchableBall = require(ServerStorage.Interfaces.IPitchableBall);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

type IPitchableBall = IPitchableBall.IPitchableBall;
type IServerContestant = IServerContestant.IServerContestant;

local RegularBall = {};

function RegularBall.new(pitcher: IServerContestant, contestantList: {IServerContestant}, actionID: string): IPitchableBall

  local function activate(self: IPitchableBall)

    local hitbox = self.model:FindFirstChild("Hitbox");
    assert(hitbox and hitbox:IsA("BasePart"), "Hitbox required");

    hitbox.Touched:Connect(function(part)
    
      -- TODO: Verify that the ball is moving fast.
      local contestant = findContestantFromPart(contestantList, part);
      if contestant and contestant ~= pitcher then

        local attributeName = `{actionID}_{tostring(contestant.id):gsub("%.", "_")}`;
        local latestValidHitTime = self.model:GetAttribute(attributeName);
        local currentHitTime = os.time();
        local duplicateVictimCooldownSeconds = 3;
        if latestValidHitTime and type(latestValidHitTime) == "number" and currentHitTime >= latestValidHitTime + duplicateVictimCooldownSeconds then

          self.model:SetAttribute(attributeName);

        end;

        if not latestValidHitTime then

          self.model:SetAttribute(attributeName, currentHitTime);

          contestant:updateHealth(math.max(contestant.currentHealth - 20, 0), {
            contestantID = pitcher.id;
            actionID = actionID;
          });
          
        end;

      end;

    end);

  end;
  
  local ball = {
    model = script.Ball:Clone();
    activate = activate;
  }

  return ball;

end;

return RegularBall;