--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);

export type StatBlockFrameProperties = {
  headerText: string;
  contentText: string;
}

local function StatBlockFrame(props: StatBlockFrameProperties)

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    Size = UDim2.new();
    AutomaticSize = Enum.AutomaticSize.XY;
  }, {
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
    UIStroke = React.createElement("UIStroke", {
      Color = Color3.fromRGB(36, 36, 36);
      Thickness = 2;
      ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
      Transparency = 0;
    });
    HeaderFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Size = UDim2.new();
    }, {
      TextLabel = React.createElement("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X;
        Text = props.headerText:upper();
      });
    });
    DividerFrame = React.createElement("Frame", {
      Size = UDim2.new(1, 0, 0, 2);
      BorderSizePixel = 0;
      BackgroundColor3 = Color3.fromRGB(36, 36, 36);
    });
    ContentFrame = React.createElement("Frame", {
      BackgroundTransparency = 1;
      Size = UDim2.new();
    }, {
      TextLabel = React.createElement("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.XY;
        Text = props.contentText;
      })
    })
  });

end;

return StatBlockFrame;