--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local function preloadAnimations(animator: Animator, animations: {[string]: number})

	local animationTracks: {[string]: AnimationTrack} = {}

	for animationName, assetID in pairs(animations) do

		local animation = Instance.new("Animation");
		animation.AnimationId = `rbxassetid://{assetID}`;
		animationTracks[animationName] = animator:LoadAnimation(animation);

	end

	return animationTracks;

end

return preloadAnimations;