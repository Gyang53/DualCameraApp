export interface RecordConfigModel {
  videoWidth: number;
  videoHeight: number;
  frameRate: number;
  bitrate: number;
  codec: VideoCodecType;
  audioSampleRate: number;
  audioChannels: number;
  audioBitrate: number;
}

export type VideoCodecType = 'H264' | 'H265';

export const DEFAULT_RECORD_CONFIG: RecordConfigModel = {
  videoWidth: 1920,
  videoHeight: 1080,
  frameRate: 30,
  bitrate: 5000000,
  codec: 'H264',
  audioSampleRate: 48000,
  audioChannels: 2,
  audioBitrate: 128000
};

export function createRecordConfig(
  overrides: Partial<RecordConfigModel> = {}
): RecordConfigModel {
  return { ...DEFAULT_RECORD_CONFIG, ...overrides };
}
