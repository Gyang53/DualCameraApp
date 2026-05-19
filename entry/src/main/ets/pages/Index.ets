import { CameraService, CameraSessionInfo } from '../services/CameraService';
import { RecordService, RecordingConfig, RecordingResult } from '../services/RecordService';
import { PermissionService } from '../services/PermissionService';
import { SplitView } from '../components/SplitView';
import { PIPView } from '../components/PIPView';
import { ControlPanel } from '../components/ControlPanel';
import { Logger } from '../utils/Logger';
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { router } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';

const TAG = 'Index';

type RecordState = 'idle' | 'preparing' | 'recording' | 'paused';

@Entry
@ComponentV2
struct Index {
  @Local isInitialized: boolean = false;
  @Local hasPermissions: boolean = false;
  @Local isDualCameraSupported: boolean = false;
  @Local recordState: RecordState = 'idle';
  @Local currentMode: 'split' | 'pip' = 'split';
  @Local recordingDuration: number = 0;
  @Local errorMessage: string = '';
  @Local showControlPanel: boolean = false;
  @Local showSuccessToast: boolean = false;
  @Local successMessage: string = '';
  @Local zoomRatio: number = 1.0;
  @Local exposureBias: number = 0;
  @Local flashEnabled: boolean = false;
  @Local stabilizationEnabled: boolean = true;

  private cameraService: CameraService = new CameraService();
  private recordService: RecordService = new RecordService();
  private permissionService: PermissionService = new PermissionService();

  private frontPreviewSurfaceId: string = '';
  private backPreviewSurfaceId: string = '';
  private recordingTimer: number = -1;
  private errorTimer: number = -1;
  private toastTimer: number = -1;
  private appContext: Context | null = null;
  private lastRecordingResult: RecordingResult | null = null;

  async aboutToAppear(): Promise<void> {
    Logger.info(TAG, 'Index page aboutToAppear');
    this.appContext = getContext(this) as Context;
    await this.checkAndRequestPermissions();
  }

  aboutToDisappear(): void {
    this.stopRecordingTimer();
    this.stopErrorTimer();
    this.stopToastTimer();
    this.cameraService.release();
    this.recordService.release();
  }

  private stopErrorTimer(): void {
    if (this.errorTimer !== -1) {
      clearTimeout(this.errorTimer);
      this.errorTimer = -1;
    }
  }

  private stopToastTimer(): void {
    if (this.toastTimer !== -1) {
      clearTimeout(this.toastTimer);
      this.toastTimer = -1;
    }
  }

  private showError(message: string): void {
    this.errorMessage = message;
    this.stopErrorTimer();
    this.errorTimer = setTimeout(() => {
      this.errorMessage = '';
    }, 3000) as number;
  }

  private showSuccess(message: string): void {
    this.successMessage = message;
    this.showSuccessToast = true;
    this.stopToastTimer();
    this.toastTimer = setTimeout(() => {
      this.showSuccessToast = false;
    }, 2000) as number;
  }

