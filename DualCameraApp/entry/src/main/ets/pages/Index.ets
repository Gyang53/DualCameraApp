import { CameraService } from '../services/CameraService';
import { PermissionService } from '../services/PermissionService';
import { SplitView } from '../components/SplitView';
import { PIPView } from '../components/PIPView';
import { Logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG = 'Index';

@Entry
@ComponentV2
struct Index {
  @Local isInitialized: boolean = false;
  @Local hasPermissions: boolean = false;
  @Local isDualCameraSupported: boolean = false;
  @Local isRecording: boolean = false;
  @Local currentMode: 'split' | 'pip' = 'split';
  @Local recordingDuration: number = 0;
  @Local errorMessage: string = '';

  private cameraService: CameraService = new CameraService();
  private permissionService: PermissionService = new PermissionService();
  private frontSurfaceId: string = '';
  private backSurfaceId: string = '';
  private recordingTimer: number = -1;

  async aboutToAppear(): Promise<void> {
    Logger.info(TAG, 'Index page aboutToAppear');
    await this.checkAndRequestPermissions();
  }

  aboutToDisappear(): void {
    this.stopRecordingTimer();
    this.cameraService.release();
  }

  async checkAndRequestPermissions(): Promise<void> {
    const context = getContext(this);
    this.hasPermissions = await this.permissionService.requestAllPermissions(context);
    
    if (this.hasPermissions) {
      await this.initializeCamera(context);
    } else {
      this.errorMessage = '请授予相机、麦克风和存储权限';
    }
  }

  async initializeCamera(context: Context): Promise<void> {
    this.isInitialized = await this.cameraService.initialize(context);
    this.isDualCameraSupported = this.cameraService.isDualCameraSupported();

    if (!this.isDualCameraSupported) {
      this.errorMessage = '此设备不支持双摄并发';
      Logger.warn(TAG, 'Device does not support concurrent dual camera');
    }
  }

  async startDualPreview(): Promise<void> {
    if (!this.frontSurfaceId || !this.backSurfaceId) {
      Logger.warn(TAG, 'Surface IDs not ready');
      return;
    }

    const success = await this.cameraService.startConcurrentPreview(
      this.frontSurfaceId,
      this.backSurfaceId
    );

    if (!success) {
      this.errorMessage = '启动双摄预览失败';
    }
  }

  build() {
    Column() {
      this.PreviewArea()

      this.ControlBar()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  @Builder
  PreviewArea() {
    Stack() {
      if (!this.hasPermissions) {
        this.PermissionPrompt()
      } else if (!this.isDualCameraSupported) {
        this.NotSupportedPrompt()
      } else {
        if (this.currentMode === 'split') {
          SplitView({
            splitRatio: 0.5,
            isVertical: true,
            frontMirror: false
          })
            .onFrontSurfaceReady((surfaceId: string) => {
              this.frontSurfaceId = surfaceId;
              this.tryStartPreview();
            })
            .onBackSurfaceReady((surfaceId: string) => {
              this.backSurfaceId = surfaceId;
              this.tryStartPreview();
            })
        } else {
          PIPView({
            pipPosition: 'topRight',
            pipScale: 0.25,
            frontMirror: false
          })
            .onFrontSurfaceReady((surfaceId: string) => {
              this.frontSurfaceId = surfaceId;
              this.tryStartPreview();
            })
            .onBackSurfaceReady((surfaceId: string) => {
              this.backSurfaceId = surfaceId;
              this.tryStartPreview();
            })
        }
      }

      if (this.errorMessage) {
        this.ErrorOverlay()
      }

      if (this.isRecording) {
        this.RecordingIndicator()
      }
    }
    .width('100%')
    .layoutWeight(1)
  }

  @Builder
  PermissionPrompt() {
    Column() {
      Text('需要权限')
        .fontSize(24)
        .fontColor(Color.White)
      Text('请授予相机、麦克风和存储权限')
        .fontSize(14)
        .fontColor('#888888')
        .margin({ top: 8 })
      Button('授予权限')
        .margin({ top: 20 })
        .onClick(() => {
          this.checkAndRequestPermissions();
        })
    }
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  NotSupportedPrompt() {
    Column() {
      Text('不支持双摄')
        .fontSize(24)
        .fontColor(Color.White)
      Text('此设备不支持前后摄像头同时工作')
        .fontSize(14)
        .fontColor('#888888')
        .margin({ top: 8 })
    }
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  ErrorOverlay() {
    Column() {
      Text(this.errorMessage)
        .fontSize(14)
        .fontColor(Color.Red)
        .padding(8)
        .backgroundColor('#80000000')
        .borderRadius(4)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .position({ x: 0, y: '50%' })
  }

  @Builder
  RecordingIndicator() {
    Row() {
      Circle()
        .width(12)
        .height(12)
        .fill(Color.Red)
      Text(this.formatDuration(this.recordingDuration))
        .fontSize(14)
        .fontColor(Color.White)
        .margin({ left: 8 })
    }
    .padding({ left: 12, right: 12, top: 6, bottom: 6 })
    .backgroundColor('#80000000')
    .borderRadius(16)
    .position({ x: 0, y: 0 })
    .margin({ left: 16, top: 40 })
  }

  @Builder
  ControlBar() {
    Row() {
      this.ControlButton('相册', () => {
        Logger.info(TAG, 'Open album');
      })

      this.ControlButton('设置', () => {
        Logger.info(TAG, 'Open settings');
      })

      this.RecordButton()

      this.ControlButton('模式', () => {
        this.switchMode();
      })

      this.ControlButton('切换', () => {
        Logger.info(TAG, 'Switch cameras');
      })
    }
    .width('100%')
    .height(100)
    .justifyContent(FlexAlign.SpaceEvenly)
    .padding({ bottom: 20 })
    .backgroundColor('#1A1A1A')
  }

  @Builder
  ControlButton(label: string, action: () => void) {
    Button({ type: ButtonType.Circle }) {
      Text(label)
        .fontSize(12)
        .fontColor(Color.White)
    }
    .width(50)
    .height(50)
    .backgroundColor('#333333')
    .onClick(action)
  }

  @Builder
  RecordButton() {
    Stack() {
      Circle()
        .width(76)
        .height(76)
        .stroke(Color.White, width: 4)
        .fill(Color.Transparent)

      if (this.isRecording) {
        Rect()
          .width(24)
          .height(24)
          .fill(Color.Red)
          .borderRadius(4)
      } else {
        Circle()
          .width(60)
          .height(60)
          .fill(Color.Red)
      }
    }
    .width(80)
    .height(80)
    .onClick(() => {
      this.toggleRecording();
    })
  }

  private tryStartPreview(): void {
    if (this.frontSurfaceId && this.backSurfaceId && !this.cameraService.isSessionRunning()) {
      this.startDualPreview();
    }
  }

  private toggleRecording(): void {
    if (this.isRecording) {
      this.stopRecording();
    } else {
      this.startRecording();
    }
  }

  private startRecording(): void {
    this.isRecording = true;
    this.recordingDuration = 0;
    this.startRecordingTimer();
    Logger.info(TAG, 'Recording started');
  }

  private stopRecording(): void {
    this.isRecording = false;
    this.stopRecordingTimer();
    Logger.info(TAG, `Recording stopped, duration: ${this.recordingDuration}ms`);
  }

  private switchMode(): void {
    this.currentMode = this.currentMode === 'split' ? 'pip' : 'split';
    Logger.info(TAG, `Mode switched to: ${this.currentMode}`);
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

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}
