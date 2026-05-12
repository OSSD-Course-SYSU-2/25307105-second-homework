export interface LunchOption {
  id: number;
  name: string;
  tags: string[];
}

export default class LunchPickerViewModel {
  static readonly MAX_HISTORY_COUNT: number = 20;
  static readonly RECENT_BLOCK_COUNT: number = 2;
  static readonly RECENT_PENALTY_WINDOW: number = 5;
  static readonly EMPTY_NAME_MESSAGE: string = '请输入午餐名称';
  static readonly DUPLICATE_NAME_MESSAGE: string = '该午餐选项已存在';
  static readonly RESERVED_ONE_MESSAGE: string = '至少保留 1 个午餐选项';
  static readonly READY_MESSAGE: string = '可以添加新午餐，或点击“帮我决定”随机选择';
  static readonly PICK_PROMPT: string = '点击“帮我决定”开始随机选择';
  static readonly PICK_EMPTY_MESSAGE: string = '请先添加午餐选项';
  static readonly PICK_EMPTY_HELPER_MESSAGE: string = '候选列表为空，暂时无法随机选择';
  static readonly HISTORY_EMPTY_MESSAGE: string = '还没有历史记录，随机选择一次后会显示在这里';

  static createDefaultOptions(): LunchOption[] {
    return [
      { id: 1, name: '黄焖鸡', tags: ['米饭', '重口', '快餐'] },
      { id: 2, name: '兰州拉面', tags: ['面食', '汤类', '快餐'] },
      { id: 3, name: '牛肉饭', tags: ['米饭', '重口', '外卖'] },
      { id: 4, name: '轻食沙拉', tags: ['轻食', '清淡', '健康'] },
      { id: 5, name: '馄饨', tags: ['汤类', '清淡', '快餐'] }
    ];
  }

  static normalizeName(name: string): string {
    return name.trim();
  }

  static normalizeTags(rawTags: string): string[] {
    if (rawTags.trim().length === 0) {
      return [];
    }

    return rawTags
      .split(/[，,、\s]+/)
      .map((tag: string) => tag.trim())
      .filter((tag: string) => tag.length > 0)
      .filter((tag: string, index: number, tags: string[]) => tags.indexOf(tag) === index);
  }

  static getRecommendedTags(): string[] {
    return ['米饭', '面食', '汤类', '轻食', '重口', '清淡', '快餐', '外卖', '健康'];
  }

  static containsOption(options: LunchOption[], name: string): boolean {
    const normalizedName: string = LunchPickerViewModel.normalizeName(name).toLowerCase();
    return options.some((option: LunchOption) => option.name.toLowerCase() === normalizedName);
  }

  static createOption(optionId: number, name: string, tags: string[]): LunchOption {
    return {
      id: optionId,
      name: LunchPickerViewModel.normalizeName(name),
      tags: tags
    };
  }

  static getNextOptionId(options: LunchOption[]): number {
    if (options.length === 0) {
      return 1;
    }

    const maxId: number = options.reduce((currentMax: number, option: LunchOption) => {
      return option.id > currentMax ? option.id : currentMax;
    }, 0);
    return maxId + 1;
  }

  static upgradeOptions(options: LunchOption[]): LunchOption[] {
    return options.map((option: LunchOption) => {
      const upgradedOption: LunchOption = {
        id: option.id,
        name: option.name,
        tags: Array.isArray(option.tags) ? option.tags : []
      };
      return upgradedOption;
    });
  }

  static getFilteredOptions(options: LunchOption[], activeTag: string): LunchOption[] {
    if (activeTag.length === 0) {
      return options;
    }
    return options.filter((option: LunchOption) => option.tags.includes(activeTag));
  }

  static pickRandomOption(options: LunchOption[], historyNames: string[]): LunchOption | undefined {
    if (options.length === 0) {
      return undefined;
    }

    const recentBlockedNames: string[] = historyNames.slice(0, LunchPickerViewModel.RECENT_BLOCK_COUNT);
    const unblockedOptions: LunchOption[] = options.filter((option: LunchOption) => !recentBlockedNames.includes(option.name));
    const candidateOptions: LunchOption[] = unblockedOptions.length > 0 ? unblockedOptions : options;

    const recentWindowNames: string[] = historyNames.slice(0, LunchPickerViewModel.RECENT_PENALTY_WINDOW);
    const weightedOptions: LunchOption[] = [];
    candidateOptions.forEach((option: LunchOption) => {
      const recentCount: number = recentWindowNames.filter((historyName: string) => historyName === option.name).length;
      const weight: number = Math.max(1, 4 - recentCount);
      for (let index = 0; index < weight; index++) {
        weightedOptions.push(option);
      }
    });

    const randomIndex: number = Math.floor(Math.random() * weightedOptions.length);
    return weightedOptions[randomIndex];
  }

  static buildTagStats(options: LunchOption[]): Map<string, number> {
    const tagCounter: Map<string, number> = new Map<string, number>();
    options.forEach((option: LunchOption) => {
      option.tags.forEach((tag: string) => {
        const currentCount: number = tagCounter.get(tag) ?? 0;
        tagCounter.set(tag, currentCount + 1);
      });
    });
    return tagCounter;
  }

  static getMostFrequentLunch(historyNames: string[]): string {
    if (historyNames.length === 0) {
      return '暂无数据';
    }

    const counter: Map<string, number> = new Map<string, number>();
    historyNames.forEach((name: string) => {
      const currentCount: number = counter.get(name) ?? 0;
      counter.set(name, currentCount + 1);
    });

    let result: string = '暂无数据';
    let maxCount: number = 0;
    counter.forEach((count: number, name: string) => {
      if (count > maxCount) {
        maxCount = count;
        result = name;
      }
    });
    return result;
  }

  static getLongestUnchosenLunch(options: LunchOption[], historyNames: string[]): string {
    if (options.length === 0) {
      return '暂无数据';
    }

    if (historyNames.length === 0) {
      return options[0].name;
    }

    let farthestIndex: number = -1;
    let result: string = options[0].name;
    options.forEach((option: LunchOption) => {
      const index: number = historyNames.indexOf(option.name);
      if (index === -1) {
        result = option.name;
        farthestIndex = Number.MAX_SAFE_INTEGER;
        return;
      }
      if (index > farthestIndex) {
        farthestIndex = index;
        result = option.name;
      }
    });
    return result;
  }
}
