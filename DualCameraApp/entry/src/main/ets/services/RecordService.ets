import { media } from '@kit.MediaKit';
import { camera } from '@kit.CameraKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { Logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'RecordService';

export interface RecordingConfig {
  width: number;
  height: number;
  frameRate: number;
  bitrate: number;
  isHdr: boolean;
}

export interface RecordingResult {
  frontFilePath: string;
  backFilePath: string;
  duration: number;
}

export class RecordService {
  private frontRecorder: media.AVRecorder | null = null;
  private backRecorder: media.AVRecorder | null = null;

  private frontFile: fileIo.File | null = null;
  private backFile: fileIo.File | null = null;
  private frontFilePath: string = '';
  private backFilePath: string = '';

  private isRecording: boolean = false;
  private startTime: number = 0;
  private duration: number = 0;

  async initialize(): Promise<boolean> {
    try {
      this.frontRecorder = await media.createAVRecorder();
      this.backRecorder = await media.createAVRecorder();
      Logger.info(TAG, 'Recorders initialized');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Initialize failed: ${err.message}`);
      return false;
    }
  }

  private generateFileName(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const hour = String(now.getHours()).padStart(2, '0');
    const minute = String(now.getMinutes()).padStart(2, '0');
    const second = String(now.getSeconds()).padStart(2, '0');
    return `VID_${year}${month}${day}_${hour}${minute}${second}`;
  }

  private async createVideoFile(context: Context, fileName: string): Promise<{ file: fileIo.File; filePath: string } | null> {
    try {
      const accessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      const options: photoAccessHelper.CreateOptions = {
        title: fileName
      };
      
      const videoUri = await accessHelper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', options);
      const file = fileIo.openSync(videoUri, fileIo.OpenMode.READ_WRITE);
      
      return { file, filePath: videoUri };
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Create video file failed: ${err.message}`);
      return null;
    }
  }

  private buildRecorderProfile(config: RecordingConfig): media.AVRecorderProfile {
    return {
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: config.bitrate,
      videoCodec: config.isHdr ? media.CodecMimeType.VIDEO_HEVC : media.CodecMimeType.VIDEO_AVC,
      videoFrameWidth: config.width,
      videoFrameHeight: config.height,
      videoFrameRate: config.frameRate,
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      isHdr: config.isHdr
    };
  }

  async prepareRecording(
    context: Context,
    config: RecordingConfig
  ): Promise<{ frontSurfaceId: string; backSurfaceId: string } | null> {
    if (!this.frontRecorder || !this.backRecorder) {
      Logger.error(TAG, 'Recorders not initialized');
      return null;
    }

    try {
      const baseName = this.generateFileName();

      // 创建视频文件
      const frontResult = await this.createVideoFile(context, `${baseName}_front`);
      if (!frontResult) {
        return null;
      }
      this.frontFile = frontResult.file;
      this.frontFilePath = frontResult.filePath;

      const backResult = await this.createVideoFile(context, `${baseName}_back`);
      if (!backResult) {
        await this.closeFile(this.frontFile);
        return null;
      }
      this.backFile = backResult.file;
      this.backFilePath = backResult.filePath;

      const profile = this.buildRecorderProfile(config);

      const avConfig: media.AVRecorderConfig = {
        audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
        videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
        profile: profile,
        url: `fd://${this.frontFile.fd.toString()}`,
        rotation: 0,
        metadata: { videoOrientation: '0' }
      };

      // 准备前摄录制器
      await this.frontRecorder.prepare(avConfig);
      const frontSurfaceId = await this.frontRecorder.getInputSurface();

      // 准备后摄录制器
      avConfig.url = `fd://${this.backFile.fd.toString()}`;
      await this.backRecorder.prepare(avConfig);
      const backSurfaceId = await this.backRecorder.getInputSurface();

      Logger.info(TAG, 'Recording prepared successfully');
      return { frontSurfaceId, backSurfaceId };
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Prepare recording failed: ${err.message}`);
      await this.cleanup();
      return null;
    }
  }

  async startRecording(): Promise<boolean> {
    if (!this.frontRecorder || !this.backRecorder) {
      Logger.error(TAG, 'Recorders not prepared');
      return false;
    }

    if (this.isRecording) {
      Logger.warn(TAG, 'Already recording');
      return false;
    }

    try {
      await this.frontRecorder.start();
      await this.backRecorder.start();
      
      this.isRecording = true;
      this.startTime = Date.now();
      Logger.info(TAG, 'Recording started');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Start recording failed: ${err.message}`);
      return false;
    }
  }

  async pauseRecording(): Promise<boolean> {
    if (!this.isRecording || !this.frontRecorder || !this.backRecorder) {
      return false;
    }

    try {
      await this.frontRecorder.pause();
      await this.backRecorder.pause();
      this.duration += Date.now() - this.startTime;
      Logger.info(TAG, 'Recording paused');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Pause recording failed: ${err.message}`);
      return false;
    }
  }

  async resumeRecording(): Promise<boolean> {
    if (!this.frontRecorder || !this.backRecorder) {
      return false;
    }

    try {
      await this.frontRecorder.resume();
      await this.backRecorder.resume();
      this.startTime = Date.now();
      Logger.info(TAG, 'Recording resumed');
      return true;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Resume recording failed: ${err.message}`);
      return false;
    }
  }

  async stopRecording(): Promise<RecordingResult | null> {
    if (!this.isRecording) {
      return null;
    }

    try {
      if (this.frontRecorder) {
        await this.frontRecorder.stop();
      }
      if (this.backRecorder) {
        await this.backRecorder.stop();
      }

      this.duration += Date.now() - this.startTime;
      this.isRecording = false;

      const result: RecordingResult = {
        frontFilePath: this.frontFilePath,
        backFilePath: this.backFilePath,
        duration: this.duration
      };

      Logger.info(TAG, `Recording stopped, duration: ${this.duration}ms`);
      return result;
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Stop recording failed: ${err.message}`);
      return null;
    }
  }

  getRecordingDuration(): number {
    if (!this.isRecording) {
      return this.duration;
    }
    return this.duration + (Date.now() - this.startTime);
  }

  isCurrentlyRecording(): boolean {
    return this.isRecording;
  }

  private async closeFile(file: fileIo.File | null): Promise<void> {
    if (file) {
      try {
        await fileIo.close(file.fd);
      } catch (error) {
        const err = error as BusinessError;
        Logger.error(TAG, `Close file failed: ${err.message}`);
      }
    }
  }

  private async cleanup(): Promise<void> {
    await this.closeFile(this.frontFile);
    await this.closeFile(this.backFile);
    this.frontFile = null;
    this.backFile = null;
    this.frontFilePath = '';
    this.backFilePath = '';
  }

  async reset(): Promise<void> {
    try {
      if (this.frontRecorder) {
        const state = this.frontRecorder.state;
        if (state === 'started' || state === 'paused') {
          await this.frontRecorder.stop();
        }
        if (state === 'stopped' || state === 'prepared') {
          await this.frontRecorder.reset();
        }
      }

      if (this.backRecorder) {
        const state = this.backRecorder.state;
        if (state === 'started' || state === 'paused') {
          await this.backRecorder.stop();
        }
        if (state === 'stopped' || state === 'prepared') {
          await this.backRecorder.reset();
        }
      }

      await this.cleanup();
      this.isRecording = false;
      this.duration = 0;
      Logger.info(TAG, 'Recorders reset');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Reset failed: ${err.message}`);
    }
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
      await this.cleanup();
      Logger.info(TAG, 'Recorders released');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Release failed: ${err.message}`);
    }
  }
}
