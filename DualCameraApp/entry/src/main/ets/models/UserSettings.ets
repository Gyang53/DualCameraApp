export interface UserSettingsModel {
  // 录像设置
  recordMode: RecordMode;
  maxDuration: MaxDuration;
  fileMode: FileMode;

  // 画面设置
  splitRatio: SplitRatio;
  pipPosition: PipPosition;
  frontMirror: boolean;
  gridLine: boolean;
  timestamp: boolean;

  // 音频设置
  audioMode: AudioMode;

  // 高级设置
  colorSpace: ColorSpace;
  frontLight: boolean;
  lowLightHint: boolean;
  storageHint: boolean;
}

export type RecordMode = 'split' | 'pip';
export type MaxDuration = 300000 | 600000 | 900000 | 1800000 | -1; // 5m, 10m, 15m, 30m, unlimited
export type FileMode = 'merged' | 'separate';
export type SplitRatio = 0.3 | 0.5 | 0.7;
export type PipPosition = 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight';
export type AudioMode = 'shared' | 'separate';
export type ColorSpace = 'auto' | 'sdr' | 'hdr';

export const DEFAULT_USER_SETTINGS: UserSettingsModel = {
  recordMode: 'split',
  maxDuration: 600000,
  fileMode: 'merged',
  splitRatio: 0.5,
  pipPosition: 'topRight',
  frontMirror: false,
  gridLine: false,
  timestamp: false,
  audioMode: 'shared',
  colorSpace: 'auto',
  frontLight: false,
  lowLightHint: true,
  storageHint: true
};

export function createUserSettings(
  overrides: Partial<UserSettingsModel> = {}
): UserSettingsModel {
  return { ...DEFAULT_USER_SETTINGS, ...overrides };
}
