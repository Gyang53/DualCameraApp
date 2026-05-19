import { CameraPreview } from './CameraPreview';
import { Logger } from '../utils/Logger';

const TAG = 'PIPView';

@ComponentV2
export struct PIPView {
  @Param pipPosition: 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight' = 'topRight';
  @Param pipScale: number = 0.25;
  @Param frontMirror: boolean = false;
  @Event onFrontSurfaceReady: (surfaceId: string) => void = () => {};
  @Event onBackSurfaceReady: (surfaceId: string) => void = () => {};

  @Local pipOffsetX: number = 0;
  @Local pipOffsetY: number = 0;
  @Local isDragging: boolean = false;

  build() {
    Stack() {
      CameraPreview({
        cameraPosition: 'back',
        isMirror: false
      })
        .width('100%')
        .height('100%')
        .onSurfaceReady((surfaceId: string) => {
          Logger.info(TAG, `Back surface ready: ${surfaceId}`);
          this.onBackSurfaceReady(surfaceId);
        })

      this.PIPWindow()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
  }

  @Builder
  PIPWindow() {
    Column() {
      CameraPreview({
        cameraPosition: 'front',
        isMirror: this.frontMirror
      })
        .width('100%')
        .height('100%')
        .onSurfaceReady((surfaceId: string) => {
          Logger.info(TAG, `Front surface ready: ${surfaceId}`);
          this.onFrontSurfaceReady(surfaceId);
        })
    }
    .width(`${this.pipScale * 100}%`)
    .aspectRatio(3 / 4)
    .borderRadius(12)
    .border({ width: 2, color: Color.White })
    .shadow({ radius: 10, color: '#40000000', offsetX: 0, offsetY: 2 })
    .position(this.getPipPosition())
    .gesture(
      PanGesture()
        .onActionStart(() => {
          this.isDragging = true;
        })
        .onActionUpdate((event: GestureEvent) => {
          this.pipOffsetX += event.offsetX;
          this.pipOffsetY += event.offsetY;
        })
        .onActionEnd(() => {
          this.isDragging = false;
          this.snapToNearestCorner();
        })
    )
  }

  private getPipPosition(): { x: string; y: string } {
    const margin = 3;
    const baseX = this.pipOffsetX;
    const baseY = this.pipOffsetY;

    switch (this.pipPosition) {
      case 'topLeft':
        return { x: `${margin + baseX}%`, y: `${margin + baseY}%` };
      case 'topRight':
        return { x: `${100 - this.pipScale * 100 - margin + baseX}%`, y: `${margin + baseY}%` };
      case 'bottomLeft':
        return { x: `${margin + baseX}%`, y: `${100 - this.pipScale * 100 * 4 / 3 - margin + baseY}%` };
      case 'bottomRight':
        return { x: `${100 - this.pipScale * 100 - margin + baseX}%`, y: `${100 - this.pipScale * 100 * 4 / 3 - margin + baseY}%` };
    }
  }

  private snapToNearestCorner(): void {
    const positions: ('topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight')[] = [
      'topLeft', 'topRight', 'bottomLeft', 'bottomRight'
    ];
    
    this.pipOffsetX = 0;
    this.pipOffsetY = 0;
  }
}
