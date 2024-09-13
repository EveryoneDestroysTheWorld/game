--!strict
return function(character: Model): Model

  character.Archivable = true;
  local ragdollModel = character:Clone();

  for index,joint in pairs(ragdollModel:GetDescendants()) do

    if joint:IsA("Motor6D") then

      local socket = Instance.new("BallSocketConstraint");
      local a1 = Instance.new("Attachment");
      local a2 = Instance.new("Attachment");
      socket.Attachment0 = a1
      socket.Attachment1 = a2
      a1.CFrame = joint.C0
      a2.CFrame = joint.C1
      socket.LimitsEnabled = true
      socket.TwistLimitsEnabled = true
      a1.Parent = joint.Part0
      a2.Parent = joint.Part1
      socket.Parent = joint.Parent
      joint.Enabled = false;

    elseif joint:IsA("LocalScript") or joint:IsA("Script") then

      joint:Destroy();

    end;

  end

  ragdollModel.Parent = workspace;
  (ragdollModel:FindFirstChild("Humanoid") :: Humanoid):ChangeState(Enum.HumanoidStateType.Physics);

  for _, part in ragdollModel:GetDescendants() do

    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then

      part:SetNetworkOwner(nil)

    end

  end;

  return ragdollModel;

end;