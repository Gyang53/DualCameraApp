import { CameraViewModel } from '../viewmodels/CameraViewModel';
import { Logger } from '../utils/Logger';

const TAG = 'Index';

@Entry
@Component
struct Index {
  @State viewModel: CameraViewModel = new CameraViewModel();
  @State isRecording: boolean = false;
  @State currentMode: 'split' | 'pip' = 'split';

  aboutToAppear(): void {
    Logger.info(TAG, 'Index page aboutToAppear');
    this.viewModel.initialize(getContext(this));
  }

  build() {
    Column() {
      // 预览区域
      Stack() {
        Text('双摄预览区域')
          .fontSize(20)
          .fontColor(Color.White)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Color.Black)

      // 控制栏
      Row() {
        // 相册按钮
        Button({ type: ButtonType.Circle }) {
          Text('相册')
            .fontSize(12)
            .fontColor(Color.White)
        }
        .width(50)
        .height(50)
        .backgroundColor('#333333')

        // 设置按钮
        Button({ type: ButtonType.Circle }) {
          Text('设置')
            .fontSize(12)
            .fontColor(Color.White)
        }
        .width(50)
        .height(50)
        .backgroundColor('#333333')

        // 录制按钮
        Button({ type: ButtonType.Circle }) {
          if (this.isRecording) {
            Text('停止')
              .fontSize(12)
              .fontColor(Color.Red)
          } else {
            Text('录制')
              .fontSize(12)
              .fontColor(Color.White)
          }
        }
        .width(70)
        .height(70)
        .backgroundColor(this.isRecording ? Color.White : '#FF0000')
        .onClick(() => {
          this.toggleRecording();
        })

        // 模式切换按钮
        Button({ type: ButtonType.Circle }) {
          Text('模式')
            .fontSize(12)
            .fontColor(Color.White)
        }
        .width(50)
        .height(50)
        .backgroundColor('#333333')
        .onClick(() => {
          this.switchMode();
        })

        // 切换摄像头
        Button({ type: ButtonType.Circle }) {
          Text('切换')
            .fontSize(12)
            .fontColor(Color.White)
        }
        .width(50)
        .height(50)
        .backgroundColor('#333333')
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.SpaceEvenly)
      .padding({ bottom: 20 })
      .backgroundColor('#1A1A1A')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  private toggleRecording(): void {
    if (this.isRecording) {
      this.viewModel.stopRecording();
    } else {
      this.viewModel.startRecording();
    }
    this.isRecording = !this.isRecording;
  }

  private switchMode(): void {
    this.currentMode = this.currentMode === 'split' ? 'pip' : 'split';
    this.viewModel.switchMode(this.currentMode);
  }
}
