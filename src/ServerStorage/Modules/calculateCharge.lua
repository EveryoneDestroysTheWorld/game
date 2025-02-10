--!strict

--[[
  Calculates the charge value.
]]
local function calculateCharge(startChargeTime: number, maxChargeDuration: number): number

  local goalTime = startChargeTime + maxChargeDuration;
	local queryTime = DateTime.now().UnixTimestampMillis;
  local delta = goalTime - queryTime;
	return math.min(1, 1 - (delta / maxChargeDuration));

end;

return calculateCharge;