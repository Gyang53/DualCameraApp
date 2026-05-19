import { Logger } from '../utils/Logger';

const TAG = 'ControlPanel';

@ComponentV2
export struct ControlPanel {
  @Param isVisible: boolean = false;
  @Param zoomRatio: number = 1.0;
  @Param exposureBias: number = 0;
  @Param flashEnabled: boolean = false;
  @Param stabilizationEnabled: boolean = true;
  @Event onZoomChange: (ratio: number) => void = () => {};
  @Event onExposureChange: (bias: number) => void = () => {};
  @Event onFlashToggle: (enabled: boolean) => void = () => {};
  @Event onStabilizationToggle: (enabled: boolean) => void = () => {};
  @Event onClose: () => void = () => {};

  build() {
    if (this.isVisible) {
      Column() {
        // Header
        Row() {
          Text('相机控制')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
          Blank()
          Text('✕')
            .fontSize(18)
            .fontColor('#888888')
            .onClick(() => {
              this.onClose();
            })
        }
        .width('100%')
        .padding({ bottom: 12 })

        // Zoom control
        Row() {
          Text('变焦')
            .fontSize(14)
            .fontColor(Color.White)
            .width(60)

          Slider({
            value: this.zoomRatio,
            min: 1.0,
            max: 6.0,
            step: 0.1
          })
            .layoutWeight(1)
            .blockColor('#4CAF50')
            .trackColor('#333333')
            .selectedColor('#4CAF50')
            .onChange((value: number) => {
              this.onZoomChange(value);
            })

          Text(`${this.zoomRatio.toFixed(1)}x`)
            .fontSize(14)
            .fontColor(Color.White)
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .margin({ top: 8 })

        // Exposure control
        Row() {
          Text('曝光')
            .fontSize(14)
            .fontColor(Color.White)
            .width(60)

          Slider({
            value: this.exposureBias + 4,
            min: 0,
            max: 8,
            step: 0.5
          })
            .layoutWeight(1)
            .blockColor('#4CAF50')
            .trackColor('#333333')
            .selectedColor('#4CAF50')
            .onChange((value: number) => {
              this.onExposureChange(value - 4);
            })

          Text(`${this.exposureBias >= 0 ? '+' : ''}${this.exposureBias.toFixed(1)}`)
            .fontSize(14)
            .fontColor(Color.White)
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .margin({ top: 12 })

        // Flash and Stabilization toggles
        Row() {
          Column() {
            Text(this.flashEnabled ? '🔦' : '💫')
              .fontSize(24)
            Text('闪光灯')
              .fontSize(12)
              .fontColor(this.flashEnabled ? '#4CAF50' : '#888888')
              .margin({ top: 4 })
          }
          .padding(12)
          .backgroundColor(this.flashEnabled ? '#2A4A2A' : '#2A2A2A')
          .borderRadius(8)
          .onClick(() => {
            this.onFlashToggle(!this.flashEnabled);
          })

          Column() {
            Text(this.stabilizationEnabled ? '🎬' : '📷')
              .fontSize(24)
            Text('防抖')
              .fontSize(12)
              .fontColor(this.stabilizationEnabled ? '#4CAF50' : '#888888')
              .margin({ top: 4 })
          }
          .padding(12)
          .backgroundColor(this.stabilizationEnabled ? '#2A4A2A' : '#2A2A2A')
          .borderRadius(8)
          .margin({ left: 16 })
          .onClick(() => {
            this.onStabilizationToggle(!this.stabilizationEnabled);
          })
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#1A1A1A')
      .borderRadius({ topLeft: 16, topRight: 16 })
    }
  }
}
