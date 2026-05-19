import { media } from '@kit.MediaKit';
import { Logger } from '../utils/Logger';
import { RecordConfig } from '../common/Types';
import { FileUtils } from '../utils/FileUtils';

const TAG = 'RecordService';

export class RecordService {
  private frontRecorder: media.AVRecorder | null = null;
  private backRecorder: media.AVRecorder | null = null;
  private isRecording: boolean = false;
  private startTime: number = 0;
  private frontFilePath: string = '\;
  private backFilePath: string = '';

  async initialize(): Promise<boolean> {
    try {
      this.frontRecorder = await media.createAVRecorder();
      this.backRecorder = await media.createAVRecorder();
      Logger.info(TAG, 'Recorders initialized');
      return true;
    } catch (error) {
      Logger.error(TAG, `Initialize failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  async startRecording(
    context: Context,
    frontSurfaceId: string,
    backSurfaceId: string,
    config: RecordConfig
  ): Promise<boolean> {
    if (this.isRecording) {
      Logger.warn(TAG, 'Already recording');
      return false;
    }

    try {
      const baseName = FileUtils.generateFileName();
      this.frontFilePath = `${baseName}_front`;
      this.backFilePath = `${baseName}_back`;

      const profile = this.buildRecorderProfile(config);

      Logger.info(TAG, `Starting recording with config: ${JSON.stringify(config)}`);
      
      // TODO: Implement actual recording logic
      this.isRecording = true;
      this.startTime = Date.now();
      
      return true;
    } catch (error) {
      Logger.error(TAG, `Start recording failed: ${JSON.stringify(error)}`);
      return false;
    }
  }

  async stopRecording(): Promise<string[]> {
    if (!this.isRecording) {
      return [];
    }

    try {
      Logger.info(TAG, 'Stopping recording...');

      if (this.frontRecorder) {
        await this.frontRecorder.stop();
      }
      if (this.backRecorder) {
        await this.backRecorder.stop();
      }

      this.isRecording = false;
      Logger.info(TAG, 'Recording stopped');

      return [this.frontFilePath, this.backFilePath];
    } catch (error) {
      Logger.error(TAG, `Stop recording failed: ${JSON.stringify(error)}`);
      this.isRecording = false;
      return [];
    }
  }

  getRecordingDuration(): number {
    if (!this.isRecording) {
      return 0;
    }
    return Date.now() - this.startTime;
  }

  isCurrentlyRecording(): boolean {
    return this.isRecording;
  }

  private buildRecorderProfile(config: RecordConfig): media.AVRecorderProfile {
    return {
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: config.bitrate,
      videoCodec: config.codec === 'h265' 
        ? media.CodecMimeType.VIDEO_HEVC 
        : media.CodecMimeType.VIDEO_AVC,
      videoFrameWidth: config.width,
      videoFrameHeight: config.height,
      videoFrameRate: config.frameRate,
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
    };
  }

  async release(): Promise<void> {
    try {
      if (this.frontRecorder) {
        await this.frontRecorder.release();
        this.frontRecorder = null;
      }
      if (this.backRecorder) {
        await this.backRecorder.release();
        this.backRecorder = null;
      }
      Logger.info(TAG, 'Recorders released');
    } catch (error) {
      Logger.error(TAG, `Release failed: ${JSON.stringify(error)}`);
    }
  }
}
