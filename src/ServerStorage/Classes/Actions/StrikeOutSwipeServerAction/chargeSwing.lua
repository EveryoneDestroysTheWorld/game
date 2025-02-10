--!strict

local ServerStorage = game:GetService("ServerStorage");
local types = require(ServerStorage.Modules.types);

--[[
  Charges the contestant's bat before they swing it. The longer the charge, the bigger the WHAM!
]]
local function chargeSwing(action: types.StrikeOutSwipeServerAction): ()

  local originalChargeTime = DateTime.now().UnixTimestampMillis;
  action.startChargeTimeMilliseconds = originalChargeTime;

  task.spawn(function()
	
		while task.wait(0.05) and action.startChargeTimeMilliseconds == originalChargeTime do

			-- local player = action.contestant.player;
			if action.contestant.currentStamina <= 0 then

        -- -- Let the player know to stop charging.
				-- if action.remoteEvent and player then

				-- 	action.remoteEvent:FireClient(player);

				-- end;

				action:activate(false);
				break;

			else

				action.contestant:updateStamina(action.contestant.currentStamina - 1, {
					actionID = action.id;
					contestantID = action.contestant.id;
				});

			end;

		end;

	end);

end;

return chargeSwing;