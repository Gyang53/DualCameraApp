import { StorageService } from '../services/StorageService';
import { Logger } from '../utils/Logger';
import { UserSettings } from '../common/Types';

const TAG = 'SettingsViewModel';

export class SettingsViewModel {
  @Track settings: UserSettings | null = null;
  @Track isLoading: boolean = false;

  private storageService: StorageService;

  constructor() {
    this.storageService = new StorageService();
  }

  async initialize(context: Context): Promise<void> {
    this.isLoading = true;
    await this.storageService.initialize(context);
    this.settings = await this.storageService.loadSettings();
    this.isLoading = false;
    Logger.info(TAG, 'Settings loaded');
  }

  async updateRecordMode(mode: 'split' | 'pip'): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, recordMode: mode };
    await this.storageService.saveSettings(this.settings);
  }

  async updateSplitRatio(ratio: number): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, splitRatio: ratio };
    await this.storageService.saveSettings(this.settings);
  }

  async updatePipPosition(position: 'topLeft' | 'topRight' | 'bottomLeft' | 'bottomRight'): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, pipPosition: position };
    await this.storageService.saveSettings(this.settings);
  }

  async updateMaxDuration(duration: number): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, maxDuration: duration };
    await this.storageService.saveSettings(this.settings);
  }

  async updateFileMode(mode: 'merged' | 'separate'): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, fileMode: mode };
    await this.storageService.saveSettings(this.settings);
  }

  async updateFrontMirror(enabled: boolean): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, frontMirror: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateGridLine(enabled: boolean): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, gridLine: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateTimestamp(enabled: boolean): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, timestamp: enabled };
    await this.storageService.saveSettings(this.settings);
  }

  async updateColorSpace(space: 'auto' | 'sdr' | 'hdr'): Promise<void> {
    if (!this.settings) return;
    this.settings = { ...this.settings, colorSpace: space };
    await this.storageService.saveSettings(this.settings);
  }

  async resetToDefaults(): Promise<void> {
    this.settings = this.storageService.getDefaultSettings();
    await this.storageService.saveSettings(this.settings);
    Logger.info(TAG, 'Settings reset to defaults');
  }
}
