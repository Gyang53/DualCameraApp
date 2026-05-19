@Component
export struct RecordButton {
  @Prop isRecording: boolean = false;
  private onRecordClick?: () => void;

  build() {
    Stack() {
      // Outer ring
      Circle()
        .width(76)
        .height(76)
        .stroke(Color.White, width: 4)
        .fill(Color.Transparent)

      // Inner button
      if (this.isRecording) {
        // Stop icon (square)
        Rect()
          .width(24)
          .height(24)
          .fill(Color.Red)
          .borderRadius(4)
      } else {
        // Record icon (circle)
        Circle()
          .width(60)
          .height(60)
          .fill(Color.Red)
      }
    }
    .width(80)
    .height(80)
    .onClick(() => {
      if (this.onRecordClick) {
        this.onRecordClick();
      }
    })
  }

  setOnClick(callback: () => void): void {
    this.onRecordClick = callback;
  }
}
