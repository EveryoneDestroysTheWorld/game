--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local types = require(script.types);

local ParalysisClientEffect = {
  name = "Paralysis";
  id = script.Name:sub(1, script.Name:gsub("ClientEffect", ""):len());
}

function ParalysisClientEffect.new(contestantID: number, uniqueEffectID: string): types.ParalysisClientEffect

  local effect: types.ParalysisClientEffect = {
    name = ParalysisClientEffect.name;
    id = ParalysisClientEffect.id;
    uniqueID = uniqueEffectID;
    contestantID = contestantID;
    remoteFunction = ReplicatedStorage.Shared.Functions.EffectFunctions:FindFirstChild(uniqueEffectID);
    attributes = {
      events = {};
      frozenAnimations = {};
    };
    activate = function(self: types.ParalysisClientEffect)

    end;
    deactivate = function(self: types.ParalysisClientEffect)

    end;
  };

  assert(effect.remoteFunction and effect.remoteFunction:IsA("RemoteFunction"));
  effect.remoteFunction.OnClientInvoke = function()

    effect:activate();

  end;

  return effect;

end;

return ParalysisClientEffect;