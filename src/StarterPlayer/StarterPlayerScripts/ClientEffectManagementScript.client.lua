--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientEffect = require(ReplicatedStorage.Client.Classes.ClientEffect);
local waitForLocalPlayerContestant = require(ReplicatedStorage.Client.Modules.waitForLocalPlayerContestant);

local contestant = waitForLocalPlayerContestant();

local initializedEffects = {};

ReplicatedStorage.Shared.Functions.InitializeEffect.OnClientInvoke = function(effectID: string, uniqueID: string, shouldEnable: boolean): ()

  if shouldEnable then
    
    local effectClass = ClientEffect.get(effectID);
    assert(effectClass);

    local effect = effectClass.new({
      contestant = contestant;
      uniqueID = uniqueID;
    });

    initializedEffects[effectID] = initializedEffects[effectID] or {};
    initializedEffects[effectID][uniqueID] = effect;

  else

    local effect = if initializedEffects[effectID] then initializedEffects[effectID][uniqueID] else nil;
    if effect then

      if effect.deactivate then

        effect.deactivate(effect);

      end;

      initializedEffects[effectID][uniqueID] = nil;

    end;

  end;

end;