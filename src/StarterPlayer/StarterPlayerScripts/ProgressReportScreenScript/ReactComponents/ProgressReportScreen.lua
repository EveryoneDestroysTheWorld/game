--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ContentContainer = require(script.Parent.ContentContainer);
local OptionsContainer = require(script.Parent.OptionsContainer);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;

export type ProgressReportScreenProperties = {
  round: ClientRound;
}

local function ProgressReportScreen(properties: ProgressReportScreenProperties)

  return React.createElement("Frame", {
    BackgroundTransparency = 0.6;
    BackgroundColor3 = Color3.new();
    Size = UDim2.new(1, 0, 1, 0);
    BorderSizePixel = 0;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      VerticalFlex = Enum.UIFlexAlignment.SpaceBetween;
      HorizontalAlignment = Enum.HorizontalAlignment.Center;
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 30);
      PaddingRight = UDim.new(0, 30);
      PaddingTop = UDim.new(0, 30);
      PaddingBottom = UDim.new(0, 30);
    });
    ContentContainer = React.createElement(ContentContainer, {round = properties.round});
    OptionsContainer = React.createElement(OptionsContainer);
  });

end;

return ProgressReportScreen;