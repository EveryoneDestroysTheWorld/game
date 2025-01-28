--!strict
-- Programmers: Hati (hati_bati) and Christian Toney (Christian_Toney)
-- Designer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local function preloadAnimations(humanoid: Humanoid, animations: {[string]: string})

	local animator = humanoid:FindFirstChild("Animator") :: Animator;
	local animationTracks: {[string]: AnimationTrack} = {}

	for animationName, assetID in pairs(animations) do

		local animation = Instance.new("Animation");
		animation.AnimationId = `rbxassetid://{assetID}`;
		animationTracks[animationName] = animator:LoadAnimation(animation);

	end

	return animationTracks;

end

return preloadAnimations;