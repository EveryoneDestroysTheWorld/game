--!strict
-- Programmer: Hati (hati_bati)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ServerStorage = game:GetService("ServerStorage");

local types = require(ServerStorage.Classes.types);

local function animateFlight(action: types.TakeFlightServerAction, primaryPart: BasePart, animData: Vector3, isEndingFlight: boolean)

	action.animationTracks.right:Play(animData.X, animData.Y, animData.Z);
	action.animationTracks.left:Play(animData.X, animData.Y, animData.Z);

	if isEndingFlight then

		action.animationTracks.rightIdle:Stop(0.1)
		action.animationTracks.leftIdle:Stop(0.1)
		action.animationTracks.idle:Stop(0.1)
		action.animationTracks["end"]:Play(0.1,1,0.8)
		task.wait(0.3)
		action.animationTracks["end"]:AdjustWeight(0.01, 0.5)

	else
		action.animationTracks.start:Play(0.1,1,1.8)
		task.wait(0.5)
		action.animationTracks.start:AdjustWeight(0.01, 0.5)
		action.animationTracks.idle:Play(0.5, 1, 1.2)
		action.animationTracks.rightIdle:Play(0.5, 1, 1.2)
		action.animationTracks.leftIdle:Play(0.5, 1, 1.2)
		task.wait(0.3)

		local flightConstraint = primaryPart:FindFirstChild("FlightConstraint");
		if flightConstraint then

			flightConstraint.Destroying:Once(function(change)
				
				action.animationTracks.rightIdle:Stop(0.3)
				action.animationTracks.leftIdle:Stop(0.3)
				action.animationTracks.idle:Stop(0.3)

			end)

		end;

	end

end

return animateFlight;