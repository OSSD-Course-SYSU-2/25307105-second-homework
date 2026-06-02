import { Context } from '@kit.AbilityKit';
import LunchStorage from '../common/utils/LunchStorage';
import LunchHistoryItem from '../viewmodel/LunchHistoryItem';
import LunchPickerViewModel, { LunchOption } from '../viewmodel/LunchPickerViewModel';

@Entry
@Component
struct LunchPickerPage {
  private static readonly MAX_REROLL_COUNT: number = 3;
  private nextOptionId: number = LunchPickerViewModel.getNextOptionId(LunchPickerViewModel.createDefaultOptions());

  @State candidateName: string = '';
  @State candidateTagsText: string = '';
  @State activeTag: string = '';
  @State resultText: string = LunchPickerViewModel.PICK_PROMPT;
  @State helperText: string = LunchPickerViewModel.READY_MESSAGE;
  @State resultTagText: string = '准备就绪';
  @State selectedOptionId: number = -1;
  @State hasPendingResult: boolean = false;
  @State rerollCount: number = 0;
  @State showInputPanel: boolean = false;
  @State showHistoryPanel: boolean = false;
  @State showManagePanel: boolean = false;
  @State historyItems: LunchHistoryItem[] = [];
  @State lunchOptions: LunchOption[] = LunchPickerViewModel.createDefaultOptions();
  @State windowWidth: number = 360;

  aboutToAppear(): void {
    const hostContext: Context | undefined = this.getUIContext().getHostContext();
    LunchStorage.initialize(hostContext);

    const storedOptions: LunchOption[] = LunchStorage.loadOptions();
    if (storedOptions.length > 0) {
      this.lunchOptions = storedOptions;
    }

    this.historyItems = LunchStorage.loadHistory();
    this.nextOptionId = LunchPickerViewModel.getNextOptionId(this.lunchOptions);
  }

