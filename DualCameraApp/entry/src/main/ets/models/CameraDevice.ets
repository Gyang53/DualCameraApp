export interface CameraDeviceModel {
  deviceId: string;
  position: CameraPosition;
  isAvailable: boolean;
  supportedFormats: VideoFormat[];
}

export type CameraPosition = 'front' | 'back';

export interface VideoFormat {
  width: number;
  height: number;
  frameRates: number[];
}

export function createCameraDevice(
  deviceId: string,
  position: CameraPosition,
  isAvailable: boolean = true
): CameraDeviceModel {
  return {
    deviceId,
    position,
    isAvailable,
    supportedFormats: []
  };
}
