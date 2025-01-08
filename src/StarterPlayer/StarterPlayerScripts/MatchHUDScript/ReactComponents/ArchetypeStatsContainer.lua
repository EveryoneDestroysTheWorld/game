--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local ClientRound = require(ReplicatedStorage.Client.Classes.ClientRound);
type ClientRound = ClientRound.ClientRound;
local StatContainer = require(script.Parent.StatContainer);
local Line = require(script.Parent.Line);
local Square = require(script.Parent.Square);

type RoundTimerProps = {
  round: ClientRound;
}

local function ArchetypeStatsContainer(props: RoundTimerProps)

  return React.createElement("Frame", {
    BackgroundTransparency = 1;
    AutomaticSize = Enum.AutomaticSize.Y;
    Position = UDim2.new(0.5, 0, 1, -30);
    Size = UDim2.new(0, 200, 0, 0);
  }, {
    UIListLayout = React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 5);
    });
    StatsContainer = React.createElement("Frame", {
      LayoutOrder = 1;
      Size = UDim2.new(1, 0, 0, 20);
    }, {
      UIListLayout = React.createElement("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder;
        Padding = UDim.new(0, 5);
        FillDirection = Enum.FillDirection.Horizontal;
      });
      HealthStatContainer = React.createElement(StatContainer, {
        iconImage = "rbxassetid://89195253844423",
        layoutOrder = 1;
        value = "0";
      });
      StaminaStatContainer = React.createElement(StatContainer, {
        iconImage = "rbxassetid://124027369520548",
        layoutOrder = 2;
        value = "0";
      });
    });
    ArchetypeButton = React.createElement("TextButton", {
      LayoutOrder = 2;
      Size = UDim2.new(1, 0, 0, 30);
      BackgroundTransparency = 0.6;
      BorderSizePixel = 0;
    }, {
      DecorationContainer = React.createElement("Frame", {
        Size = UDim2.new(1, 0, 1, 0);
        BackgroundTransparency = 1;
      }, {
        TopLine = React.createElement(Line, {isTop = true});
        BottomLine = React.createElement(Line, {isTop = false});
        TopLeftSquare = React.createElement(Square, {anchorPoint = Vector2.new()});
        TopRightSquare = React.createElement(Square, {anchorPoint = Vector2.new(1, 0)});
        BottomLeftSquare = React.createElement(Square, {anchorPoint = Vector2.new(0, 1)});
        BottomRightSquare = React.createElement(Square, {anchorPoint = Vector2.new(1, 1)});
      });
      TextLabel = React.createElement("TextLabel", {
        BackgroundTransparency = 1;
        AutomaticSize = Enum.AutomaticSize.XY;
        FontFace = Font.fromId(11702779517, Enum.FontWeight.Light);
        TextColor3 = Color3.new(1, 1, 1);
        TextSize = 14;
        Text = "CHOOSE AN ARCHETYPE"
      });
    });
  });

end;

return ArchetypeStatsContainer;