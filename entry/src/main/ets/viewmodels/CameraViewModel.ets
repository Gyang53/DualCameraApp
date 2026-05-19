import { CameraService } from '../services/CameraService';
import { RecordService } from '../services/RecordService';
import { PermissionService } from '../services/PermissionService';
import { Logger } from '../utils/Logger';
import { RecordConfig, UserSettings } from '../common/Types';

const TAG = 'CameraViewModel';

export class CameraViewModel {
  @Track isInitialized: boolean = false;
  @Track isDualCameraSupported: boolean = false;
  @Track isRecording: boolean = false;
  @Track currentMode: 'split' | 'pip' = 'split';
  @Track recordingDuration: number = 0;

  private cameraService: CameraService;
  private recordService: RecordService;
  private permissionService: PermissionService;
  private recordingTimer: number = -1;

  constructor() {
    this.cameraService = new CameraService();
    this.recordService = new RecordService();
    this.permissionService = new PermissionService();
  }

  async initialize(context: Context): Promise<void> {
    Logger.info(TAG, 'Initializing camera view model...');

    const hasPermissions = await this.permissionService.checkAllPermissions(context);
    if (!hasPermissions) {
      Logger.warn(TAG, 'Missing permissions');
      return;
    }

    this.isInitialized = await this.cameraService.initialize(context);
    this.isDualCameraSupported = this.cameraService.isDualCameraSupported();
    
    if (this.isDualCameraSupported) {
      await this.recordService.initialize();
    }

    Logger.info(TAG, `Initialized: ${this.isInitialized}, DualCamera: ${this.isDualCameraSupported}`);
  }

  async startPreview(frontSurfaceId: string, backSurfaceId: string): Promise<boolean> {
    if (!this.isInitialized) {
      Logger.error(TAG, 'Not initialized');
      return false;
    }

    return this.cameraService.openConcurrentCameras(frontSurfaceId, backSurfaceId);
  }

  async startRecording(): Promise<boolean> {
    if (this.isRecording) {
      Logger.warn(TAG, 'Already recording');
      return false;
    }

    Logger.info(TAG, 'Starting recording...');
    this.isRecording = true;
    this.recordingDuration = 0;
    this.startRecordingTimer();
    return true;
  }

  async stopRecording(): Promise<void> {
    if (!this.isRecording) {
      return;
    }

    Logger.info(TAG, 'Stopping recording...');
    this.stopRecordingTimer();
    const files = await this.recordService.stopRecording();
    this.isRecording = false;
    Logger.info(TAG, `Recording saved: ${JSON.stringify(files)}`);
  }

  switchMode(mode: 'split' | 'pip'): void {
    this.currentMode = mode;
    Logger.info(TAG, `Mode switched to: ${mode}`);
  }

  private startRecordingTimer(): void {
    this.recordingTimer = setInterval(() => {
      this.recordingDuration += 1000;
    }, 1000);
  }

  private stopRecordingTimer(): void {
    if (this.recordingTimer !== -1) {
      clearInterval(this.recordingTimer);
      this.recordingTimer = -1;
    }
  }

  async release(): Promise<void> {
    this.stopRecordingTimer();
    await this.cameraService.closeCameras();
    await this.recordService.release();
    this.isInitialized = false;
  }
}