  async checkAndRequestPermissions(): Promise<void> {
    if (!this.appContext) return;
    
    this.hasPermissions = await this.permissionService.requestAllPermissions(this.appContext);
    
    if (this.hasPermissions) {
      await this.initializeCamera(this.appContext);
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

    await this.recordService.initialize();
  }

  async onSurfacesReady(frontSurfaceId: string, backSurfaceId: string): Promise<void> {
    this.frontPreviewSurfaceId = frontSurfaceId;
    this.backPreviewSurfaceId = backSurfaceId;
    
    if (frontSurfaceId && backSurfaceId && !this.cameraService.isSessionRunning()) {
      await this.startPreview();
    }
  }

  async startPreview(): Promise<void> {
    if (!this.frontPreviewSurfaceId || !this.backPreviewSurfaceId) {
      return;
    }

    const success = await this.cameraService.startConcurrentPreview(
      this.frontPreviewSurfaceId,
      this.backPreviewSurfaceId
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
              this.onSurfacesReady(surfaceId, this.backPreviewSurfaceId);
            })
            .onBackSurfaceReady((surfaceId: string) => {
              this.onSurfacesReady(this.frontPreviewSurfaceId, surfaceId);
            })
        } else {
          PIPView({
            pipPosition: 'topRight',
            pipScale: 0.25,
            frontMirror: false
          })
            .onFrontSurfaceReady((surfaceId: string) => {
              this.onSurfacesReady(surfaceId, this.backPreviewSurfaceId);
            })
            .onBackSurfaceReady((surfaceId: string) => {
              this.onSurfacesReady(this.frontPreviewSurfaceId, surfaceId);
            })
        }
      }

      if (this.errorMessage) {
        this.ErrorOverlay()
      }

      // Success toast
      if (this.showSuccessToast) {
        this.SuccessToast()
      }

      if (this.recordState === 'recording' || this.recordState === 'paused') {
        this.RecordingIndicator()
      }

      // Control Panel overlay
      if (this.showControlPanel) {
        Column() {
          Blank()
          ControlPanel({
            isVisible: this.showControlPanel,
            zoomRatio: this.zoomRatio,
            exposureBias: this.exposureBias,
            flashEnabled: this.flashEnabled,
            stabilizationEnabled: this.stabilizationEnabled,
            onZoomChange: (ratio: number) => {
              this.zoomRatio = ratio;
              this.cameraService.setZoomRatio(ratio, false);
            },
            onExposureChange: (bias: number) => {
              this.exposureBias = bias;
              this.cameraService.setExposureBias(bias, false);
            },
            onFlashToggle: (enabled: boolean) => {
              this.flashEnabled = enabled;
              this.cameraService.setFlashMode(enabled);
            },
            onStabilizationToggle: (enabled: boolean) => {
              this.stabilizationEnabled = enabled;
              this.cameraService.setStabilization(enabled, false);
              this.cameraService.setStabilization(enabled, true);
            },
            onClose: () => {
              this.showControlPanel = false;
            }
          })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
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
  SuccessToast() {
    Column() {
      Row() {
        Text('✓')
          .fontSize(16)
          .fontColor('#4CAF50')
        Text(this.successMessage)
          .fontSize(14)
          .fontColor(Color.White)
          .margin({ left: 8 })
      }
      .padding({ left: 16, right: 16, top: 10, bottom: 10 })
      .backgroundColor('#CC2A2A2A')
      .borderRadius(20)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .position({ x: 0, y: '40%' })
  }

  @Builder
  RecordingIndicator() {
    Row() {
      Circle()
        .width(12)
        .height(12)
        .fill(this.recordState === 'paused' ? '#FFA500' : Color.Red)
      Text(this.formatDuration(this.recordingDuration))
        .fontSize(14)
        .fontColor(Color.White)
        .margin({ left: 8 })
      if (this.recordState === 'paused') {
        Text('(已暂停)')
          .fontSize(12)
          .fontColor('#FFA500')
          .margin({ left: 4 })
      }
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
        this.openAlbum();
      })

      this.ControlButton('设置', () => {
        router.pushUrl({ url: 'pages/Settings' });
      })

      this.RecordButton()

      this.ControlButton('控制', () => {
        this.showControlPanel = !this.showControlPanel;
      })

      this.ControlButton('模式', () => {
        this.switchMode();
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

      if (this.recordState === 'recording') {
        Rect()
          .width(24)
          .height(24)
          .fill(Color.Red)
          .borderRadius(4)
      } else if (this.recordState === 'paused') {
        Row() {
          Rect().width(8).height(20).fill('#FFA500')
          Rect().width(8).height(20).fill('#FFA500').margin({ left: 4 })
        }
      } else if (this.recordState === 'preparing') {
        LoadingProgress()
          .width(40)
          .height(40)
          .color(Color.White)
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
      this.handleRecordAction();
    })
  }

  private async handleRecordAction(): Promise<void> {
    switch (this.recordState) {
      case 'idle':
        await this.startRecording();
        break;
      case 'recording':
        await this.stopRecording();
        break;
      case 'paused':
        await this.resumeRecording();
        break;
    }
  }

  private async startRecording(): Promise<void> {
    if (!this.appContext || !this.cameraService.isSessionRunning()) {
      this.errorMessage = '请先启动预览';
      return;
    }

    this.recordState = 'preparing';
    this.errorMessage = '';

    try {
      // 先停止当前预览
      await this.cameraService.stopPreview();

      // 准备录制
      const config: RecordingConfig = {
        width: 1920,
        height: 1080,
        frameRate: 30,
        bitrate: 5000000,
        isHdr: false
      };

      const surfaces = await this.recordService.prepareRecording(this.appContext, config);
      if (!surfaces) {
        this.errorMessage = '准备录制失败';
        this.recordState = 'idle';
        await this.startPreview();
        return;
      }

      // 重新启动带 VideoOutput 的预览
      const success = await this.cameraService.startConcurrentRecording(
        this.frontPreviewSurfaceId,
        this.backPreviewSurfaceId,
        surfaces.frontSurfaceId,
        surfaces.backSurfaceId
      );

      if (!success) {
        this.errorMessage = '启动录制预览失败';
        this.recordState = 'idle';
        await this.recordService.reset();
        await this.startPreview();
        return;
      }

      // 启动 VideoOutput
      await this.cameraService.startVideoOutput();

      // 开始录制
      const started = await this.recordService.startRecording();
      if (started) {
        this.recordState = 'recording';
        this.recordingDuration = 0;
        this.startRecordingTimer();
        Logger.info(TAG, 'Recording started');
      } else {
        this.errorMessage = '开始录制失败';
        this.recordState = 'idle';
        await this.recordService.reset();
        await this.startPreview();
      }
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Start recording failed: ${err.message}`);
      this.errorMessage = `录制失败: ${err.message}`;
      this.recordState = 'idle';
      await this.recordService.reset();
      await this.startPreview();
    }
  }

  private async pauseRecording(): Promise<void> {
    const success = await this.recordService.pauseRecording();
    if (success) {
      this.recordState = 'paused';
      this.stopRecordingTimer();
      await this.cameraService.stopVideoOutput();
      Logger.info(TAG, 'Recording paused');
    }
  }

  private async resumeRecording(): Promise<void> {
    const success = await this.recordService.resumeRecording();
    if (success) {
      this.recordState = 'recording';
      this.startRecordingTimer();
      await this.cameraService.startVideoOutput();
      Logger.info(TAG, 'Recording resumed');
    }
  }

  private async stopRecording(): Promise<void> {
    this.stopRecordingTimer();

    try {
      const result = await this.recordService.stopRecording();
      await this.cameraService.stopVideoOutput();

      if (result) {
        this.lastRecordingResult = result;
        Logger.info(TAG, `Recording saved: ${JSON.stringify(result)}`);
        const duration = Math.floor(result.duration / 1000);
        const minutes = Math.floor(duration / 60);
        const seconds = duration % 60;
        this.showSuccess(`录制完成 ${minutes}分${seconds}秒`);
      }

      await this.recordService.reset();
      await this.startPreview();

      this.recordState = 'idle';
      this.recordingDuration = 0;
      Logger.info(TAG, 'Recording stopped and preview restarted');
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Stop recording failed: ${err.message}`);
      this.showError('停止录制失败');
    }
  }

  private async openAlbum(): Promise<void> {
    if (!this.appContext) {
      return;
    }
    try {
      const context = this.appContext as common.UIAbilityContext;
      await context.startAbility({
        action: 'ohos.want.action.VIEW',
        type: 'video/*',
        flags: 0x20000000
      });
    } catch (error) {
      const err = error as BusinessError;
      Logger.error(TAG, `Open album failed: ${err.message}`);
      this.showError('打开相册失败');
    }
  }

  private switchMode(): void {
    if (this.recordState !== 'idle') {
      this.errorMessage = '录制中无法切换模式';
      return;
    }
    this.currentMode = this.currentMode === 'split' ? 'pip' : 'split';
    Logger.info(TAG, `Mode switched to: ${this.currentMode}`);
  }

  private startRecordingTimer(): void {
    this.recordingTimer = setInterval(() => {
      this.recordingDuration = this.recordService.getRecordingDuration();
    }, 100);
  }

  private stopRecordingTimer(): void {
    if (this.recordingTimer !== -1) {
      clearInterval(this.recordingTimer);
      this.recordingTimer = -1;
    }
  }

  private formatDuration(ms: number): string {
    const totalSeconds = Math.floor(ms / 1000);
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    if (hours > 0) {
      return `${hours}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    }
    return `${minutes}:${seconds.toString().padStart(2, '0')}`;
  }
}
