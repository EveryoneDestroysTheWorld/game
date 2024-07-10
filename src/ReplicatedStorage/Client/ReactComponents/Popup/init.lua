local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ScreenUIListLayout = require(script.Parent.ScreenUIListLayout);
local ScreenUIPadding = require(script.Parent.ScreenUIPadding);
local Button = require(script.Parent.Button);
local Colors = require(ReplicatedStorage.Client.Colors);
local ParagraphTextLabel = require(script.Parent.ParagraphTextLabel);

type PopupProps = {
  headingText: string?;
  taglineText: string?;
  options: {typeof(Button)}; 
  children: any;
};

local function Popup(props: PopupProps)

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5);
    AutomaticSize = Enum.AutomaticSize.XY;
    Position = UDim2.new(0.5, 0, 0.5, 0);
    Size = UDim2.new(0, 0, 0, 0);
    BorderSizePixel = 0;
    BackgroundColor3 = Colors.PopupBackground;
    BackgroundTransparency = 0.6;
  }, {
    UIListLayout = React.createElement(ScreenUIListLayout);
    UIPadding = React.createElement(ScreenUIPadding);
    UICorner = React.createElement("UICorner", {
      CornerRadius = UDim.new(0, 5);
    });
    UISizeConstraint = React.createElement("UISizeConstraint", {
      MaxSize = Vector2.new(600, 300);
      MinSize = Vector2.new(300, 0);
    });
    UIStroke = React.createElement("UIStroke", {
      Color = Colors.PopupBorder;
      Transparency = 0.87;
    });
    Header = if props.headingText or props.taglineText then React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new(0, 0, 0, 0);
      LayoutOrder = 1;
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        Padding = UDim.new(0, 5);
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      Heading = if props.headingText then React.createElement(ParagraphTextLabel, {
        LayoutOrder = 1;
        text = props.headingText:upper();
        TextColor3 = Colors.DemoDemonsRed;
        headingLevel = 1;
      }) else nil;
      Tagline = if props.taglineText then React.createElement(ParagraphTextLabel, {
        LayoutOrder = 2;
        text = props.taglineText;
        TextColor3 = Colors.TaglineText;
        headingLevel = 2;
      }) else nil;
    }) else nil;
    Content = React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new(0, 0, 0, 0);
      LayoutOrder = 2;
    }, {
      React.createElement(ScreenUIListLayout);
      props.children;
    });
    Options = if props.options then React.createElement("Frame", {
      BackgroundTransparency = 1;
      AutomaticSize = Enum.AutomaticSize.XY;
      Size = UDim2.new(0, 0, 0, 0);
      LayoutOrder = 3;
    }, {
      React.createElement("UIListLayout", {
        Name = "UIListLayout";
        FillDirection = Enum.FillDirection.Horizontal;
        Padding = UDim.new(0, 15);
        SortOrder = Enum.SortOrder.LayoutOrder;
      });
      props.options;
    }) else nil;
  });

end

return Popup;