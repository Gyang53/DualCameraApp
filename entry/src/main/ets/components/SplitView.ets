import { CameraPreview } from './CameraPreview';
import { Logger } from '../utils/Logger';

const TAG = 'SplitView';

@ComponentV2
export struct SplitView {
  @Param splitRatio: number = 0.5;
  @Param isVertical: boolean = true;
  @Param frontMirror: boolean = false;
  @Event onFrontSurfaceReady: (surfaceId: string) => void = () => {};
  @Event onBackSurfaceReady: (surfaceId: string) => void = () => {};

  build() {
    Stack() {
      if (this.isVertical) {
        Column() {
          CameraPreview({
            cameraPosition: 'front',
            isMirror: this.frontMirror
          })
            .height(`${this.splitRatio * 100}%`)
            .onSurfaceReady((surfaceId: string) => {
              Logger.info(TAG, `Front surface ready: ${surfaceId}`);
              this.onFrontSurfaceReady(surfaceId);
            })

          Divider()
            .width('100%')
            .height(2)
            .color(Color.White)

          CameraPreview({
            cameraPosition: 'back',
            isMirror: false
          })
            .height(`${(1 - this.splitRatio) * 100}%`)
            .onSurfaceReady((surfaceId: string) => {
              Logger.info(TAG, `Back surface ready: ${surfaceId}`);
              this.onBackSurfaceReady(surfaceId);
            })
        }
        .width('100%')
        .height('100%')
      } else {
        Row() {
          CameraPreview({
            cameraPosition: 'front',
            isMirror: this.frontMirror
          })
            .width(`${this.splitRatio * 100}%`)
            .onSurfaceReady((surfaceId: string) => {
              this.onFrontSurfaceReady(surfaceId);
            })

          Divider()
            .width(2)
            .height('100%')
            .color(Color.White)

          CameraPreview({
            cameraPosition: 'back',
            isMirror: false
          })
            .width(`${(1 - this.splitRatio) * 100}%`)
            .onSurfaceReady((surfaceId: string) => {
              this.onBackSurfaceReady(surfaceId);
            })
        }
        .width('100%')
        .height('100%')
      }

      this.RatioIndicator()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  @Builder
  RatioIndicator() {
    Row() {
      Text(`${Math.round(this.splitRatio * 100)}:${Math.round((1 - this.splitRatio) * 100)}`)
        .fontSize(12)
        .fontColor(Color.White)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .backgroundColor('#80000000')
        .borderRadius(4)
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .position({ x: 0, y: 10 })
  }
}
