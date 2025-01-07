--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local WaitingMessage = require(script.Parent.WaitingMessage);

local function PreRoundLoadoutScreen()

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundColor3 = Color3.new(0, 0, 0);
    BorderSizePixel = 0;
  }, {
    WaitingMessage = React.createElement(WaitingMessage);
  });

end;

return PreRoundLoadoutScreen;