local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");

local function submitPosition(_, inputState)

  if inputState == Enum.UserInputState.Begin then

    script.RemoteEvent:FireServer(Players.LocalPlayer:GetMouse().Hit.Position);

  end;

end;

ContextActionService:BindActionAtPriority("Submit Position", submitPosition, false, 2, Enum.UserInputType.MouseButton1);