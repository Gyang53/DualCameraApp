import { CameraPreview } from './CameraPreview';

@Component
export struct SplitView {
  @Prop frontSurfaceId: string = '\;
  @Prop backSurfaceId: string = '\;
  @Prop splitRatio: number = 0.5;
  @Prop isVertical: boolean = true;

  build() {
    if (this.isVertical) {
      Column() {
        CameraPreview({
          surfaceId: this.frontSurfaceId,
          cameraPosition: 'front'
        })
          .height(`${this.splitRatio * 100}%`)

        CameraPreview({
          surfaceId: this.backSurfaceId,
          cameraPosition: 'back'
        })
          .height(`${(1 - this.splitRatio) * 100}%`)
      }
      .width('100%')
      .height('100%')
    } else {
      Row() {
        CameraPreview({
          surfaceId: this.frontSurfaceId,
          cameraPosition: 'front'
        })
          .width(`${this.splitRatio * 100}%`)

        CameraPreview({
          surfaceId: this.backSurfaceId,
          cameraPosition: 'back'
        })
          .width(`${(1 - this.splitRatio) * 100}%`)
      }
      .width('100%')
      .height('100%')
    }
  }
}
