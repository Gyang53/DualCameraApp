import { RecordService } from '../services/RecordService';
import { StorageService } from '../services/StorageService';
import { Logger } from '../utils/Logger';
import { RecordConfig, UserSettings } from '../common/Types';
import { Constants } from '../utils/Constants';

const TAG = 'RecordViewModel';

export class RecordViewModel {
  @Track isRecording: boolean = false;
  @Track duration: number = 0;
  @Track settings: UserSettings | null = null;

  private recordService: RecordService;
  private storageService: StorageService;
  private durationTimer: number = -1;

  constructor() {
    this.recordService = new RecordService();
    this.storageService = new StorageService();
  }

  async initialize(context: Context): Promise<void> {
    await this.storageService.initialize(context);
    this.settings = await this.storageService.loadSettings();
    await this.recordService.initialize();
    Logger.info(TAG, 'RecordViewModel initialized');
  }

  async startRecording(
    context: Context,
    frontSurfaceId: string,
    backSurfaceId: string
  ): Promise<boolean> {
    if (!this.settings) {
      Logger.error(TAG, 'Settings not loaded');
      return false;
    }

    const config: RecordConfig = {
      width: Constants.DEFAULT_VIDEO_WIDTH,
      height: Constants.DEFAULT_VIDEO_HEIGHT,
      frameRate: Constants.DEFAULT_FRAME_RATE,
      bitrate: Constants.DEFAULT_BITRATE,
      codec: 'h264',
    };

    const success = await this.recordService.startRecording(
      context,
      frontSurfaceId,
      backSurfaceId,
      config
    );

    if (success) {
      this.isRecording = true;
      this.startDurationTimer();
    }

    return success;
  }

  async stopRecording(): Promise<string[]> {
    if (!this.isRecording) {
      return [];
    }

    const files = await this.recordService.stopRecording();
    this.isRecording = false;
    this.stopDurationTimer();
    return files;
  }

  private startDurationTimer(): void {
    this.durationTimer = setInterval(() => {
      this.duration = this.recordService.getRecordingDuration();
      
      if (this.settings && this.settings.maxDuration > 0) {
        if (this.duration >= this.settings.maxDuration) {
          this.stopRecording();
        }
      }
    }, 100);
  }

  private stopDurationTimer(): void {
    if (this.durationTimer !== -1) {
      clearInterval(this.durationTimer);
      this.durationTimer = -1;
    }
  }

  async updateSettings(newSettings: Partial<UserSettings>): Promise<void> {
    if (!this.settings) {
      return;
    }

    this.settings = { ...this.settings, ...newSettings };
    await this.storageService.saveSettings(this.settings);
  }
}
