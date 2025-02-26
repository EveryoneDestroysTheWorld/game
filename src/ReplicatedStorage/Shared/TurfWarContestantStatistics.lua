export type TurfWarContestantStatistics = {
  partsDestroyed: number;
  partsClaimed: number;
  partsRestored: number;
  eliminationCount: number;
  recoveryCount: number;
  deathCount: number;
}

export type PatchableTurfWarContestantStatistics = {
  partsClaimed: number?;
  partsDestroyed: number?;
  partsRestored: number?;
  eliminationCount: number?;
  recoveryCount: number?;
  deathCount: number?;
}

return {};