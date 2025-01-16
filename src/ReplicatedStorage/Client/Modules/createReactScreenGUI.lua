--!strict
local Players = game:GetService("Players");

local function createReactScreenGUI()

  local screenGUI = Instance.new("ScreenGui");
  screenGUI.Parent = Players.LocalPlayer:WaitForChild("PlayerGui");
  screenGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
  screenGUI.ScreenInsets = Enum.ScreenInsets.None;
  screenGUI.ResetOnSpawn = false;
  screenGUI.DisplayOrder = 1;
  screenGUI.Enabled = true;

  return screenGUI;

end;

return createReactScreenGUI;