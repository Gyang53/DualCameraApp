import { camera } from '@kit.CameraKit';
import { Logger } from '../utils/Logger';

const TAG = 'CameraService';

export class CameraService {
  private cameraManager: camera.CameraManager | null = null;
  private frontCamera: camera.CameraDevice | null = null;
  private backCamera: camera.CameraDevice | null = null;
  private frontSession: camera.VideoSession | null = null;
  private backSession: camera.VideoSession | null = null;
  private isConcurrentSupported: boolean = false;

  async initialize(context: Context): Promise<boolean> {
    try {
      this.cameraManager = camera.getCameraManager(context);
      if (!this.cameraManager) {
        Logger.error(TAG, 'Failed to get camera manager');
        return false;
      }

      const cameras = this.cameraManager.getSupportedCameras();
      Logger.info(TAG, `Found ${cameras.length} cameras`);

      for (const cam of cameras) {
        if (cam.cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT) {
          this.frontCamera = cam;
          Logger.info(TAG, 'Front camera found');
        } else if (cam.cameraPosition === camera.CameraPosition.CAMERA_POSITION_BACK) {
          this.backCamera = cam;
          Logger.info(TAG, 'Back camera found');
        }
      }

      this.isConcurrentSupported = this.checkConcurrentCapability();
      Logger.info(TAG, `Concurrent capability: ${this.isConcurrentSupported}`);

      return this.frontCamera !== null && this.backCamera !== null;
    } catch (error) {
      Logger.error(TAG, `Initialize failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  private checkConcurrentCapability(): boolean {
    if (!this.frontCamera || !this.backCamera || !this.cameraManager) {
      return false;
    }

    try {
      const deviceArray: camera.CameraDevice[] = [this.frontCamera, this.backCamera];
      const concurrentInfo = this.cameraManager.getCameraConcurrentInfos(deviceArray);
      return concurrentInfo.length > 0;
    } catch (error) {
      Logger.error(TAG, `Check concurrent capability failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  isDualCameraSupported(): boolean {
    return this.isConcurrentSupported;
  }

  async openConcurrentCameras(
    frontSurfaceId: string,
    backSurfaceId: string
  ): Promise<boolean> {
    if (!this.isConcurrentSupported) {
      Logger.error(TAG, 'Concurrent camera not supported');
      return false;
    }

    try {
      if (!this.cameraManager || !this.frontCamera || !this.backCamera) {
        return false;
      }

      Logger.info(TAG, 'Opening concurrent cameras...');
      // TODO: Implement concurrent camera opening logic
      return true;
    } catch (error) {
      Logger.error(TAG, `Open concurrent cameras failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  async closeCameras(): Promise<void> {
    try {
      if (this.frontSession) {
        await this.frontSession.stop();
        this.frontSession = null;
      }
      if (this.backSession) {
        await this.backSession.stop();
        this.backSession = null;
      }
      Logger.info(TAG, 'Cameras closed');
    } catch (error) {
      Logger.error(TAG, `Close cameras failed: ${JSON.stringify(error)}`);
    }
  }

  getFrontCamera(): camera.CameraDevice | null {
    return this.frontCamera;
  }

  getBackCamera(): camera.CameraDevice | null {
    return this.backCamera;
  }
}
