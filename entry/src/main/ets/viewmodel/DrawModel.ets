/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import CommonConstants from '../common/constants/CommonConstants';
import { EnumeratedValue } from '../common/constants/CommonConstants';
import ColorConstants from '../common/constants/ColorConstants';
import StyleConstants from '../common/constants/StyleConstants';
import PrizeData from './PrizeData';
import FillArcData from './FillArcData';
import Logger from '../common/utils/Logger';
import CheckEmptyUtils from '../common/utils/CheckEmptyUtils';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');

/**
 * Canvas drawing method class.
 */
export default class DrawModel {
  private startAngle: number = 0;
  private avgAngle: number = CommonConstants.CIRCLE / CommonConstants.COUNT;
  private screenWidth: number = 0;
  private canvasContext?: CanvasRenderingContext2D;
  private isMoneyMode: boolean = true; // true: 钱多模式, false: 钱少模式

  /**
   * Draw the raffle round turntable.
   *
   * @param canvasContext canvasContext.
   * @param screenWidth screenWidth.
   * @param screenHeight screenHeight.
   */
  draw(canvasContext: CanvasRenderingContext2D, screenWidth: number, screenHeight: number) {
    if (CheckEmptyUtils.isEmptyObj(canvasContext)) {
      Logger.error('[DrawModel][draw] canvasContext is empty.');
      return;
    }
    this.canvasContext = canvasContext;
    this.screenWidth = screenWidth;
    // Reset start angle to 0 degrees (right position)
    this.startAngle = 0;
    this.canvasContext.clearRect(0, 0, this.screenWidth, screenHeight);
    // Translates the canvas along the X and Y axes by a specified distance.
    this.canvasContext.translate(this.screenWidth / CommonConstants.TWO,
      screenHeight / CommonConstants.TWO);
    // Painted outer disc petal.
    this.drawFlower();
    // Draw outer disc, small circle.
    this.drawOutCircle();
    // Draw the inner disc.
    this.drawInnerCircle();
    // Draw the interior fan-shaped raffle area.
    this.drawInnerArc();
    // Reset start angle for text drawing
    this.startAngle = 0;
    // Draw text in the internal fan area.
    this.drawArcText();
    // Reset start angle for image drawing
    this.startAngle = 0;
    // Draw the picture corresponding to the prize in the internal fan area.
    this.drawImage();
    this.canvasContext.translate(-this.screenWidth / CommonConstants.TWO,
      -screenHeight / CommonConstants.TWO);
  }

  /**
   * Set mode for draw model.
   *
   * @param isMoneyMode true: money much mode, false: money little mode.
   */
  setMode(isMoneyMode: boolean) {
    this.isMoneyMode = isMoneyMode;
  }

  /**
   * Method of drawing arcs.
   *
   * @param fillArcData fillArcData.
   * @param fillColor fillColor.
   */
  fillArc(fillArcData: FillArcData, fillColor: string) {
    if (CheckEmptyUtils.isEmptyObj(fillArcData) || CheckEmptyUtils.isEmptyStr(fillColor)) {
      Logger.error('[DrawModel][fillArc] fillArcData or fillColor is empty.');
      return;
    }
    if (this.canvasContext !== undefined) {
      this.canvasContext.beginPath();
      this.canvasContext.fillStyle = fillColor;
      this.canvasContext.arc(fillArcData.x, fillArcData.y, fillArcData.radius,
        fillArcData.startAngle, fillArcData.endAngle);
      this.canvasContext.fill();
    }
  }

  /**
   * Painted outer disc petal.
   */
  drawFlower() {
    let beginAngle = this.startAngle + this.avgAngle;
    const pointY = this.screenWidth * CommonConstants.FLOWER_POINT_Y_RATIOS;
    const radius = this.screenWidth * CommonConstants.FLOWER_RADIUS_RATIOS;
    const innerRadius = this.screenWidth * CommonConstants.FLOWER_INNER_RATIOS;
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      this.canvasContext?.save();
      this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE);
      this.fillArc(new FillArcData(0, -pointY, radius, 0, Math.PI * CommonConstants.TWO),
        ColorConstants.FLOWER_OUT_COLOR);

