export const LUNCH_CONTINUATION_STATE_KEY: string = 'lunchContinuationState';
export const LUNCH_CONTINUATION_PAGE_ID: string = 'LunchPickerPage';
export const LUNCH_CONTINUATION_RESTORE_PENDING_KEY: string = 'lunchContinuationRestorePending';

export interface LunchContinuationSourceOption {
  id: number;
  name: string;
  tags: string[];
}

export interface LunchContinuationSourceHistoryItem {
  id: number;
  name: string;
  pickedAt: string;
}

export interface LunchContinuationOption {
  id: number;
  name: string;
  tags: string[];
}

export interface LunchContinuationHistoryItem {
  id: number;
  name: string;
  pickedAt: string;
}

export interface LunchContinuationState {
  version: number;
  pageId: string;
  activeTag: string;
  candidateName: string;
  candidateTagsText: string;
  selectedOptionId: number;
  resultText: string;
  helperText: string;
  resultTagText: string;
  hasPendingResult: boolean;
  rerollCount: number;
  showInputPanel: boolean;
  showHistoryPanel: boolean;
  showManagePanel: boolean;
  lunchOptions: LunchContinuationOption[];
  historyItems: LunchContinuationHistoryItem[];
  updatedAt: number;
}

export default class LunchContinuationStateModel {
  static readonly VERSION: number = 1;
  static readonly MAX_OPTIONS_COUNT: number = 30;
  static readonly MAX_HISTORY_COUNT: number = 20;
  private static readonly MAX_TEXT_LENGTH: number = 120;

  static createState(
    activeTag: string,
    candidateName: string,
    candidateTagsText: string,
    selectedOptionId: number,
    resultText: string,
    helperText: string,
    resultTagText: string,
    hasPendingResult: boolean,
    rerollCount: number,
    showInputPanel: boolean,
    showHistoryPanel: boolean,
    showManagePanel: boolean,
    lunchOptions: LunchContinuationSourceOption[],
    historyItems: LunchContinuationSourceHistoryItem[]
  ): LunchContinuationState {
    const state: LunchContinuationState = {
      version: LunchContinuationStateModel.VERSION,
      pageId: LUNCH_CONTINUATION_PAGE_ID,
      activeTag: LunchContinuationStateModel.limitText(activeTag),
      candidateName: LunchContinuationStateModel.limitText(candidateName),
      candidateTagsText: LunchContinuationStateModel.limitText(candidateTagsText),
      selectedOptionId: selectedOptionId,
      resultText: LunchContinuationStateModel.limitText(resultText),
      helperText: LunchContinuationStateModel.limitText(helperText),
      resultTagText: LunchContinuationStateModel.limitText(resultTagText),
      hasPendingResult: hasPendingResult,
      rerollCount: Math.min(Math.max(rerollCount, 0), 3),
      showInputPanel: showInputPanel,
      showHistoryPanel: showHistoryPanel,
      showManagePanel: showManagePanel,
      lunchOptions: LunchContinuationStateModel.sanitizeOptions(lunchOptions),
      historyItems: LunchContinuationStateModel.sanitizeHistory(historyItems),
      updatedAt: Date.now()
    };
    return LunchContinuationStateModel.validate(state) ?? state;
  }

  static validate(rawState: Object | string | undefined | null): LunchContinuationState | undefined {
    const parsedState: Object | undefined = LunchContinuationStateModel.parseRawState(rawState);
    if (parsedState === undefined) {
      return undefined;
    }

    const source: Record<string, Object> = parsedState as Record<string, Object>;
    if (source.pageId !== LUNCH_CONTINUATION_PAGE_ID || source.version !== LunchContinuationStateModel.VERSION) {
      return undefined;
    }

    const rerollCount: number | undefined = LunchContinuationStateModel.getNumber(source.rerollCount);
    if (rerollCount === undefined || rerollCount < 0 || rerollCount > 3) {
      return undefined;
    }

    const lunchOptions: LunchContinuationOption[] | undefined =
      LunchContinuationStateModel.parseOptions(source.lunchOptions);
    if (lunchOptions === undefined || lunchOptions.length === 0) {
      return undefined;
    }

    const historyItems: LunchContinuationHistoryItem[] | undefined =
      LunchContinuationStateModel.parseHistory(source.historyItems);
    if (historyItems === undefined) {
      return undefined;
    }

    let selectedOptionId: number = LunchContinuationStateModel.getNumber(source.selectedOptionId) ?? -1;
    if (selectedOptionId >= 0 && !lunchOptions.some((option: LunchContinuationOption) => option.id === selectedOptionId)) {
      selectedOptionId = -1;
    }

    const state: LunchContinuationState = {
      version: LunchContinuationStateModel.VERSION,
      pageId: LUNCH_CONTINUATION_PAGE_ID,
      activeTag: LunchContinuationStateModel.getString(source.activeTag),
      candidateName: LunchContinuationStateModel.getString(source.candidateName),
      candidateTagsText: LunchContinuationStateModel.getString(source.candidateTagsText),
      selectedOptionId: selectedOptionId,
      resultText: LunchContinuationStateModel.getString(source.resultText),
      helperText: LunchContinuationStateModel.getString(source.helperText),
      resultTagText: LunchContinuationStateModel.getString(source.resultTagText),
      hasPendingResult: selectedOptionId >= 0 && LunchContinuationStateModel.getBoolean(source.hasPendingResult),
      rerollCount: rerollCount,
      showInputPanel: LunchContinuationStateModel.getBoolean(source.showInputPanel),
      showHistoryPanel: LunchContinuationStateModel.getBoolean(source.showHistoryPanel),
      showManagePanel: LunchContinuationStateModel.getBoolean(source.showManagePanel),
      lunchOptions: lunchOptions,
      historyItems: historyItems,
      updatedAt: LunchContinuationStateModel.getNumber(source.updatedAt) ?? Date.now()
    };

    if (state.selectedOptionId < 0) {
      state.hasPendingResult = false;
      state.rerollCount = 0;
      state.resultText = '';
      state.helperText = '';
      state.resultTagText = '';
    }
    return state;
  }

