--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ParalysisClientEffect = require(ReplicatedStorage.Client.Classes.Effects.ParalysisClientEffect);
local ClientEffectFactoryTypes = require(script.types);

local ClientEffectFactory = {};

-- Returns a ServerItem based on the ID.
function ClientEffectFactory.get(effectID: string): ClientEffectFactoryTypes.ClientEffectClass

  local effects = {
    Paralysis = ParalysisClientEffect;
  };

  local effect = effects[effectID];
  
  if not effect then

    error(`{effectID} client archetype couldn't be found.`);

  end;

  return effect;

end;

return ClientEffectFactory;