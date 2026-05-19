import { camera } from '@kit.CameraKit';
import { Logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'CameraService';

export interface CameraSessionInfo {
  cameraInput: camera.CameraInput;
  previewOutput: camera.PreviewOutput;
  videoOutput: camera.VideoOutput | null;
  videoSession: camera.VideoSession;
}

export class CameraService {
  private cameraManager: camera.CameraManager | null = null;
  private frontCamera: camera.CameraDevice | null = null;
  private backCamera: camera.CameraDevice | null = null;
  private concurrentInfo: camera.CameraConcurrentInfo[] = [];

  private frontSessionInfo: CameraSessionInfo | null = null;
  private backSessionInfo: CameraSessionInfo | null = null;

  private isInitialized: boolean = false;
  private isConcurrentSupported: boolean = false;
  private isSessionActive: boolean = false;

  async initialize(context: Context): Promise<boolean> {
    if (this.isInitialized) {
      Logger.warn(TAG, 'Already initialized');
      return true;
    }

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

      if (!this.frontCamera || !this.backCamera) {
        Logger.error(TAG, 'Missing front or back camera');
        return false;
      }

      this.isConcurrentSupported = this.checkConcurrentCapability();
      Logger.info(TAG, `Concurrent capability: ${this.isConcurrentSupported}`);

      this.isInitialized = true;
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Initialize failed: code=${err.code}, message=${err.message}`);
      return false;
    }
  }

  private checkConcurrentCapability(): boolean {
    if (!this.frontCamera || !this.backCamera || !this.cameraManager) {
      return false;
    }

    try {
      const deviceArray: camera.CameraDevice[] = [this.frontCamera, this.backCamera];
      this.concurrentInfo = this.cameraManager.getCameraConcurrentInfos(deviceArray);

      if (this.concurrentInfo.length === 0) {
        Logger.warn(TAG, 'No concurrent capability found');
        return false;
      }

      Logger.info(TAG, `Found ${this.concurrentInfo.length} concurrent modes`);
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Check concurrent capability failed: ${err.message}`);
      return false;
    }
  }

  isDualCameraSupported(): boolean {
    return this.isConcurrentSupported;
  }

  isSessionRunning(): boolean {
    return this.isSessionActive;
  }

  private getConcurrentOutputCapability(device: camera.CameraDevice): camera.CameraOutputCapability | null {
    for (const info of this.concurrentInfo) {
      if (info.device === device && info.outputCapabilities.length > 0) {
        return info.outputCapabilities[0];
      }
    }
    return null;
  }

  private selectPreviewProfile(
    capabilities: camera.CameraOutputCapability,
    targetWidth: number = 1920,
    targetHeight: number = 1080
  ): camera.Profile | null {
    const profiles = capabilities.previewProfiles;
    if (!profiles || profiles.length === 0) {
      return null;
    }

    let bestProfile: camera.Profile = profiles[0];
    let minDiff = Number.MAX_VALUE;

    for (const profile of profiles) {
      if (profile.format !== camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP) {
        continue;
      }

      const diff = Math.abs(profile.size.width - targetWidth) +
                   Math.abs(profile.size.height - targetHeight);
      if (diff < minDiff) {
        minDiff = diff;
        bestProfile = profile;
      }
    }

    return bestProfile;
  }

  selectVideoProfile(
    capabilities: camera.CameraOutputCapability,
    targetWidth: number = 1920,
    targetHeight: number = 1080
  ): camera.VideoProfile | null {
    const profiles = capabilities.videoProfiles;
    if (!profiles || profiles.length === 0) {
      return null;
    }

    let bestProfile: camera.VideoProfile | null = null;
    let minDiff = Number.MAX_VALUE;

    for (const profile of profiles) {
      const diff = Math.abs(profile.size.width - targetWidth) +
                   Math.abs(profile.size.height - targetHeight);
      if (diff < minDiff) {
        minDiff = diff;
        bestProfile = profile;
      }
    }

    return bestProfile;
  }

  async createCameraSession(
    device: camera.CameraDevice,
    previewSurfaceId: string,
    videoSurfaceId: string | null = null
  ): Promise<CameraSessionInfo | null> {
    if (!this.cameraManager) {
      Logger.error(TAG, 'Camera manager not initialized');
      return null;
    }

    try {
      const cameraInput = this.cameraManager.createCameraInput(device);
      if (!cameraInput) {
        Logger.error(TAG, 'Failed to create camera input');
        return null;
      }

      // 并发模式下打开相机
      await cameraInput.open(camera.CameraConcurrentType.CAMERA_LIMITED_CAPABILITY);
      Logger.info(TAG, 'Camera input opened in concurrent mode');

      const capabilities = this.getConcurrentOutputCapability(device);
      if (!capabilities) {
        Logger.error(TAG, 'No concurrent output capability for device');
        await cameraInput.close();
        return null;
      }

      const previewProfile = this.selectPreviewProfile(capabilities);
      if (!previewProfile) {
        Logger.error(TAG, 'No suitable preview profile found');
        await cameraInput.close();
        return null;
      }

      Logger.info(TAG, `Selected preview: ${previewProfile.size.width}x${previewProfile.size.height}`);

      const previewOutput = this.cameraManager.createPreviewOutput(previewProfile, previewSurfaceId);
      if (!previewOutput) {
        Logger.error(TAG, 'Failed to create preview output');
        await cameraInput.close();
        return null;
      }

      let videoOutput: camera.VideoOutput | null = null;
      if (videoSurfaceId) {
        const videoProfile = this.selectVideoProfile(capabilities);
        if (videoProfile) {
          videoOutput = this.cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
          Logger.info(TAG, `Created video output: ${videoProfile.size.width}x${videoProfile.size.height}`);
        }
      }

      const session = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO);
      if (!session) {
        Logger.error(TAG, 'Failed to create session');
        await cameraInput.close();
        return null;
      }

      const videoSession = session as camera.VideoSession;

      return {
        cameraInput,
        previewOutput,
        videoOutput,
        videoSession
      };
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Create camera session failed: ${err.message}`);
      return null;
    }
  }

  async startConcurrentPreview(
    frontSurfaceId: string,
    backSurfaceId: string
  ): Promise<boolean> {
    return this.startConcurrentRecording(frontSurfaceId, backSurfaceId, null, null);
  }

  async startConcurrentRecording(
    frontPreviewSurfaceId: string,
    backPreviewSurfaceId: string,
    frontVideoSurfaceId: string | null,
    backVideoSurfaceId: string | null
  ): Promise<boolean> {
    if (!this.isConcurrentSupported) {
      Logger.error(TAG, 'Concurrent camera not supported');
      return false;
    }

    if (!this.frontCamera || !this.backCamera) {
      Logger.error(TAG, 'Cameras not available');
      return false;
    }

    if (this.isSessionActive) {
      Logger.warn(TAG, 'Session already active');
      return true;
    }

    try {
      this.frontSessionInfo = await this.createCameraSession(
        this.frontCamera, 
        frontPreviewSurfaceId, 
        frontVideoSurfaceId
      );
      if (!this.frontSessionInfo) {
        Logger.error(TAG, 'Failed to create front camera session');
        return false;
      }

      this.backSessionInfo = await this.createCameraSession(
        this.backCamera, 
        backPreviewSurfaceId, 
        backVideoSurfaceId
      );
      if (!this.backSessionInfo) {
        Logger.error(TAG, 'Failed to create back camera session');
        await this.releaseSession(this.frontSessionInfo);
        this.frontSessionInfo = null;
        return false;
      }

      await this.configureAndStartSession(this.frontSessionInfo);
      await this.configureAndStartSession(this.backSessionInfo);

      this.isSessionActive = true;
      Logger.info(TAG, 'Concurrent preview started successfully');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Start concurrent preview failed: ${err.message}`);
      await this.releaseAllSessions();
      return false;
    }
  }

  private async configureAndStartSession(sessionInfo: CameraSessionInfo): Promise<void> {
    const { cameraInput, previewOutput, videoOutput, videoSession } = sessionInfo;

    videoSession.beginConfig();
    videoSession.addInput(cameraInput);
    videoSession.addOutput(previewOutput);
    
    if (videoOutput) {
      videoSession.addOutput(videoOutput);
    }
    
    await videoSession.commitConfig();
    await videoSession.start();
  }

  async startVideoOutput(): Promise<void> {
    try {
      if (this.frontSessionInfo?.videoOutput) {
        await this.frontSessionInfo.videoOutput.start();
      }
      if (this.backSessionInfo?.videoOutput) {
        await this.backSessionInfo.videoOutput.start();
      }
      Logger.info(TAG, 'Video output started');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Start video output failed: ${err.message}`);
    }
  }

  async stopVideoOutput(): Promise<void> {
    try {
      if (this.frontSessionInfo?.videoOutput) {
        await this.frontSessionInfo.videoOutput.stop();
      }
      if (this.backSessionInfo?.videoOutput) {
        await this.backSessionInfo.videoOutput.stop();
      }
      Logger.info(TAG, 'Video output stopped');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Stop video output failed: ${err.message}`);
    }
  }

  async stopPreview(): Promise<void> {
    if (!this.isSessionActive) {
      return;
    }

    try {
      if (this.frontSessionInfo?.videoSession) {
        await this.frontSessionInfo.videoSession.stop();
      }
      if (this.backSessionInfo?.videoSession) {
        await this.backSessionInfo.videoSession.stop();
      }

      this.isSessionActive = false;
      Logger.info(TAG, 'Preview stopped');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Stop preview failed: ${err.message}`);
    }
  }

  private async releaseSession(sessionInfo: CameraSessionInfo | null): Promise<void> {
    if (!sessionInfo) {
      return;
    }

    try {
      if (sessionInfo.videoSession) {
        await sessionInfo.videoSession.release();
      }
      if (sessionInfo.previewOutput) {
        await sessionInfo.previewOutput.release();
      }
      if (sessionInfo.videoOutput) {
        await sessionInfo.videoOutput.release();
      }
      if (sessionInfo.cameraInput) {
        await sessionInfo.cameraInput.close();
      }
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Release session failed: ${err.message}`);
    }
  }

  private async releaseAllSessions(): Promise<void> {
    await this.releaseSession(this.frontSessionInfo);
    await this.releaseSession(this.backSessionInfo);
    this.frontSessionInfo = null;
    this.backSessionInfo = null;
    this.isSessionActive = false;
  }

  async release(): Promise<void> {
    Logger.info(TAG, 'Releasing camera service...');
    await this.stopPreview();
    await this.releaseAllSessions();
    this.isInitialized = false;
    Logger.info(TAG, 'Camera service released');
  }

  getFrontCamera(): camera.CameraDevice | null {
    return this.frontCamera;
  }

  getBackCamera(): camera.CameraDevice | null {
    return this.backCamera;
  }

  getFrontSession(): camera.VideoSession | null {
    return this.frontSessionInfo?.videoSession ?? null;
  }

  getBackSession(): camera.VideoSession | null {
    return this.backSessionInfo?.videoSession ?? null;
  }

  getFrontVideoOutput(): camera.VideoOutput | null {
    return this.frontSessionInfo?.videoOutput ?? null;
  }

  getBackVideoOutput(): camera.VideoOutput | null {
    return this.backSessionInfo?.videoOutput ?? null;
  }
}
