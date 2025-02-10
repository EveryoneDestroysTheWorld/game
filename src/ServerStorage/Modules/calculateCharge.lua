--!strict

--[[
  Calculates the charge value.
]]
local function calculateCharge(startChargeTime: number, maxChargeDuration: number): number

  local goalTime = startChargeTime + maxChargeDuration;
	local queryTime = math.min(goalTime, DateTime.now().UnixTimestampMillis);
	return math.max(1, queryTime / goalTime);

end;

return calculateCharge;