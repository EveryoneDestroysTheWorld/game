--!strict

local ServerStorage = game:GetService("ServerStorage");

local RagdollService = require(ServerStorage.Modules.RagdollService);

return function(character: Model): Model

  character.Archivable = true;
  local ragdollModel = character:Clone();

  ragdollModel.Parent = workspace;

  for _, part in ragdollModel:GetDescendants() do

    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then

      part:SetNetworkOwner()

    end

  end;

  RagdollService:ragdollCharacter(ragdollModel);

  return ragdollModel;

end;