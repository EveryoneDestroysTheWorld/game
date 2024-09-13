local Players = game:GetService("Players");
local player = Players.LocalPlayer;

player.Character.ChildAdded:Connect(function(child)
  
  if child:IsA("ProximityPrompt") then

    child.Enabled = false;

  end;

end);