--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local StarterGui = game:GetService("StarterGui");

while not pcall(function()

  local resetBindable = Instance.new("BindableEvent")
  resetBindable.Event:Connect(function()

    ReplicatedStorage.Shared.Events.ResetButtonPressed:FireServer();

  end)

  -- This will remove the current behavior for when the reset button 
  -- is pressed and just fire resetBindable instead.
  StarterGui:SetCore("ResetButtonCallback", resetBindable);
  
end) do

  task.wait();

end;