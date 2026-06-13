/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */


import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import LunchContinuationStateModel, {
  LUNCH_CONTINUATION_RESTORE_PENDING_KEY,
  LUNCH_CONTINUATION_STATE_KEY,
  LunchContinuationState
} from '../viewmodel/LunchContinuationState';

export default class EntryAbility extends UIAbility {
  private pendingContinuationState?: LunchContinuationState;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
    this.restoreContinuationState(want);
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/LunchPickerPage', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      this.syncPendingContinuationState();
    });
  }

  onWindowStageDestroy() {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam) {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
    this.restoreContinuationState(want);
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    const currentState: LunchContinuationState | undefined =
      LunchContinuationStateModel.validate(AppStorage.get(LUNCH_CONTINUATION_STATE_KEY) as Object | undefined);
    if (currentState === undefined) {
      return AbilityConstant.OnContinueResult.REJECT;
    }

    // Keep continuation payload compact and validated before handing it to the system.
    wantParam[LUNCH_CONTINUATION_STATE_KEY] = currentState as Object;
    return AbilityConstant.OnContinueResult.AGREE;
  }

  private restoreContinuationState(want: Want) {
    const rawState: Object | undefined = want.parameters?.[LUNCH_CONTINUATION_STATE_KEY];
    const continuationState: LunchContinuationState | undefined = LunchContinuationStateModel.validate(rawState);
    if (continuationState === undefined) {
      return;
    }
    this.pendingContinuationState = continuationState;
    this.syncPendingContinuationState();
  }

  private syncPendingContinuationState() {
    if (this.pendingContinuationState === undefined) {
      return;
    }
    AppStorage.setOrCreate(LUNCH_CONTINUATION_RESTORE_PENDING_KEY, true);
    AppStorage.setOrCreate(LUNCH_CONTINUATION_STATE_KEY, this.pendingContinuationState);
  }
}
