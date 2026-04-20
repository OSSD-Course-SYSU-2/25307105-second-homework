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

import { window } from '@kit.ArkUI';
import Logger from '../common/utils/Logger';
import DrawModel from '../viewmodel/DrawModel';
import PrizeDialog from '../view/PrizeDialog';
import PrizeData from '../viewmodel/PrizeData';
import StyleConstants from '../common/constants/StyleConstants';
import CommonConstants from '../common/constants/CommonConstants';
import { Context } from '@kit.AbilityKit';

// Get context.
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context: Context = uiContext!.getHostContext()!;

@Entry
@Component
struct CanvasPage {
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State drawModel: DrawModel = new DrawModel();
  @State screenWidth: number = 0;
  @State screenHeight: number = 0;
  @State rotateDegree: number = 0;
  @State enableFlag: boolean = true;
  @State prizeData: PrizeData = new PrizeData();
  @State isMoneyMode: boolean = true; // true: 钱多模式, false: 钱少模式
  dialogController: CustomDialogController = new CustomDialogController({
    builder: PrizeDialog({
      prizeData: $prizeData,
      enableFlag: $enableFlag
    }),
    autoCancel: false,
    alignment: DialogAlignment.Center,
    cancel: () => {
      this.enableFlag = !this.enableFlag;
    }
  });

  aboutToAppear() {
    // Obtains the width and height of the screen, excluding the height of the navigation view.
    window.getLastWindow(context)
      .then((windowClass: window.Window) => {
        windowClass.setWindowLayoutFullScreen(true);
        let windowProperties = windowClass.getWindowProperties();
        this.screenWidth = this.getUIContext().px2vp(windowProperties.windowRect.width);
        this.screenHeight = this.getUIContext().px2vp(windowProperties.windowRect.height);
      })
      .catch((error: Error) => {
        Logger.error('Failed to obtain the window size. Cause: ' + JSON.stringify(error));
      })
  }

  build() {
    Column() {
      // 模式切换按钮
      Row({ space: 20 }) {
        Button(this.getModeText())
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .backgroundColor(this.isMoneyMode ? '#FF6B35' : '#4CAF50')
          .fontColor(Color.White)
          .padding({ left: 20, right: 20, top: 10, bottom: 10 })
          .borderRadius(20)
          .onClick(() => {
            this.isMoneyMode = !this.isMoneyMode;
            // 切换模式后重新绘制转盘
            this.drawModel.setMode(this.isMoneyMode);
            this.drawModel.draw(this.canvasContext, this.screenWidth, this.screenHeight);
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .padding({ top: 20, bottom: 10 })

      Stack({ alignContent: Alignment.Center }) {
        Canvas(this.canvasContext)
          .width(StyleConstants.FULL_PERCENT)
          .height(StyleConstants.FULL_PERCENT)
          .onReady(() => {
            this.drawModel.draw(this.canvasContext, this.screenWidth, this.screenHeight);
          })
          .rotate({
            x: 0,
            y: 0,
            z: 1,
            angle: this.rotateDegree,
            centerX: this.screenWidth / CommonConstants.TWO,
            centerY: this.screenHeight / CommonConstants.TWO
          })

        Image($r('app.media.ic_center'))
          .width(StyleConstants.CENTER_IMAGE_WIDTH)
          .height(StyleConstants.CENTER_IMAGE_HEIGHT)
          .enabled(this.enableFlag)
          .onClick(() => {
            this.enableFlag = !this.enableFlag;
            this.startAnimator();
          })
      }
      .width(StyleConstants.FULL_PERCENT)
      .height(StyleConstants.FULL_PERCENT)
    }
    .width(StyleConstants.FULL_PERCENT)
    .height(StyleConstants.FULL_PERCENT)
    .backgroundImage($r('app.media.ic_background'), ImageRepeat.NoRepeat)
    .backgroundImageSize({
      width: StyleConstants.FULL_PERCENT,
      height: StyleConstants.BACKGROUND_IMAGE_SIZE
    })
  }

  /**
   * Get mode text for button.
   */
  getModeText(): string {
    const resource = this.isMoneyMode ? $r('app.string.text_mode_money_much') : $r('app.string.text_mode_money_little');
    return uiContext!.getHostContext()!.resourceManager.getStringSync(resource.id);
  }

  /**
   * Start animator.
   */
  startAnimator() {
    let randomAngle = Math.floor(Math.random() * CommonConstants.CIRCLE);
    // Obtaining prize information.
    this.prizeData = this.drawModel.showPrizeData(randomAngle);

    this.getUIContext().animateTo({
      duration: CommonConstants.DURATION,
      curve: Curve.Ease,
      delay: 0,
      iterations: 1,
      playMode: PlayMode.Normal,
      onFinish: () => {
        this.rotateDegree = CommonConstants.ANGLE - randomAngle;
        // Display prize information pop-up window.
        this.dialogController.open();
      }
    }, () => {
      this.rotateDegree = CommonConstants.CIRCLE * CommonConstants.FIVE +
      CommonConstants.ANGLE - randomAngle;
    })
  }
}