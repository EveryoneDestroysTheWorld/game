local Cause = require(script.Parent.Cause);
type Cause = Cause.Cause;

export type Effect = {
  name: string;
  id: string;
  description: string?;
  expirationTimeMilliseconds: number?;
  onActivate: (() -> ())?;
  onBeforeHealthChange: ((newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
  onBeforeStaminaChange: ((newHealth: number, oldHealth: number, cause: Cause?) -> number)?;
}

return {};