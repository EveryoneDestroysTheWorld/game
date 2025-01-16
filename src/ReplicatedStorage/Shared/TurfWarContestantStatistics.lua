export type TurfWarContestantStatistics = {
  partsDestroyed: number;
  partsClaimed: number;
  partsRestored: number;
  deathCount: number;
}

export type PatchableContestantTurfWarStatistics = {
  partsClaimed: number?;
  partsDestroyed: number?;
  partsRestored: number?;
  deathCount: number?;
}

return {};