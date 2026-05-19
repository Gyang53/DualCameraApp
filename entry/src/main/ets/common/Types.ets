export interface CameraDevice {
  deviceId: string;
  position: 'front' | 'back';
  isAvailable: boolean;
}

export interface RecordConfig {
  width: number;
  height: number;
  frameRate: number;
  bitrate: number;
  codec: VideoCodec;
}

export type VideoCodec = 'h264' | 'h265';

export interface UserSettings {
  recordMode: 'split' | 'pip';
  splitRatio: number;
  pipPosition: 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight';
  maxDuration: number;
  fileMode: 'merged' | 'separate';
  frontMirror: boolean;
  gridLine: boolean;
  timestamp: boolean;
  audioMode: 'shared' | 'separate';
  colorSpace: 'auto' | 'sdr' | 'hdr';
  frontLight: boolean;
  lowLightHint: boolean;
  storageHint: boolean;
}

export interface CameraParams {
  zoomRatio: number;
  exposureBias: number;
  focusMode: 'continuous' | 'manual';
  flashMode: 'off' | 'on' | 'auto';
  stabilization: boolean;
}
