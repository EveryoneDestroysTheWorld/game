--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local ServerStorage = game:GetService("ServerStorage");
local HttpService = game:GetService("HttpService");

local RagdollService = require(ServerStorage.Modules.RagdollService);
local types = require(ServerStorage.Modules.types);

local ParalysisServerEffect = {
  name = "Paralysis";
  id = script.Name:sub(1, script.Name:gsub("ServerEffect", ""):len());
  __index = {} :: types.ParalysisServerEffect;
}

function ParalysisServerEffect.new(properties: types.ServerEffectConstructorProperties): types.ParalysisServerEffect

  local effect: types.ParalysisServerEffectProperties = {
    name = ParalysisServerEffect.name;
    id = ParalysisServerEffect.id;
    uniqueID = HttpService:GenerateGUID(false);
    contestant = properties.contestant;
    weight = {
      walkSpeed = 0;
      weight = math.huge;
    };
    ragdollKey = {};
    frozenAnimations = {};
  };

  if properties.contestant.player then

    local remoteFunction = Instance.new("RemoteFunction");
    remoteFunction.Parent = ReplicatedStorage.Shared.Functions.EffectFunctions;
    remoteFunction.Name = effect.uniqueID;

    effect.remoteFunction = remoteFunction;

  end;

  return (setmetatable(effect, ParalysisServerEffect) :: unknown) :: types.ParalysisServerEffect

end;

function ParalysisServerEffect.__index:activate()

  self.contestant:addWalkSpeedWeight(self.weight);

  local character = self.contestant.character;
  if self.contestant.player and self.remoteFunction then

    ReplicatedStorage.Shared.Functions.InitializeEffect:InvokeClient(self.contestant.player, self.id, self.uniqueID, true);
    self.remoteFunction:InvokeClient(self.contestant.player);

  end;

  -- Tip the player.
  if character then

    RagdollService:ragdollCharacter(character, self.ragdollKey, self.contestant.player)

  end;

end;

function ParalysisServerEffect.__index:breakdown()

  self.contestant:removeWalkSpeedWeight(self.weight);

  local character = self.contestant.character;
  if character then

    RagdollService:restoreCharacter(character, self.ragdollKey, self.contestant.player);

  end;

  if self.contestant.player then

    ReplicatedStorage.Shared.Functions.InitializeEffect:InvokeClient(self.contestant.player, self.id, self.uniqueID, false);

  end;

  if self.remoteFunction then

    self.remoteFunction:Destroy();

  end;

end;

return ParalysisServerEffect;