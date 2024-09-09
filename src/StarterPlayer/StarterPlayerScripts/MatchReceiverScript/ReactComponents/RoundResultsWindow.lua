--!strict
-- Programmers: Christian Toney (Christian_Toney)

local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local RoundResultsHeaderFrame = require(script.Parent.RoundResultsHeaderFrame);
local RoundResultsContentFrame = require(script.Parent.RoundResultsContentFrame);

local function RoundResultsWindow()

  local round = React.useState(ClientRound.fromServerRound());

  return React.createElement("Frame", {
    Size = UDim2.new(1, 0, 1, 0);
    BackgroundColor3 = Color3.new();
    BackgroundTransparency = 0.1;
    BorderSizePixel = 0;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
    });
    Header = React.createElement(RoundResultsHeaderFrame, {round = round});
    Content = React.createElement(RoundResultsContentFrame, {round = round});
    ControlsFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      LayoutOrder = 3;
      Size = UDim2.new(1, 0, 0, 30);
    }, {

    });
  })

end;

return RoundResultsWindow;