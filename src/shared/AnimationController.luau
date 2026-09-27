local AnimationController = {}

function AnimationController.SetBaseAnimationsEnabled(character: Model, enabled: boolean)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then return end

	-- Freeze or resume all currently playing default tracks
	for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
		if enabled then
			track:AdjustSpeed(1)
		else
			track:AdjustSpeed(0)
		end
	end
end

return AnimationController
