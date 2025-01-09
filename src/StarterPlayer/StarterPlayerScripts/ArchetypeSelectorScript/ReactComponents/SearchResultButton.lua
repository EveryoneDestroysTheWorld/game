--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ContextActionService = game:GetService("ContextActionService");
local Fonts = require(ReplicatedStorage.Client.Fonts);

export type SearchResultButtonProperties = {
  onActivate: () -> ();
  isSelected: boolean;
  LayoutOrder: number;
  title: string;
  description: string;
  iconImage: string;
}

local function SearchResultButton(properties: SearchResultButtonProperties)

  React.useEffect(function(): ()
  
    if properties.isSelected then

      local function selectResult(actionName: string, inputState: Enum.UserInputState)

        if inputState == Enum.UserInputState.Begin then

          properties.onActivate();

        end;

      end;

      ContextActionService:BindAction("SelectResult", selectResult, false, Enum.KeyCode.Return, Enum.KeyCode.KeypadEnter);

      return function()

        ContextActionService:UnbindAction("SelectResult");

      end;

    end;

  end, {properties.isSelected});

  return React.createElement("TextButton", {
    BackgroundTransparency = 1;
    LayoutOrder = properties.LayoutOrder;
    AutomaticSize = Enum.AutomaticSize.Y;
    Size = UDim2.new(1, 0, 0, 0);
    Text = "";
    [React.Event.Activated] = function()

      properties.onActivate();
      print("Done!");

    end;
  }, {
    TopSection = React.createElement("Frame", {
      AutomaticSize = Enum.AutomaticSize.Y;
      BorderSizePixel = 0;
      Size = UDim2.new(1, 0, 0, 30);
      BackgroundColor3 = Color3.new();
      BackgroundTransparency = 0.6;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        FillDirection = Enum.FillDirection.Horizontal;
        Padding = UDim.new(0, 10);
      });
      UIPadding = React.createElement("UIPadding", {
        PaddingLeft = UDim.new(0, 15);
        PaddingRight = UDim.new(0, 15);
        PaddingTop = UDim.new(0, 15);
        PaddingBottom = UDim.new(0, 15);
      });
      LeftSection = React.createElement("Frame", {
        AutomaticSize = Enum.AutomaticSize.XY;
        LayoutOrder = 1;
        BackgroundTransparency = 1;
      }, {
        IconImageLabel = React.createElement("ImageLabel", {
          Size = UDim2.new(0, 28, 0, 28);
          BackgroundTransparency = 1;
          Image = properties.iconImage;
        });
      });
      RightSection = React.createElement("Frame", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        LayoutOrder = 2;
      }, {
        UIListLayout = React.createElement("UIListLayout", {
          SortOrder = Enum.SortOrder.LayoutOrder;
          Padding = UDim.new(0, 5);
        });
        UIFlexItem = React.createElement("UIFlexItem", {
          FlexMode = Enum.UIFlexMode.Fill
        });
        TitleLabel = React.createElement("TextLabel", {
          AutomaticSize = Enum.AutomaticSize.XY;
          Text = properties.title;
          TextColor3 = Color3.new(1, 1, 1);
          BackgroundTransparency = 1;
          FontFace = Fonts.Bold;
          TextSize = 14;
          LayoutOrder = 1;
          TextWrapped = true;
          TextXAlignment = Enum.TextXAlignment.Left;
        });
        DescriptionLabel = React.createElement("TextLabel", {
          AutomaticSize = Enum.AutomaticSize.XY;
          Text = properties.description;
          TextColor3 = Color3.new(1, 1, 1);
          FontFace = Fonts.Regular;
          BackgroundTransparency = 1;
          TextSize = 14;
          LayoutOrder = 2;
          TextWrapped = true;
          TextXAlignment = Enum.TextXAlignment.Left;
        });
      });
    });
    -- BottomSection = React.createElement("Frame", {
    --   AutomaticSize = Enum.AutomaticSize.Y;
    --   Size = UDim2.new(1, 0, 0, 0);
    -- });
  });

end;

return SearchResultButton;