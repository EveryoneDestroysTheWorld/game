local Cause = require(script.Parent.Cause);
type Cause = Cause.Cause;

export type Effect = {
  name: string;
  description: string?;
  endTimeMilliseconds: number?;
  onBeforeHealthChange: ((increment: number, cause: Cause?) -> number)?;
  onBeforeStaminaChange: ((increment: number, cause: Cause?) -> number)?;
}

return {};