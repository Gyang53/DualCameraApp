import { CameraPreview } from './CameraPreview';

@Component
export struct PIPView {
  @Prop frontSurfaceId: string = '\;
  @Prop backSurfaceId: string = '\;
  @Prop pipPosition: 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight' = 'topRight';
  @Prop pipScale: number = 0.25;
  @State pipOffsetX: number = 0;
  @State pipOffsetY: number = 0;

  build() {
    Stack() {
      // Main camera (back)
      CameraPreview({
        surfaceId: this.backSurfaceId,
        cameraPosition: 'back'
      })
        .width('100%')
        .height('100%')

      // PIP camera (front)
      CameraPreview({
        surfaceId: this.frontSurfaceId,
        cameraPosition: 'front'
      })
        .width(`${this.pipScale * 100}%`)
        .height(`${this.pipScale * 100}%`)
        .borderRadius(12)
        .border({ width: 2, color: Color.White })
        .position(this.getPipPosition())
    }
    .width('100%')
    .height('100%')
  }

  private getPipPosition(): { x: string; y: string } {
    const margin = '3%';
    switch (this.pipPosition) {
      case 'topLeft':
        return { x: margin, y: margin };
      case 'topRight':
        return { x: `${100 - this.pipScale * 100 - 3}%`, y: margin };
      case 'bottomLeft':
        return { x: margin, y: `${100 - this.pipScale * 100 - 3}%` };
      case 'bottomRight':
        return { x: `${100 - this.pipScale * 100 - 3}%`, y: `${100 - this.pipScale * 100 - 3}%` };
    }
  }
}
