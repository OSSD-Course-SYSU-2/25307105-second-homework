import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import LunchPickerViewModel, { LunchOption } from '../../viewmodel/LunchPickerViewModel';
import LunchHistoryItem from '../../viewmodel/LunchHistoryItem';

class LunchStorage {
  private static readonly STORE_NAME: string = 'lunch_picker_preferences';
  private static readonly OPTIONS_KEY: string = 'lunch_options';
  private static readonly HISTORY_KEY: string = 'lunch_history';

  private preferencesStore?: preferences.Preferences;

  initialize(context?: Context): void {
    if (context === undefined || this.preferencesStore !== undefined) {
      return;
    }

    try {
      this.preferencesStore = preferences.getPreferencesSync(context, {
        name: LunchStorage.STORE_NAME
      });
    } catch (_error) {
      this.preferencesStore = undefined;
    }
  }

  loadOptions(): LunchOption[] {
    const rawValue: string = this.getStringValue(LunchStorage.OPTIONS_KEY);
    if (rawValue.length === 0) {
      return [];
    }
    return LunchPickerViewModel.upgradeOptions(this.parseOptions(rawValue));
  }

  saveOptions(options: LunchOption[]): void {
    this.setStringValue(LunchStorage.OPTIONS_KEY, JSON.stringify(options));
  }

  loadHistory(): LunchHistoryItem[] {
    const rawValue: string = this.getStringValue(LunchStorage.HISTORY_KEY);
    if (rawValue.length === 0) {
      return [];
    }
    return this.parseHistory(rawValue);
  }

  saveHistory(historyItems: LunchHistoryItem[]): void {
    this.setStringValue(LunchStorage.HISTORY_KEY, JSON.stringify(historyItems));
  }

  clearHistory(): void {
    this.setStringValue(LunchStorage.HISTORY_KEY, JSON.stringify([]));
  }

  private getStringValue(key: string): string {
    if (this.preferencesStore === undefined) {
      return '';
    }
    try {
      return this.preferencesStore.getSync(key, '') as string;
    } catch (_error) {
      return '';
    }
  }

  private setStringValue(key: string, value: string): void {
    if (this.preferencesStore === undefined) {
      return;
    }
    try {
      this.preferencesStore.putSync(key, value);
      this.preferencesStore.flushSync();
    } catch (_error) {
    }
  }

  private parseOptions(rawValue: string): LunchOption[] {
    try {
      return JSON.parse(rawValue) as LunchOption[];
    } catch (_error) {
      return [];
    }
  }

  private parseHistory(rawValue: string): LunchHistoryItem[] {
    try {
      return JSON.parse(rawValue) as LunchHistoryItem[];
    } catch (_error) {
      return [];
    }
  }
}

export default new LunchStorage();
