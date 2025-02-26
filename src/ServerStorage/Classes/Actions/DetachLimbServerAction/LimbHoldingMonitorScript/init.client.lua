--!strict
-- This script is used for players to submit their target location without initializing their own DetachLimbClientAction.
-- 
-- Programmer: Christian Toney (Christian_Toney)
-- © 2024 – 2025 Beastslash LLC

local ContextActionService = game:GetService("ContextActionService");
local Players = game:GetService("Players");

local function submitPosition(_, inputState)

  if inputState == Enum.UserInputState.Begin then

    script.RemoteEvent:FireServer(Players.LocalPlayer:GetMouse().Hit.Position);
 
  end;

end;

ContextActionService:BindActionAtPriority("Submit Position", submitPosition, false, 2, Enum.UserInputType.MouseButton1);