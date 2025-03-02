--!strict

local ServerStorage = game:GetService("ServerStorage");
local TweenService = game:GetService("TweenService");

local ParalysisServerEffect = require(ServerStorage.Classes.Effects.ParalysisServerEffect);
local IPitchableBall = require(ServerStorage.Interfaces.IPitchableBall);
local IServerContestant = require(ServerStorage.Interfaces.IServerContestant);

local findContestantFromPart = require(ServerStorage.Modules.findContestantFromPart);

type IPitchableBall = IPitchableBall.IPitchableBall;
type IServerContestant = IServerContestant.IServerContestant;

local ElectricBall = {};

function ElectricBall.new(pitcher: IServerContestant, contestantList: {IServerContestant}, actionID: string): IPitchableBall

  local model = script.Ball:Clone();

  local function activate()

    local hitbox = model:FindFirstChild("Hitbox");
    assert(hitbox and hitbox:IsA("BasePart"), "Hitbox required");

    hitbox.Touched:Connect(function(part)

      local function createHighlight(instance: BasePart | Model)

        local highlight = Instance.new("Highlight");
        highlight.FillColor = Color3.fromRGB(237, 255, 43);
        highlight.FillTransparency = if instance:IsA("BasePart") then 0.9 else 0;
        highlight.DepthMode = Enum.HighlightDepthMode.Occluded;
        highlight.OutlineColor = Color3.new(1, 1, 1);
        highlight.OutlineTransparency = 0;
        highlight.Parent = instance;
    
        local tween = TweenService:Create(highlight, TweenInfo.new(), {
          FillTransparency = 1;
          OutlineTransparency = 1;
        });
    
        tween.Completed:Once(function()
        
          highlight:Destroy();
    
        end);
    
        tween:Play();
    
      end;
    
      local function electrocuteContestant(contestant: IServerContestant)
    
        local immunitySeconds = 3;
        local attributeName = `{actionID}_LatestElectrocutionTime`;
        local latestDamage = contestant.attributes[attributeName];
        local currentTime = os.time();
        local isContestantImmune = type(latestDamage) == "number" and latestDamage + immunitySeconds > currentTime;
        if not isContestantImmune then
    
          contestant.attributes[attributeName] = currentTime;
    
          local paralysisEffect = ParalysisServerEffect.new({
            contestant = contestant;
          })
    
          contestant:addEffect(paralysisEffect);
    
          local stunLengthSeconds = 2;
          task.delay(stunLengthSeconds, function()
          
            contestant:removeEffect(paralysisEffect);
    
          end);
    
          local electrocutionDamage = 5;
          contestant:setCurrentHealth(math.max(contestant.currentHealth - electrocutionDamage, 0), {
            contestantID = pitcher.id;
            actionID = actionID;
          });
    
          if contestant.character then
    
            createHighlight(contestant.character);
    
          end
    
        end;
    
      end;
    
      local contestant = findContestantFromPart(contestantList, part);
      if contestant then
    
        if contestant ~= pitcher then
    
          electrocuteContestant(contestant);
    
        end;
    
      elseif part.Material == Enum.Material.Metal then
    
        createHighlight(part);
    
        local touchingParts = workspace:GetPartsInPart(part);
        for _, touchingPart in touchingParts do
    
          local touchingContestant = findContestantFromPart(contestantList, touchingPart);
          if touchingContestant then
    
            electrocuteContestant(touchingContestant);
    
          end;
    
        end;
    
      end;

    end);

  end;

  local ball = {
    model = model;
    activate = activate;
  }

  return ball;

end;

return ElectricBall;