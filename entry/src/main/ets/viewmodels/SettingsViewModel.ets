import { StorageService } from '../services/StorageService';
import { Logger } from '../utils/Logger';
import { UserSettings } from '../common/Types';

const TAG = 'SettingsViewModel';

@ObservedV2
export class SettingsViewModel {
  @Trace settings: UserSettings | null = null;
  @Trace isLoading: boolean = false;

  private storageService: StorageService | null = null;

  async initialize(context: Context): Promise<void> {
    this.isLoading = true;
    this.storageService = new StorageService();
    await this.storageService.initialize(context);
    this.settings = await this.storageService.loadSettings();
    this.isLoading = false;
    Logger.info(TAG, 'Settings loaded');
  }

  async updateRecordMode(mode: 'split' | 'pip'): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, recordMode: mode };
    await this.storageService.saveSettings(this.settings);
  }

  async updateMaxDuration(duration: number): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, maxDuration: duration };
    await this.storageService.saveSettings(this.settings);
  }

  async updateFileMode(mode: 'merged' | 'separate'): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, fileMode: mode };
    await this.storageService.saveSettings(this.settings);
  }

  async updateSplitRatio(ratio: number): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, splitRatio: ratio };
    await this.storageService.saveSettings(this.settings);
  }

  async updatePipPosition(position: 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight'): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, pipPosition: position };
    await this.storageService.saveSettings(this.settings);
  }

  async updateFrontMirror(enabled: boolean): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, frontMirror: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateGridLine(enabled: boolean): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, gridLine: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateTimestamp(enabled: boolean): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, timestamp: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateAudioMode(mode: 'shared' | 'separate'): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, audioMode: mode };
    await this.storageService.saveSettings(this.settings);
  }

  async updateColorSpace(space: 'auto' | 'sdr' | 'hdr'): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, colorSpace: space };
    await this.storageService.saveSettings(this.settings);
  }

  async updateFrontLight(enabled: boolean): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, frontLight: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateLowLightHint(enabled: boolean): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, lowLightHint: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateStorageHint(enabled: boolean): Promise<void> {
    if (!this.settings || !this.storageService) {
      return;
    }
    this.settings = { ...this.settings, storageHint: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async resetToDefaults(): Promise<void> {
    if (!this.storageService) {
      return;
    }
    this.settings = this.storageService.getDefaultSettings();
    await this.storageService.saveSettings(this.settings);
    Logger.info(TAG, 'Settings reset to defaults');
  }

  getDurationLabel(duration: number): string {
    if (duration === -1) {
      return '无限制';
    }
    const minutes: number = Math.floor(duration / 60000);
    return `${minutes}分钟`;
  }

  getFileModeLabel(mode: 'merged' | 'separate'): string {
    return mode === 'merged' ? '合并文件' : '分开文件';
  }

  getSplitRatioLabel(ratio: number): string {
    const percent: number = Math.round(ratio * 100);
    return `${percent}:${100 - percent}`;
  }

  getPipPositionLabel(position: string): string {
    const labelMap: Record<string, string> = {
      'topLeft': '左上',
      'topRight': '右上',
      'bottomLeft': '左下',
      'bottomRight': '右下'
    };
    return labelMap[position] || '右上';
  }

  getAudioModeLabel(mode: 'shared' | 'separate'): string {
    return mode === 'shared' ? '共用音轨' : '独立音轨';
  }

  getColorSpaceLabel(space: string): string {
    const labelMap: Record<string, string> = {
      'auto': '自动',
      'sdr': 'SDR',
      'hdr': 'HDR'
    };
    return labelMap[space] || '自动';
  }
}