      this.fillArc(new FillArcData(0, -pointY, innerRadius, 0, Math.PI * CommonConstants.TWO),
        ColorConstants.FLOWER_INNER_COLOR);
      beginAngle += this.avgAngle;
      this.canvasContext?.restore();
    }
  }

  /**
   * Draw outer disc, small circle.
   */
  drawOutCircle() {
    // Draw outer disc.
    this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.OUT_CIRCLE_RATIOS, 0,
      Math.PI * CommonConstants.TWO), ColorConstants.OUT_CIRCLE_COLOR);

    let beginAngle = this.startAngle;
    // Draw small circle.
    for (let i = 0; i < CommonConstants.SMALL_CIRCLE_COUNT; i++) {
      this.canvasContext?.save();
      this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE);
      this.fillArc(new FillArcData(this.screenWidth * CommonConstants.SMALL_CIRCLE_RATIOS, 0,
        CommonConstants.SMALL_CIRCLE_RADIUS, 0, Math.PI * CommonConstants.TWO),
        ColorConstants.WHITE_COLOR);
      beginAngle = beginAngle + CommonConstants.CIRCLE / CommonConstants.SMALL_CIRCLE_COUNT;
      this.canvasContext?.restore();
    }
  }

  /**
   * Draw the inner disc.
   */
  drawInnerCircle() {
    this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.INNER_CIRCLE_RATIOS, 0,
      Math.PI * CommonConstants.TWO), ColorConstants.INNER_CIRCLE_COLOR);
    this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.INNER_WHITE_CIRCLE_RATIOS, 0,
      Math.PI * CommonConstants.TWO), ColorConstants.WHITE_COLOR);
  }

  /**
   * Draw the interior fan-shaped raffle area.
   */
  drawInnerArc() {
    let colors = [
      ColorConstants.ARC_PINK_COLOR, ColorConstants.ARC_YELLOW_COLOR,
      ColorConstants.ARC_GREEN_COLOR, ColorConstants.ARC_PINK_COLOR,
      ColorConstants.ARC_YELLOW_COLOR, ColorConstants.ARC_GREEN_COLOR
    ];
    let radius = this.screenWidth * CommonConstants.INNER_ARC_RATIOS;
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      this.fillArc(new FillArcData(0, 0, radius, this.startAngle * Math.PI / CommonConstants.HALF_CIRCLE,
        (this.startAngle + this.avgAngle) * Math.PI / CommonConstants.HALF_CIRCLE), colors[i]);
      this.canvasContext?.lineTo(0, 0);
      this.canvasContext?.fill();
      this.startAngle += this.avgAngle;
    }
  }

  /**
   * Draw text in the internal fan area.
   */
  drawArcText() {
    if (this.canvasContext !== undefined) {
      this.canvasContext.textAlign = CommonConstants.TEXT_ALIGN;
      this.canvasContext.textBaseline = CommonConstants.TEXT_BASE_LINE;
      this.canvasContext.fillStyle = ColorConstants.TEXT_COLOR;
      this.canvasContext.font = StyleConstants.ARC_TEXT_SIZE + CommonConstants.CANVAS_FONT;
    }
    let textArrays: Resource[];
    if (this.isMoneyMode) {
      // 钱多模式：中餐、西餐、日料、快餐、素食、面食
      textArrays = [
        $r('app.string.text_chinese'),
        $r('app.string.text_western'),
        $r('app.string.text_japanese'),
        $r('app.string.text_fast'),
        $r('app.string.text_vegetarian'),
        $r('app.string.text_noodles')
      ];
    } else {
      // 钱少模式：方便面、面包、馒头、米饭、粥、饼干
      textArrays = [
        $r('app.string.text_instant_noodles'),
        $r('app.string.text_bread'),
        $r('app.string.text_steamed_bun'),
        $r('app.string.text_rice'),
        $r('app.string.text_porridge'),
        $r('app.string.text_biscuit')
      ];
    }
    let arcTextStartAngle = CommonConstants.ARC_START_ANGLE;
    let arcTextEndAngle = CommonConstants.ARC_END_ANGLE;
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      this.drawCircularText(this.getResourceString(textArrays[i]),
        (this.startAngle + arcTextStartAngle) * Math.PI / CommonConstants.HALF_CIRCLE,
        (this.startAngle + arcTextEndAngle) * Math.PI / CommonConstants.HALF_CIRCLE);
      this.startAngle += this.avgAngle;
    }
  }

  /**
   * Obtains the character string corresponding to the specified resource ID.
   *
   * @param resource resource.
   */
  getResourceString(resource: Resource): string {
    if (CheckEmptyUtils.isEmptyObj(resource)) {
      Logger.error('[DrawModel][getResourceString] resource is empty.')
      return '';
    }
    let resourceString: string = '';
    try {
      resourceString = uiContext!.getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      Logger.error(`[DrawModel][getResourceString]getStringSync failed, error : ${JSON.stringify(error)}.`);
    }
    return resourceString;
  }

  /**
   * Draw Arc Text.
   *
   * @param textString textString.
   * @param startAngle startAngle.
   * @param endAngle endAngle.
   */
  drawCircularText(textString: string, startAngle: number, endAngle: number) {
    if (CheckEmptyUtils.isEmptyStr(textString)) {
      Logger.error('[DrawModel][drawCircularText] textString is empty.')
      return;
    }

    class CircleText {
      x: number = 0;
      y: number = 0;
      radius: number = 0;
    }

    let circleText: CircleText = {
      x: 0,
      y: 0,
      radius: this.screenWidth * CommonConstants.INNER_ARC_RATIOS
    };
    // The radius of the circle.
    let radius = circleText.radius - circleText.radius / CommonConstants.COUNT;
    // The radians occupied by each letter.
    let angleDecrement = (startAngle - endAngle) / (textString.length - 1);
    let angle = startAngle;
    let index = 0;
    let character: string;

    while (index < textString.length) {
      character = textString.charAt(index);
      this.canvasContext?.save();
      this.canvasContext?.beginPath();
      this.canvasContext?.translate(circleText.x + Math.cos(angle) * radius,
        circleText.y - Math.sin(angle) * radius);
      this.canvasContext?.rotate(Math.PI / CommonConstants.TWO - angle);
      this.canvasContext?.fillText(character, 0, 0);
      angle -= angleDecrement;
      index++;
      this.canvasContext?.restore();
    }
  }

  /**
   * Draw the picture corresponding to the prize in the internal fan area.
   */
  drawImage() {
    let beginAngle = this.startAngle;
    let imageSrc: string[];
    if (this.isMoneyMode) {
      // 钱多模式图片
      imageSrc = [
        CommonConstants.CHINESE_IMAGE_URL, CommonConstants.WESTERN_IMAGE_URL,
        CommonConstants.JAPANESE_IMAGE_URL, CommonConstants.FAST_IMAGE_URL,
        CommonConstants.VEGETARIAN_IMAGE_URL, CommonConstants.NOODLES_IMAGE_URL
      ];
    } else {
      // 钱少模式图片 - 使用现有图片资源
      imageSrc = [
        'resources/base/media/ic_cake.png',      // 方便面
        'resources/base/media/ic_hamburg.png',   // 面包
        'resources/base/media/ic_smile.png',     // 馒头
        'resources/base/media/ic_watermelon.png', // 米饭
        'resources/base/media/ic_fast.png',      // 粥
        'resources/base/media/ic_noodles.png'    // 饼干
      ];
    }
    for (let i = 0; i < CommonConstants.COUNT; i++) {
      let image = new ImageBitmap(imageSrc[i]);
      this.canvasContext?.save();
      this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE);
      this.canvasContext?.drawImage(image, this.screenWidth * CommonConstants.IMAGE_DX_RATIOS,
        this.screenWidth * CommonConstants.IMAGE_DY_RATIOS, CommonConstants.IMAGE_SIZE,
        CommonConstants.IMAGE_SIZE);
      beginAngle += this.avgAngle;
      this.canvasContext?.restore();
    }
  }

  /**
   * Displaying information about prizes.
   *
   * @param randomAngle randomAngle.
   */
  showPrizeData(randomAngle: number): PrizeData {
    // Calculate sector index directly from randomAngle
    // Sectors: 0-60°→1, 60-120°→2, 120-180°→3, 180-240°→4, 240-300°→5, 300-360°→6
    // Use modulo to handle 360 degrees (which should map to sector 1)
    const normalizedAngle = randomAngle % CommonConstants.CIRCLE;
    const sectorIndex = Math.floor(normalizedAngle / this.avgAngle) + 1;
    
    // Ensure sector index is within 1-6
    if (sectorIndex >= 1 && sectorIndex <= CommonConstants.COUNT) {
      return this.getPrizeData(sectorIndex);
    }
    
    // Fallback (should not happen)
    return this.getPrizeData(CommonConstants.COUNT);
  }

  /**
   * Obtaining information about prizes.
   *
   * @param scopeNum scopeNum.
   */
  getPrizeData(scopeNum: number): PrizeData {
    let prizeData: PrizeData = new PrizeData();
    if (this.isMoneyMode) {
      // 钱多模式奖品
      switch (scopeNum) {
        case EnumeratedValue.ONE:
          prizeData.message = $r('app.string.prize_text_chinese');
          prizeData.imageSrc = CommonConstants.CHINESE_IMAGE_URL;
          break;
        case EnumeratedValue.TWO:
          prizeData.message = $r('app.string.prize_text_western');
          prizeData.imageSrc = CommonConstants.WESTERN_IMAGE_URL;
          break;
        case EnumeratedValue.THREE:
          prizeData.message = $r('app.string.prize_text_japanese');
          prizeData.imageSrc = CommonConstants.JAPANESE_IMAGE_URL;
          break;
        case EnumeratedValue.FOUR:
          prizeData.message = $r('app.string.prize_text_fast');
          prizeData.imageSrc = CommonConstants.FAST_IMAGE_URL;
          break;
        case EnumeratedValue.FIVE:
          prizeData.message = $r('app.string.prize_text_vegetarian');
          prizeData.imageSrc = CommonConstants.VEGETARIAN_IMAGE_URL;
          break;
        case EnumeratedValue.SIX:
          prizeData.message = $r('app.string.prize_text_noodles');
          prizeData.imageSrc = CommonConstants.NOODLES_IMAGE_URL;
          break;
        default:
          break;
      }
    } else {
      // 钱少模式奖品
      switch (scopeNum) {
        case EnumeratedValue.ONE:
          prizeData.message = $r('app.string.prize_text_instant_noodles');
          prizeData.imageSrc = 'resources/base/media/ic_cake.png';
          break;
        case EnumeratedValue.TWO:
          prizeData.message = $r('app.string.prize_text_bread');
          prizeData.imageSrc = 'resources/base/media/ic_hamburg.png';
          break;
        case EnumeratedValue.THREE:
          prizeData.message = $r('app.string.prize_text_steamed_bun');
          prizeData.imageSrc = 'resources/base/media/ic_smile.png';
          break;
        case EnumeratedValue.FOUR:
          prizeData.message = $r('app.string.prize_text_rice');
          prizeData.imageSrc = 'resources/base/media/ic_watermelon.png';
          break;
        case EnumeratedValue.FIVE:
          prizeData.message = $r('app.string.prize_text_porridge');
          prizeData.imageSrc = 'resources/base/media/ic_fast.png';
          break;
        case EnumeratedValue.SIX:
          prizeData.message = $r('app.string.prize_text_biscuit');
          prizeData.imageSrc = 'resources/base/media/ic_noodles.png';
          break;
        default:
          break;
      }
    }
    return prizeData;
  }
}
