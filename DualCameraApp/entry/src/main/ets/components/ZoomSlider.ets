@ComponentV2
export struct ZoomSlider {
  @Param minZoom: number = 1.0;
  @Param maxZoom: number = 6.0;
  @Param currentZoom: number = 1.0;
  @Event onZoomChange: (ratio: number) => void = () => {};

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
        .blockColor('#4CAF50')
        .trackColor('#333333')
        .selectedColor('#4CAF50')
        .onChange((value: number) => {
          this.onZoomChange(value);
        })
    }
    .width(60)
    .padding(8)
    .backgroundColor('#1A1A1A')
    .borderRadius(12)
  }
}