  build() {
    Scroll() {
      Column({ space: this.getOuterSpace() }) {
        this.buildHeader()
        if (this.isTwoColumnLayout()) {
          Row({ space: 18 }) {
            Column({ space: 14 }) {
              this.buildResultCard()
              this.buildStatsStrip()
              this.buildFilterCard()
            }
            .layoutWeight(1)

            Column({ space: 14 }) {
              this.buildOptionListCard()
              this.buildToolsPanel()
            }
            .layoutWeight(1)
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        } else {
          this.buildResultCard()
          this.buildStatsStrip()
          this.buildFilterCard()
          this.buildOptionListCard()
          this.buildToolsPanel()
        }
      }
      .width(this.getContentWidth())
      .padding({
        left: this.getPagePadding(),
        right: this.getPagePadding(),
        top: this.isCompactLayout() ? 22 : 32,
        bottom: 30
      })
      .alignSelf(ItemAlign.Center)
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
    .backgroundColor('#F6EFE6')
    .onAreaChange((_oldValue, newValue) => {
      this.windowWidth = this.toNumber(newValue.width.toString());
    })
  }

  @Builder
  private buildHeader() {
    Row() {
      Column({ space: 8 }) {
        Text('Lunch Picker')
          .fontSize(14)
          .fontColor('#8C6A43')
          .fontWeight(FontWeight.Medium)

        Text('午餐选择器')
          .fontSize(this.isCompactLayout() ? 30 : 38)
          .fontWeight(FontWeight.Bold)
          .fontColor('#2D1F12')

        Text(this.isTwoColumnLayout() ? '一套工程适配手机、平板和 2in1：窄屏专注选择，宽屏同时管理候选和历史。' : '少纠结一会儿，多享受一顿饭。')
          .fontSize(14)
          .fontColor('#6F5A45')
          .lineHeight(22)
          .maxLines(2)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(this.getDeviceLabel())
        .fontSize(12)
        .fontColor('#8F4A24')
        .padding({ left: 12, right: 12, top: 7, bottom: 7 })
        .backgroundColor('#F9DFC7')
        .borderRadius(999)
    }
    .width('100%')
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private buildResultCard() {
    Column({ space: 14 }) {
      Row() {
        Text('今天吃什么？')
          .fontSize(16)
          .fontColor('#8C6A43')

        Text(this.resultTagText)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor('#8F4A24')
          .padding({ left: 10, right: 10, top: 5, bottom: 5 })
          .backgroundColor('#F9DFC7')
          .borderRadius(999)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Text(this.resultText)
        .fontSize(this.selectedOptionId >= 0 ? (this.isCompactLayout() ? 28 : 34) : 24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2D1F12')
        .textAlign(TextAlign.Center)

      Text(this.helperText)
        .fontSize(13)
        .fontColor('#7A6752')
        .textAlign(TextAlign.Center)
        .lineHeight(20)

      if (this.hasPendingResult) {
        Row({ space: 10 }) {
          Button('换一个')
            .layoutWeight(1)
            .height(52)
            .borderRadius(16)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor(this.canReroll() ? '#EEE4D9' : '#E2D6CB')
            .fontColor('#6F5A45')
            .enabled(this.canReroll())
            .opacity(this.canReroll() ? 1 : 0.55)
            .onClick(() => {
              this.pickLunch();
            })

          Button('就吃这个')
            .layoutWeight(1)
            .height(52)
            .borderRadius(16)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .backgroundColor('#D96C3A')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.confirmLunch();
            })
        }
        .width('100%')
      } else {
        Button(this.selectedOptionId >= 0 ? '重新推荐' : '帮我决定')
          .width('100%')
          .height(52)
          .borderRadius(16)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.getSelectableOptions().length > 0 ? '#D96C3A' : '#D3B8A7')
          .fontColor('#FFFFFF')
          .enabled(this.getSelectableOptions().length > 0)
          .onClick(() => {
            this.pickLunch();
          })
      }
    }
    .width('100%')
    .padding(this.getCardPadding())
    .borderRadius(16)
    .backgroundColor('#FFF9F2')
    .shadow({
      radius: 18,
      color: '#1F000000',
      offsetX: 0,
      offsetY: 8
    })
  }

  @Builder
  private buildStatsStrip() {
    Row({ space: 8 }) {
      this.buildMetricItem('次数', `${this.historyItems.length}`)
      this.buildMetricItem('常吃', this.getMostFrequentLunch())
      this.buildMetricItem('很久没吃', this.getLongestUnchosenLunch())
    }
    .width('100%')
  }

  @Builder
  private buildMetricItem(title: string, value: string) {
    Column({ space: 6 }) {
      Text(title)
        .fontSize(12)
        .fontColor('#8C7A66')

      Text(value)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2D1F12')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ left: 10, right: 10, top: 10, bottom: 10 })
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildToolsPanel() {
    Column({ space: 10 }) {
      this.buildToolToggle('添加午餐', this.showInputPanel, 'input')
      if (this.showInputPanel) {
        this.buildInputCard()
      }

      this.buildToolToggle(`最近结果 ${this.historyItems.length}`, this.showHistoryPanel, 'history')
      if (this.showHistoryPanel) {
        this.buildHistoryCard()
      }

      this.buildToolToggle('管理', this.showManagePanel, 'manage')
      if (this.showManagePanel) {
        this.buildManageCard()
      }
    }
    .width('100%')
  }

  @Builder
  private buildToolToggle(label: string, isOpen: boolean, panel: string) {
    Row() {
      Text(label)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2D1F12')

      Text(isOpen ? '收起' : '展开')
        .fontSize(12)
        .fontColor('#8C6A43')
    }
    .width('100%')
    .height(44)
    .padding({ left: 16, right: 16 })
    .borderRadius(14)
    .backgroundColor('#FFF9F2')
    .justifyContent(FlexAlign.SpaceBetween)
    .onClick(() => {
      this.toggleToolPanel(panel);
    })
  }

  @Builder
  private buildFilterCard() {
    Column({ space: 12 }) {
      Row() {
        Text('标签筛选')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2D1F12')

        Text(this.activeTag.length > 0 ? `当前：${this.activeTag}` : '当前：全部')
          .fontSize(12)
          .fontColor('#8C6A43')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        this.buildFilterChip('全部', this.activeTag.length === 0)

        ForEach(this.getAvailableTags(), (tag: string) => {
          this.buildFilterChip(tag, this.activeTag === tag)
        }, (tag: string) => tag)
      }
      .width('100%')

      Text(this.getFilterHintText())
        .fontSize(12)
        .fontColor('#7A6752')
    }
    .width('100%')
    .padding(this.getCardPadding())
    .borderRadius(16)
    .backgroundColor('#FFF9F2')
  }

  @Builder
  private buildFilterChip(label: string, isActive: boolean) {
    Text(label)
      .fontSize(12)
      .fontColor(isActive ? '#FFFFFF' : '#7A5E43')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(isActive ? '#D96C3A' : '#EFE3D6')
      .borderRadius(999)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.activeTag = label === '全部' ? '' : label;
      })
  }

  @Builder
  private buildInputCard() {
    Column({ space: 12 }) {
      Text('添加午餐选项')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2D1F12')

      TextInput({ placeholder: '例如：土豆牛肉饭', text: this.candidateName })
        .width('100%')
        .height(48)
        .backgroundColor(this.getNormalizedCandidateName().length > 0 ? '#FFF3E8' : '#FFFFFF')
        .borderRadius(14)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.candidateName = value;
        })

      TextInput({ placeholder: '标签：米饭 重口 外卖', text: this.candidateTagsText })
        .width('100%')
        .height(48)
        .backgroundColor(this.candidateTagsText.trim().length > 0 ? '#FFF3E8' : '#FFFFFF')
        .borderRadius(14)
        .padding({ left: 14, right: 14 })
        .onChange((value: string) => {
          this.candidateTagsText = value;
        })

      Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
        ForEach(LunchPickerViewModel.getRecommendedTags(), (tag: string) => {
          this.buildQuickTagChip(tag)
        }, (tag: string) => tag)
      }
      .width('100%')

      Button('添加')
        .width('100%')
        .height(48)
        .borderRadius(14)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .backgroundColor(this.canAddCandidate() ? '#2F7D4A' : '#A9C8B4')
        .fontColor('#FFFFFF')
        .enabled(this.canAddCandidate())
        .onClick(() => {
          this.addLunchOption();
        })

      Text(this.getInputHintText())
        .fontSize(12)
        .fontColor('#7A6752')
        .lineHeight(18)
    }
    .width('100%')
    .padding(this.getCardPadding())
    .borderRadius(16)
    .backgroundColor('#FFF9F2')
  }

