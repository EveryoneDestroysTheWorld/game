--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage");

local ClientEffect = require(ReplicatedStorage.Client.Classes.ClientEffect);
local waitForLocalPlayerContestant = require(ReplicatedStorage.Client.Modules.waitForLocalPlayerContestant);

local contestant = waitForLocalPlayerContestant();

local initializedEffects = {};

ReplicatedStorage.Shared.Functions.ToggleEffect.OnClientInvoke = function(effectID: string, uniqueID: string, shouldEnable: boolean): ()

  if shouldEnable then

    print(contestant.character);
    
    local effectClass = ClientEffect.get(effectID);
    assert(effectClass);

    local effect = effectClass.new({
      contestant = contestant;
    });

    initializedEffects[effectID] = initializedEffects[effectID] or {};
    initializedEffects[effectID][uniqueID] = effect;

    task.spawn(function()
      
      if effect.activate then

        effect.activate(effect);

      end;

    end);

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