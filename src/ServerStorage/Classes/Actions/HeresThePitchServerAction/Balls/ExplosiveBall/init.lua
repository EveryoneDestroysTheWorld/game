--!strict

local ServerStorage = game:GetService("ServerStorage");

local IPitchableBall = require(ServerStorage.Interfaces.IPitchableBall);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);
local RagdollService = require(ServerStorage.Modules.RagdollService);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

type IPitchableBall = IPitchableBall.IPitchableBall;
type IServerContestant = IServerContestant.IServerContestant;

local ExplosiveBall = {};

function ExplosiveBall.new(pitcher: IServerContestant, contestantList: {IServerContestant}, actionID: string): IPitchableBall

  local function activate(self: IPitchableBall)

    local hitbox = self.model:FindFirstChild("Hitbox");
    assert(hitbox and hitbox:IsA("BasePart"), "Hitbox required");

    hitbox.Touched:Connect(function(part)
    
      local function detonateBall()

        if self.model.Parent then
  
          local mesh = self.model.PrimaryPart;
          assert(mesh);
  
          local ballPosition = mesh.Position;
          self.model:Destroy();
  
          -- TODO: Implement custom explosion.
          local immuneContestants = {};
          local explosion = Instance.new("Explosion");
          explosion.Position = ballPosition;
          explosion.BlastPressure = 0;
          explosion.DestroyJointRadiusPercent = 0;
          explosion.Hit:Connect(function(hitPart: BasePart)
  
            local contestant = findContestantFromPart(contestantList, hitPart);
            if contestant and not table.find(immuneContestants, contestant) then
  
              table.insert(immuneContestants, contestant);
  
              contestant:updateHealth(math.max(contestant.currentHealth - 15, 0), {
                contestantID = pitcher.id;
                actionID = actionID;
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
      local contestant = findContestantFromPart(contestantList, part);
      if contestant then
  
        if contestant ~= pitcher then
  
          contestant:updateHealth(math.max(contestant.currentHealth - 5, 0), {
            contestantID = pitcher.id;
            actionID = actionID;
          });
  
          detonateBall();
  
        end;
  
      else
  
        detonateBall();
  
      end;

    end);

  end;

  local ball = {
    model = script.Ball:Clone();
    activate = activate;
  }

  return ball;

end;

return ExplosiveBall;