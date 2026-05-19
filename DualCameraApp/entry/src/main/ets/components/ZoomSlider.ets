@Component
export struct ZoomSlider {
  @Prop minZoom: number = 1.0;
  @Prop maxZoom: number = 5.0;
  @State currentZoom: number = 1.0;
  private onZoomChange?: (ratio: number) => void;

  build() {
    Column() {
      Text(`${this.currentZoom.toFixed(1)}x`)
        .fontSize(16)
        .fontColor(Color.White)
        .margin({ bottom: 8 })

      Slider({
        value: this.currentZoom,
        min: this.minZoom,
        max: this.maxZoom,
        step: 0.1,
        style: SliderStyle.OutSet
      })
        .blockColor(Color.Red)
        .trackColor('#333333')
        .selectedColor(Color.Red)
        .onChange((value: number) => {
          this.currentZoom = value;
          if (this.onZoomChange) {
            this.onZoomChange(value);
          }
        })
    }
    .width(60)
    .padding(8)
    .backgroundColor('#2A2A2A')
    .borderRadius(12)
  }

  setOnZoomChange(callback: (ratio: number) => void): void {
    this.onZoomChange = callback;
  }
}
