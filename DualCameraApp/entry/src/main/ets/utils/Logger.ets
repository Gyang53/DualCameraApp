import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0xFF00;

export class Logger {
  static info(tag: string, message: string): void {
    hilog.info(DOMAIN, tag, message);
  }

  static debug(tag: string, message: string): void {
    hilog.debug(DOMAIN, tag, message);
  }

  static warn(tag: string, message: string): void {
    hilog.warn(DOMAIN, tag, message);
  }

  static error(tag: string, message: string): void {
    hilog.error(DOMAIN, tag, message);
  }
}
