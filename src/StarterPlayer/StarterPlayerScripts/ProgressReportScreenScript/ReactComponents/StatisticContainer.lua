--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local ClientContestant = require(ReplicatedStorage.Client.Classes.ClientContestant);
type ClientContestant = ClientContestant.ClientContestant;
local Fonts = require(ReplicatedStorage.Client.Fonts);

export type ProgressReportScreenProperties = {
  LayoutOrder: number;
  name: string;
  value: number;
}

local function StatisticContainer(properties: ProgressReportScreenProperties)

  return React.createElement("Frame", {
    BackgroundTransparency = 0.6;
    AutomaticSize = Enum.AutomaticSize.Y;
    BackgroundColor3 = Color3.new(0, 0, 0);
    Size = UDim2.new(1, 0, 0, 0);
    BorderSizePixel = 0;
    LayoutOrder = properties.LayoutOrder;
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      FillDirection = Enum.FillDirection.Horizontal;
      HorizontalFlex = Enum.UIFlexAlignment.SpaceBetween;
      Padding = UDim.new(0, 2);
    });
    UIPadding = React.createElement("UIPadding", {
      PaddingLeft = UDim.new(0, 5);
      PaddingTop = UDim.new(0, 5);
      PaddingBottom = UDim.new(0, 5);
      PaddingRight = UDim.new(0, 5);
    });
    StatisticNameTextLabel = React.createElement("TextLabel", {
      LayoutOrder = 1;
      Text = properties.name:upper();
      FontFace = Fonts.Regular;
      TextColor3 = Color3.new(1, 1, 1);
      AutomaticSize = Enum.AutomaticSize.XY;
      BackgroundTransparency = 1;
      TextSize = 14;
    });
    ValueContainer = React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      LayoutOrder = 2;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, 5);
        FillDirection = Enum.FillDirection.Horizontal;
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      PersonalValueTextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextColor3 = Color3.new(1, 1, 1);
        FontFace = Fonts.SemiBold;
        LayoutOrder = 1;
        TextTransparency = 0.3;
        TextSize = 14;
        Text = properties.value;
      });
      SlashTextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextColor3 = Color3.new(1, 1, 1);
        FontFace = Fonts.Regular;
        LayoutOrder = 2;
        TextTransparency = 0.3;
        TextSize = 14;
        Text = "/";
      });
      TotalValueTextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        TextColor3 = Color3.new(1, 1, 1);
        FontFace = Fonts.Regular;
        LayoutOrder = 3;
        TextTransparency = 0.3;
        TextSize = 14;
        Text = "0";
      });
    })
  });

end;

return StatisticContainer;