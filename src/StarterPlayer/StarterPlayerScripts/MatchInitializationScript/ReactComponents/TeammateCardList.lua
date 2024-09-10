--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local React = require(ReplicatedStorage.Shared.Packages.react);
local dataTypeTween = require(ReplicatedStorage.Client.Classes.DataTypeTween);

type TeammateCardListProps = {
  layoutOrder: number;
  children: any;
  shouldHide: boolean?;
}

local function TeammateCardList(props: TeammateCardListProps)

  local containerRef = React.useRef(nil :: GuiObject?);
  React.useEffect(function()
  
    local container = containerRef.current;
    if container then

      container.Position = UDim2.new(1, if props.shouldHide then 100 else 0, 0.5, 0);

    end;
    
  end, {});

  React.useEffect(function(): ()
  
    local container = containerRef.current;
    if container and props.layoutOrder == 1 then 
      
      container.Position = UDim2.new(0, 0, 0.5, 0);
    
    elseif props.layoutOrder == 2 then 

      if container then

        local tween = dataTypeTween({
          type = "Number";
          goalValue = if props.shouldHide then 100 else 0;
          initialValue = container.Position.X.Offset;
          tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut);
          onChange = function(newValue: number)

            -- Using containerRef just in case the type of element changes.
            container = containerRef.current;
            if container then

              container.Position = UDim2.new(container.Position.X.Scale, newValue, container.Position.Y.Scale, container.Position.Y.Offset);

            end;

          end;
        });

        tween:Play();

        return function()
  
          tween:Cancel();
    
        end;

      end;

    end;

  end, {props.shouldHide :: any, props.layoutOrder});

  return React.createElement("Frame", {
    AnchorPoint = Vector2.new(if props.layoutOrder == 1 then 0 else 1, 0.5);
    AutomaticSize = Enum.AutomaticSize.XY;
    ref = containerRef;
    BackgroundTransparency = 1;
    Size = UDim2.new();
    LayoutOrder = props.layoutOrder;
  }, {
    React.createElement("UIListLayout", {
      SortOrder = Enum.SortOrder.LayoutOrder;
      Padding = UDim.new(0, 1);
      HorizontalAlignment = if props.layoutOrder == 2 then Enum.HorizontalAlignment.Right else nil;
    });
    React.createElement(React.Fragment, {}, props.children);
  })

end;

return TeammateCardList;