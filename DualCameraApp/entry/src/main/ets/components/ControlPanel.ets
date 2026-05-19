import { Logger } from '../utils/Logger';

const TAG = 'ControlPanel';

@Component
export struct ControlPanel {
  @Prop isVisible: boolean = false;
  @State zoomRatio: number = 1.0;
  @State exposureBias: number = 0;
  private onZoomChange?: (ratio: number) => void;
  private onExposureChange?: (bias: number) => void;

  build() {
    if (this.isVisible) {
      Column() {
        // Zoom control
        Row() {
          Text('变焦')
            .fontSize(14)
            .fontColor(Color.White)
            .width(50)

          Slider({
            value: this.zoomRatio,
            min: 1.0,
            max: 5.0,
            step: 0.1
          })
            .layoutWeight(1)
            .blockColor(Color.Red)
            .trackColor('#333333')
            .onChange((value: number) => {
              this.zoomRatio = value;
              if (this.onZoomChange) {
                this.onZoomChange(value);
              }
            })

          Text(`${this.zoomRatio.toFixed(1)}x`)
            .fontSize(14)
            .fontColor(Color.White)
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })

        // Exposure control
        Row() {
          Text('曝光')
            .fontSize(14)
            .fontColor(Color.White)
            .width(50)

          Slider({
            value: this.exposureBias + 4,
            min: 0,
            max: 8,
            step: 0.5
          })
            .layoutWeight(1)
            .blockColor(Color.Red)
            .trackColor('#333333')
            .onChange((value: number) => {
              this.exposureBias = value - 4;
              if (this.onExposureChange) {
                this.onExposureChange(this.exposureBias);
              }
            })

          Text(`${this.exposureBias >= 0 ? '+' : ''}${this.exposureBias.toFixed(1)}`)
            .fontSize(14)
            .fontColor(Color.White)
            .width(50)
            .textAlign(TextAlign.End)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
        .margin({ top: 16 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#2A2A2A')
      .borderRadius(12)
    }
  }

  setOnZoomChange(callback: (ratio: number) => void): void {
    this.onZoomChange = callback;
  }

  setOnExposureChange(callback: (bias: number) => void): void {
    this.onExposureChange = callback;
  }
}
