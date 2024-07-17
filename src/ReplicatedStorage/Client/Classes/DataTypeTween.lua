local TweenService = game:GetService("TweenService");

type props = ({
  type: "Number";
  initialValue: number?;
  goalValue: number;
  onChange: (newValue: number) -> ();
} | {
  type: "Color3";
  initialValue: Color3?;
  goalValue: Color3;
  onChange: (newValue: Color3) -> ();
}) & {
  tweenInfo: TweenInfo?;
}

return function(props: props): Tween

  local valueInstance = Instance.new(`{type}Value`);
  valueInstance:GetPropertyChangedSignal("Value"):Connect(function()
    
    task.wait();
    props.onChange(valueInstance.Value);

  end);
  
  if props.initialValue then

    valueInstance.Value = props.initialValue;

  end;

  local tween = TweenService:Create(valueInstance, props.tweenInfo or TweenInfo.new(), {Value = props.goalValue});
  
  return tween;

end;