  @Builder
  private buildQuickTagChip(tag: string) {
    Text(tag)
      .fontSize(12)
      .fontColor(this.getNormalizedCandidateTags().includes(tag) ? '#FFFFFF' : '#7A5E43')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.getNormalizedCandidateTags().includes(tag) ? '#2F7D4A' : '#EFE3D6')
      .borderRadius(999)
      .margin({ right: 8, bottom: 8 })
      .onClick(() => {
        this.toggleCandidateTag(tag);
      })
  }

  @Builder
  private buildOptionListCard() {
    Column({ space: 12 }) {
      Row() {
        Text(`候选列表 (${this.getSelectableOptions().length}/${this.lunchOptions.length})`)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2D1F12')

        Text(this.selectedOptionId >= 0 ? (this.hasPendingResult ? '待确认推荐' : '已确认结果') : '等待随机选择')
          .fontSize(12)
          .fontColor('#8C6A43')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      ForEach(this.getSelectableOptions(), (option: LunchOption) => {
        Row({ space: 12 }) {
          Column({ space: 8 }) {
            Text(option.name)
              .fontSize(16)
              .fontWeight(this.selectedOptionId === option.id ? FontWeight.Bold : FontWeight.Regular)
              .fontColor('#2D1F12')

            Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Start }) {
              ForEach(option.tags, (tag: string) => {
                Text(tag)
                  .fontSize(11)
                  .fontColor(this.selectedOptionId === option.id ? '#A64F1D' : '#7A5E43')
                  .padding({ left: 8, right: 8, top: 4, bottom: 4 })
                  .backgroundColor(this.selectedOptionId === option.id ? '#FADFCB' : '#F3E9DF')
                  .borderRadius(999)
                  .margin({ right: 6, bottom: 4 })
              }, (tag: string) => `${option.id}_${tag}`)
            }
            .width('100%')
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Start)

          Button('删除')
            .type(ButtonType.Normal)
            .backgroundColor(this.selectedOptionId === option.id ? '#F3C9B3' : '#F8DED2')
            .fontColor('#B6481B')
            .fontSize(13)
            .height(32)
            .borderRadius(10)
            .onClick(() => {
              this.removeLunchOption(option.id);
            })
        }
        .width('100%')
        .padding({ left: 16, right: 10, top: 14, bottom: 14 })
        .borderRadius(16)
        .backgroundColor(this.selectedOptionId === option.id ? '#FFF1E5' : '#FFFFFF')
        .border({
          width: this.selectedOptionId === option.id ? 1 : 0,
          color: '#F0B48B'
        })
      }, (option: LunchOption) => option.id.toString())
    }
    .width('100%')
    .padding(this.getCardPadding())
    .borderRadius(16)
    .backgroundColor('#FFF9F2')
  }

  @Builder
  private buildHistoryCard() {
    Column({ space: 12 }) {
      Row() {
        Text('最近结果')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2D1F12')

        Button('清空历史')
          .type(ButtonType.Normal)
          .backgroundColor('#EEE4D9')
          .fontColor('#6F5A45')
          .fontSize(12)
          .height(30)
          .borderRadius(10)
          .enabled(this.historyItems.length > 0)
          .opacity(this.historyItems.length > 0 ? 1 : 0.5)
          .onClick(() => {
            this.clearHistory();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      if (this.historyItems.length === 0) {
        Text(LunchPickerViewModel.HISTORY_EMPTY_MESSAGE)
          .fontSize(13)
          .fontColor('#8C7A66')
          .lineHeight(20)
      } else {
        ForEach(this.historyItems, (item: LunchHistoryItem) => {
          Row() {
            Column({ space: 4 }) {
              Text(item.name)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor('#2D1F12')

              Text(item.pickedAt)
                .fontSize(12)
                .fontColor('#8C7A66')
            }
            .alignItems(HorizontalAlign.Start)

            Text('历史记录')
              .fontSize(11)
              .fontColor('#A06E49')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F6E6D8')
              .borderRadius(999)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding({ left: 14, right: 14, top: 12, bottom: 12 })
          .borderRadius(14)
          .backgroundColor('#FFFFFF')
        }, (item: LunchHistoryItem) => item.id.toString())
      }
    }
    .width('100%')
    .padding(this.getCardPadding())
    .borderRadius(16)
    .backgroundColor('#FFF9F2')
  }

  @Builder
  private buildManageCard() {
    Column({ space: 12 }) {
      Text('管理')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#2D1F12')

      if (this.isCompactLayout()) {
        Column({ space: 10 }) {
          this.buildManageButton('恢复默认候选项', 'restore')
          this.buildManageButton('清空当前结果', 'reset')
        }
        .width('100%')
      } else {
        Row({ space: 12 }) {
          this.buildManageButton('恢复默认候选项', 'restore')
          this.buildManageButton('清空当前结果', 'reset')
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding(this.getCardPadding())
    .borderRadius(16)
    .backgroundColor('#FFF9F2')
  }

  @Builder
  private buildManageButton(label: string, action: string) {
    Button(label)
      .layoutWeight(1)
      .height(44)
      .borderRadius(14)
      .backgroundColor(action === 'restore' ? '#EEE4D9' : '#F8DED2')
      .fontColor(action === 'restore' ? '#6F5A45' : '#B6481B')
      .fontSize(14)
      .onClick(() => {
        if (action === 'restore') {
          this.resetOptions();
          return;
        }
        this.resetResult();
      })
  }

  private getAvailableTags(): string[] {
    const tagCounter: Map<string, number> = LunchPickerViewModel.buildTagStats(this.lunchOptions);
    const tags: string[] = [];
    tagCounter.forEach((_count: number, tag: string) => {
      tags.push(tag);
    });
    return tags.sort();
  }

  private getSelectableOptions(): LunchOption[] {
    return LunchPickerViewModel.getFilteredOptions(this.lunchOptions, this.activeTag);
  }

  private getHistoryNames(): string[] {
    return this.historyItems.map((item: LunchHistoryItem) => item.name);
  }

  private getMostFrequentLunch(): string {
    return LunchPickerViewModel.getMostFrequentLunch(this.getHistoryNames());
  }

  private getLongestUnchosenLunch(): string {
    return LunchPickerViewModel.getLongestUnchosenLunch(this.lunchOptions, this.getHistoryNames());
  }

  private getFilterHintText(): string {
    if (this.activeTag.length === 0) {
      return `当前展示全部 ${this.lunchOptions.length} 个候选项`;
    }
    return `标签“${this.activeTag}”下共有 ${this.getSelectableOptions().length} 个候选项`;
  }

  private canAddCandidate(): boolean {
    const normalizedName: string = this.getNormalizedCandidateName();
    return normalizedName.length > 0 && !LunchPickerViewModel.containsOption(this.lunchOptions, normalizedName);
  }

  private getNormalizedCandidateName(): string {
    return LunchPickerViewModel.normalizeName(this.candidateName);
  }

  private getNormalizedCandidateTags(): string[] {
    return LunchPickerViewModel.normalizeTags(this.candidateTagsText);
  }

  private toggleToolPanel(panel: string) {
    if (panel === 'input') {
      this.showInputPanel = !this.showInputPanel;
      return;
    }
    if (panel === 'history') {
      this.showHistoryPanel = !this.showHistoryPanel;
      return;
    }
    this.showManagePanel = !this.showManagePanel;
  }

  private toggleCandidateTag(tag: string) {
    const currentTags: string[] = this.getNormalizedCandidateTags();
    const nextTags: string[] = currentTags.includes(tag)
      ? currentTags.filter((currentTag: string) => currentTag !== tag)
      : [...currentTags, tag];
    this.candidateTagsText = nextTags.join(' ');
  }

  private getInputHintText(): string {
    const normalizedName: string = this.getNormalizedCandidateName();
    const tags: string[] = this.getNormalizedCandidateTags();
    if (normalizedName.length === 0) {
      return '输入午餐名称，可选补充多个标签，例如：米饭 重口 外卖';
    }

    if (LunchPickerViewModel.containsOption(this.lunchOptions, normalizedName)) {
      return '这个名称已经在候选列表中';
    }

    if (tags.length === 0) {
      return `准备添加“${normalizedName}”，暂时没有标签`;
    }

    return `准备添加“${normalizedName}”，标签：${tags.join(' / ')}`;
  }

  private addLunchOption() {
    const normalizedName: string = this.getNormalizedCandidateName();
    if (normalizedName.length === 0) {
      this.helperText = LunchPickerViewModel.EMPTY_NAME_MESSAGE;
      this.resultTagText = '输入为空';
      return;
    }

    if (LunchPickerViewModel.containsOption(this.lunchOptions, normalizedName)) {
      this.helperText = LunchPickerViewModel.DUPLICATE_NAME_MESSAGE;
      this.resultTagText = '重复项';
      return;
    }

    const tags: string[] = this.getNormalizedCandidateTags();
    this.lunchOptions = [
      ...this.lunchOptions,
      LunchPickerViewModel.createOption(this.nextOptionId, normalizedName, tags)
    ];
    this.nextOptionId += 1;
    this.candidateName = '';
    this.candidateTagsText = '';
    this.helperText = `已添加“${normalizedName}”，当前共 ${this.lunchOptions.length} 项`;
    this.resultTagText = tags.length > 0 ? `标签 ${tags.length}` : '列表已更新';
    LunchStorage.saveOptions(this.lunchOptions);
  }

  private removeLunchOption(optionId: number) {
    if (this.lunchOptions.length <= 1) {
      this.helperText = LunchPickerViewModel.RESERVED_ONE_MESSAGE;
      this.resultTagText = '无法删除';
      return;
    }

    this.lunchOptions = this.lunchOptions.filter((option: LunchOption) => option.id !== optionId);
    this.helperText = `已更新候选列表，当前共 ${this.lunchOptions.length} 项`;
    this.resultTagText = '列表已更新';
    LunchStorage.saveOptions(this.lunchOptions);

    if (this.selectedOptionId === optionId) {
      this.resetResult();
      this.helperText = '已删除当前展示结果，请重新随机选择';
      this.resultTagText = '结果已重置';
    }
  }

  private pickLunch() {
    const selectableOptions: LunchOption[] = this.getSelectableOptions();
    const selectedOption: LunchOption | undefined = LunchPickerViewModel.pickRandomOption(selectableOptions, this.getHistoryNames());
    if (selectedOption === undefined) {
      this.selectedOptionId = -1;
      this.hasPendingResult = false;
      this.resultText = LunchPickerViewModel.PICK_EMPTY_MESSAGE;
      this.helperText = this.activeTag.length > 0 ? '当前筛选条件下没有可选项' : LunchPickerViewModel.PICK_EMPTY_HELPER_MESSAGE;
      this.resultTagText = '无法选择';
      return;
    }

    this.selectedOptionId = selectedOption.id;
    this.resultText = selectedOption.name;
    const nextRerollCount: number = this.hasPendingResult ? this.rerollCount + 1 : 0;
    this.hasPendingResult = true;
    this.rerollCount = nextRerollCount;
    this.resultTagText = selectedOption.tags.length > 0 ? selectedOption.tags[0] : '待确认';
    if (this.rerollCount >= LunchPickerPage.MAX_REROLL_COUNT) {
      this.hasPendingResult = false;
      this.rerollCount = 0;
      this.helperText = `已经换了 ${LunchPickerPage.MAX_REROLL_COUNT} 次，已帮你确定“${selectedOption.name}”`;
      this.resultTagText = '已确认';
      this.appendHistory(selectedOption.name);
      return;
    }

    this.helperText = this.getPendingResultHelperText(selectableOptions.length);
  }

  private confirmLunch() {
    const selectedOption: LunchOption | undefined = this.lunchOptions.find((option: LunchOption) => {
      return option.id === this.selectedOptionId;
    });
    if (selectedOption === undefined) {
      this.resetResult();
      this.helperText = '当前推荐已不在候选列表中，请重新随机选择';
      this.resultTagText = '结果已重置';
      return;
    }

    this.hasPendingResult = false;
    this.rerollCount = 0;
    this.resultText = selectedOption.name;
    this.helperText = `已确认“${selectedOption.name}”，结果已写入历史记录`;
    this.resultTagText = '已确认';
    this.appendHistory(selectedOption.name);
  }

  private appendHistory(lunchName: string) {
    const historyItem: LunchHistoryItem = {
      id: Date.now(),
      name: lunchName,
      pickedAt: this.formatNow()
    };

    this.historyItems = [historyItem, ...this.historyItems].slice(0, LunchPickerViewModel.MAX_HISTORY_COUNT);
    LunchStorage.saveHistory(this.historyItems);
  }

  private clearHistory() {
    this.historyItems = [];
    LunchStorage.clearHistory();
    this.helperText = '历史记录已清空';
    this.resultTagText = '历史已清空';
  }

  private resetOptions() {
    this.lunchOptions = LunchPickerViewModel.createDefaultOptions();
    this.nextOptionId = LunchPickerViewModel.getNextOptionId(this.lunchOptions);
    LunchStorage.saveOptions(this.lunchOptions);
    this.resetResult();
    this.helperText = '已恢复默认候选项';
    this.resultTagText = '已恢复默认';
  }

  private resetResult() {
    this.selectedOptionId = -1;
    this.hasPendingResult = false;
    this.rerollCount = 0;
    this.resultText = LunchPickerViewModel.PICK_PROMPT;
    this.helperText = LunchPickerViewModel.READY_MESSAGE;
    this.resultTagText = '准备就绪';
  }

  private canReroll(): boolean {
    return this.rerollCount < LunchPickerPage.MAX_REROLL_COUNT;
  }

  private getPendingResultHelperText(selectableCount: number): string {
    if (!this.canReroll()) {
      return `已经换了 ${LunchPickerPage.MAX_REROLL_COUNT} 次，就吃这个吧，别纠结了`;
    }
    return `已在 ${selectableCount} 个筛选结果中生成推荐；还可以换 ${LunchPickerPage.MAX_REROLL_COUNT - this.rerollCount} 次`;
  }

  private formatNow(): string {
    const now: Date = new Date();
    const month: string = `${now.getMonth() + 1}`.padStart(2, '0');
    const day: string = `${now.getDate()}`.padStart(2, '0');
    const hour: string = `${now.getHours()}`.padStart(2, '0');
    const minute: string = `${now.getMinutes()}`.padStart(2, '0');
    return `${month}-${day} ${hour}:${minute}`;
  }

  private isCompactLayout(): boolean {
    return this.windowWidth < 600;
  }

  private isTwoColumnLayout(): boolean {
    return this.windowWidth >= 720;
  }

  private getDeviceLabel(): string {
    if (this.windowWidth >= 960) {
      return '2in1 / 桌面';
    }
    if (this.windowWidth >= 720) {
      return '平板双栏';
    }
    return '手机单栏';
  }

  private getContentWidth(): string {
    if (this.windowWidth >= 1080) {
      return '1040vp';
    }
    return '100%';
  }

  private getPagePadding(): number {
    if (this.windowWidth >= 720) {
      return 28;
    }
    return 18;
  }

  private getCardPadding(): number {
    if (this.windowWidth >= 720) {
      return 22;
    }
    return 20;
  }

  private getOuterSpace(): number {
    if (this.windowWidth >= 720) {
      return 18;
    }
    return 14;
  }

  private toNumber(value: string): number {
    const parsedValue: number = Number.parseFloat(value);
    if (Number.isNaN(parsedValue)) {
      return 360;
    }
    return parsedValue;
  }
}
