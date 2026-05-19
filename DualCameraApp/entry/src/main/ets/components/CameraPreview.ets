import { camera } from '@kit.CameraKit';
import { Logger } from '../utils/Logger';

const TAG = 'CameraPreview';

export interface CameraPreviewCallbacks {
  onSurfaceReady: (surfaceId: string) => void;
  onError: (error: string) => void;
}

@ComponentV2
export struct CameraPreview {
  @Param cameraPosition: 'front' | 'back' = 'back';
  @Param isMirror: boolean = false;
  @Event onSurfaceReady: (surfaceId: string) => void = () => {};
  @Event onError: (error: string) => void = () => {};

  private xComponentController: XComponentController = new XComponentController();
  private surfaceId: string = '';

  build() {
    Stack() {
      XComponent({
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .onLoad(() => {
          this.surfaceId = this.xComponentController.getXComponentSurfaceId();
          Logger.info(TAG, `XComponent loaded, surfaceId: ${this.surfaceId}`);
          if (this.surfaceId) {
            this.onSurfaceReady(this.surfaceId);
          } else {
            this.onError('Failed to get surface ID');
          }
        })
        .width('100%')
        .height('100%')
        .mirror(this.isMirror && this.cameraPosition === 'front')

      if (!this.surfaceId) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(Color.White)
          Text(`${this.cameraPosition === 'front' ? '前置' : '后置'}摄像头`)
            .fontSize(14)
            .fontColor(Color.White)
            .margin({ top: 8 })
        }
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .justifyContent(FlexAlign.Center)
    .alignContent(Alignment.Center)
  }

  getSurfaceId(): string {
    return this.surfaceId;
  }
}