  private static parseRawState(rawState: Object | string | undefined | null): Object | undefined {
    if (rawState === undefined || rawState === null) {
      return undefined;
    }
    if (typeof rawState === 'string') {
      try {
        return JSON.parse(rawState) as Object;
      } catch (_error) {
        return undefined;
      }
    }
    return rawState;
  }

  private static sanitizeOptions(options: LunchContinuationSourceOption[]): LunchContinuationOption[] {
    return options
      .slice(0, LunchContinuationStateModel.MAX_OPTIONS_COUNT)
      .map((option: LunchContinuationSourceOption) => {
        const sanitizedOption: LunchContinuationOption = {
          id: option.id,
          name: LunchContinuationStateModel.limitText(option.name),
          tags: Array.isArray(option.tags) ? option.tags
            .filter((tag: string) => tag.length > 0)
            .map((tag: string) => LunchContinuationStateModel.limitText(tag))
            .slice(0, 8) : []
        };
        return sanitizedOption;
      })
      .filter((option: LunchContinuationOption) => option.name.length > 0);
  }

  private static sanitizeHistory(historyItems: LunchContinuationSourceHistoryItem[]): LunchContinuationHistoryItem[] {
    return historyItems
      .slice(0, LunchContinuationStateModel.MAX_HISTORY_COUNT)
      .map((item: LunchContinuationSourceHistoryItem) => {
        const historyItem: LunchContinuationHistoryItem = {
          id: item.id,
          name: LunchContinuationStateModel.limitText(item.name),
          pickedAt: LunchContinuationStateModel.limitText(item.pickedAt)
        };
        return historyItem;
      })
      .filter((item: LunchContinuationHistoryItem) => item.name.length > 0);
  }

  private static parseOptions(rawOptions: Object | undefined): LunchContinuationOption[] | undefined {
    if (!Array.isArray(rawOptions)) {
      return undefined;
    }
    const options: LunchContinuationOption[] = [];
    rawOptions.slice(0, LunchContinuationStateModel.MAX_OPTIONS_COUNT).forEach((rawOption: Object) => {
      const optionRecord: Record<string, Object> = rawOption as Record<string, Object>;
      const id: number | undefined = LunchContinuationStateModel.getNumber(optionRecord.id);
      const name: string = LunchContinuationStateModel.getString(optionRecord.name);
      if (id === undefined || name.length === 0 || !Array.isArray(optionRecord.tags)) {
        return;
      }
      const tags: string[] = (optionRecord.tags as string[])
        .filter((tag: string) => typeof tag === 'string' && tag.length > 0)
        .map((tag: string) => LunchContinuationStateModel.limitText(tag))
        .slice(0, 8);
      options.push({ id: id, name: name, tags: tags });
    });
    return options;
  }

  private static parseHistory(rawHistory: Object | undefined): LunchContinuationHistoryItem[] | undefined {
    if (!Array.isArray(rawHistory)) {
      return undefined;
    }
    const historyItems: LunchContinuationHistoryItem[] = [];
    rawHistory.slice(0, LunchContinuationStateModel.MAX_HISTORY_COUNT).forEach((rawItem: Object) => {
      const itemRecord: Record<string, Object> = rawItem as Record<string, Object>;
      const id: number | undefined = LunchContinuationStateModel.getNumber(itemRecord.id);
      const name: string = LunchContinuationStateModel.getString(itemRecord.name);
      if (id === undefined || name.length === 0) {
        return;
      }
      historyItems.push({
        id: id,
        name: name,
        pickedAt: LunchContinuationStateModel.getString(itemRecord.pickedAt)
      });
    });
    return historyItems;
  }

  private static getString(value: Object | undefined): string {
    if (typeof value !== 'string') {
      return '';
    }
    return LunchContinuationStateModel.limitText(value);
  }

  private static getNumber(value: Object | undefined): number | undefined {
    if (typeof value !== 'number' || Number.isNaN(value)) {
      return undefined;
    }
    return value;
  }

  private static getBoolean(value: Object | undefined): boolean {
    return typeof value === 'boolean' ? value : false;
  }

  private static limitText(value: string): string {
    return value.trim().slice(0, LunchContinuationStateModel.MAX_TEXT_LENGTH);
  }
}
