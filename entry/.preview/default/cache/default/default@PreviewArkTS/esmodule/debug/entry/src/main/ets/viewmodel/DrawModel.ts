import CommonConstants from "@bundle:com.example.canvascomponent/entry/ets/common/constants/CommonConstants";
import { EnumeratedValue } from "@bundle:com.example.canvascomponent/entry/ets/common/constants/CommonConstants";
import ColorConstants from "@bundle:com.example.canvascomponent/entry/ets/common/constants/ColorConstants";
import StyleConstants from "@bundle:com.example.canvascomponent/entry/ets/common/constants/StyleConstants";
import PrizeData from "@bundle:com.example.canvascomponent/entry/ets/viewmodel/PrizeData";
import FillArcData from "@bundle:com.example.canvascomponent/entry/ets/viewmodel/FillArcData";
import Logger from "@bundle:com.example.canvascomponent/entry/ets/common/utils/Logger";
import CheckEmptyUtils from "@bundle:com.example.canvascomponent/entry/ets/common/utils/CheckEmptyUtils";
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
/**
 * Food item interface for dynamic data source.
 */
export interface FoodItem {
    name: string;
    icon: string;
    bgColor: string;
}
/**
 * Canvas drawing method class.
 */
export default class DrawModel {
    private startAngle: number = 0;
    private avgAngle: number = CommonConstants.CIRCLE / CommonConstants.COUNT;
    private screenWidth: number = 0;
    private canvasContext?: CanvasRenderingContext2D;
    private isMoneyMode: boolean = true; // true: 钱多模式, false: 钱少模式
    private foodList: FoodItem[] = []; // 动态食物列表
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
        this.canvasContext.translate(this.screenWidth / CommonConstants.TWO, screenHeight / CommonConstants.TWO);
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
        this.canvasContext.translate(-this.screenWidth / CommonConstants.TWO, -screenHeight / CommonConstants.TWO);
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
     * Set food list for dynamic data source.
     *
     * @param foodList food item array.
     */
    setFoodList(foodList: FoodItem[]) {
        this.foodList = foodList;
        // 动态计算平均角度
        if (this.foodList.length > 0) {
            this.avgAngle = CommonConstants.CIRCLE / this.foodList.length;
        }
    }
    /**
     * Get current food list.
     */
    getFoodList(): FoodItem[] {
        return this.foodList;
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
            this.canvasContext.arc(fillArcData.x, fillArcData.y, fillArcData.radius, fillArcData.startAngle, fillArcData.endAngle);
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
            this.fillArc(new FillArcData(0, -pointY, radius, 0, Math.PI * CommonConstants.TWO), ColorConstants.FLOWER_OUT_COLOR);
            this.fillArc(new FillArcData(0, -pointY, innerRadius, 0, Math.PI * CommonConstants.TWO), ColorConstants.FLOWER_INNER_COLOR);
            beginAngle += this.avgAngle;
            this.canvasContext?.restore();
        }
    }
    /**
     * Draw outer disc, small circle.
     */
    drawOutCircle() {
        // Draw outer disc.
        this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.OUT_CIRCLE_RATIOS, 0, Math.PI * CommonConstants.TWO), ColorConstants.OUT_CIRCLE_COLOR);
        let beginAngle = this.startAngle;
        // Draw small circle.
        for (let i = 0; i < CommonConstants.SMALL_CIRCLE_COUNT; i++) {
            this.canvasContext?.save();
            this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE);
            this.fillArc(new FillArcData(this.screenWidth * CommonConstants.SMALL_CIRCLE_RATIOS, 0, CommonConstants.SMALL_CIRCLE_RADIUS, 0, Math.PI * CommonConstants.TWO), ColorConstants.WHITE_COLOR);
            beginAngle = beginAngle + CommonConstants.CIRCLE / CommonConstants.SMALL_CIRCLE_COUNT;
            this.canvasContext?.restore();
        }
    }
    /**
     * Draw the inner disc.
     */
    drawInnerCircle() {
        this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.INNER_CIRCLE_RATIOS, 0, Math.PI * CommonConstants.TWO), ColorConstants.INNER_CIRCLE_COLOR);
        this.fillArc(new FillArcData(0, 0, this.screenWidth * CommonConstants.INNER_WHITE_CIRCLE_RATIOS, 0, Math.PI * CommonConstants.TWO), ColorConstants.WHITE_COLOR);
    }
    /**
     * Draw the interior fan-shaped raffle area.
     */
    drawInnerArc() {
        // 默认颜色数组（用于没有设置bgColor的情况）
        let defaultColors = [
            ColorConstants.ARC_PINK_COLOR, ColorConstants.ARC_YELLOW_COLOR,
            ColorConstants.ARC_GREEN_COLOR, ColorConstants.ARC_PINK_COLOR,
            ColorConstants.ARC_YELLOW_COLOR, ColorConstants.ARC_GREEN_COLOR
        ];
        let radius = this.screenWidth * CommonConstants.INNER_ARC_RATIOS;
        let count = this.foodList.length > 0 ? this.foodList.length : CommonConstants.COUNT;
        for (let i = 0; i < count; i++) {
            // 优先使用foodList中的bgColor，否则使用默认颜色
            let color = this.foodList.length > 0 && this.foodList[i].bgColor
                ? this.foodList[i].bgColor
                : defaultColors[i % defaultColors.length];
            this.fillArc(new FillArcData(0, 0, radius, this.startAngle * Math.PI / CommonConstants.HALF_CIRCLE, (this.startAngle + this.avgAngle) * Math.PI / CommonConstants.HALF_CIRCLE), color);
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
        let count = this.foodList.length > 0 ? this.foodList.length : CommonConstants.COUNT;
        let arcTextStartAngle = CommonConstants.ARC_START_ANGLE;
        let arcTextEndAngle = CommonConstants.ARC_END_ANGLE;
        for (let i = 0; i < count; i++) {
            // 优先使用foodList中的name，否则使用默认文字
            let text: string;
            if (this.foodList.length > 0) {
                text = this.foodList[i].name;
            }
            else {
                // 默认文字（兼容旧逻辑）
                let textArrays: Resource[];
                if (this.isMoneyMode) {
                    textArrays = [
                        { "id": 16777253, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777265, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777257, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777255, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777264, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777260, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" }
                    ];
                }
                else {
                    textArrays = [
                        { "id": 16777256, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777252, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777263, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777262, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777261, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" },
                        { "id": 16777251, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" }
                    ];
                }
                text = this.getResourceString(textArrays[i]);
            }
            this.drawCircularText(text, (this.startAngle + arcTextStartAngle) * Math.PI / CommonConstants.HALF_CIRCLE, (this.startAngle + arcTextEndAngle) * Math.PI / CommonConstants.HALF_CIRCLE);
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
            Logger.error('[DrawModel][getResourceString] resource is empty.');
            return '';
        }
        let resourceString: string = '';
        try {
            resourceString = uiContext!.getHostContext()!.resourceManager.getStringSync(resource.id);
        }
        catch (error) {
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
            Logger.error('[DrawModel][drawCircularText] textString is empty.');
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
            this.canvasContext?.translate(circleText.x + Math.cos(angle) * radius, circleText.y + Math.sin(angle) * radius);
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
        let count = this.foodList.length > 0 ? this.foodList.length : CommonConstants.COUNT;
        // 默认图片数组（用于没有设置icon的情况）
        let defaultImageSrc: string[];
        if (this.isMoneyMode) {
            defaultImageSrc = [
                CommonConstants.CHINESE_IMAGE_URL, CommonConstants.WESTERN_IMAGE_URL,
                CommonConstants.JAPANESE_IMAGE_URL, CommonConstants.FAST_IMAGE_URL,
                CommonConstants.VEGETARIAN_IMAGE_URL, CommonConstants.NOODLES_IMAGE_URL
            ];
        }
        else {
            defaultImageSrc = [
                'resources/base/media/ic_cake.png',
                'resources/base/media/ic_hamburg.png',
                'resources/base/media/ic_smile.png',
                'resources/base/media/ic_watermelon.png',
                'resources/base/media/ic_fast.png',
                'resources/base/media/ic_noodles.png'
            ];
        }
        for (let i = 0; i < count; i++) {
            // 优先使用foodList中的icon，否则使用默认图片
            let imageSrc = this.foodList.length > 0 && this.foodList[i].icon
                ? this.foodList[i].icon
                : defaultImageSrc[i % defaultImageSrc.length];
            let image = new ImageBitmap(imageSrc);
            this.canvasContext?.save();
            this.canvasContext?.rotate(beginAngle * Math.PI / CommonConstants.HALF_CIRCLE);
            this.canvasContext?.drawImage(image, this.screenWidth * CommonConstants.IMAGE_DX_RATIOS, this.screenWidth * CommonConstants.IMAGE_DY_RATIOS, CommonConstants.IMAGE_SIZE, CommonConstants.IMAGE_SIZE);
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
        const normalizedAngle = randomAngle % CommonConstants.CIRCLE;
        const sectorIndex = Math.floor(normalizedAngle / this.avgAngle) + 1;
        let count = this.foodList.length > 0 ? this.foodList.length : CommonConstants.COUNT;
        // Ensure sector index is within valid range
        if (sectorIndex >= 1 && sectorIndex <= count) {
            return this.getPrizeData(sectorIndex);
        }
        // Fallback (should not happen)
        return this.getPrizeData(count);
    }
    /**
     * Obtaining information about prizes.
     *
     * @param scopeNum scopeNum.
     */
    getPrizeData(scopeNum: number): PrizeData {
        let prizeData: PrizeData = new PrizeData();
        // 优先使用动态foodList
        if (this.foodList.length > 0 && scopeNum >= 1 && scopeNum <= this.foodList.length) {
            let item = this.foodList[scopeNum - 1];
            prizeData.message = item.name;
            prizeData.imageSrc = item.icon;
            return prizeData;
        }
        // 兼容旧逻辑
        if (this.isMoneyMode) {
            switch (scopeNum) {
                case EnumeratedValue.ONE:
                    prizeData.message = { "id": 16777241, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = CommonConstants.CHINESE_IMAGE_URL;
                    break;
                case EnumeratedValue.TWO:
                    prizeData.message = { "id": 16777250, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = CommonConstants.WESTERN_IMAGE_URL;
                    break;
                case EnumeratedValue.THREE:
                    prizeData.message = { "id": 16777244, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = CommonConstants.JAPANESE_IMAGE_URL;
                    break;
                case EnumeratedValue.FOUR:
                    prizeData.message = { "id": 16777242, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = CommonConstants.FAST_IMAGE_URL;
                    break;
                case EnumeratedValue.FIVE:
                    prizeData.message = { "id": 16777249, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = CommonConstants.VEGETARIAN_IMAGE_URL;
                    break;
                case EnumeratedValue.SIX:
                    prizeData.message = { "id": 16777245, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = CommonConstants.NOODLES_IMAGE_URL;
                    break;
                default:
                    break;
            }
        }
        else {
            switch (scopeNum) {
                case EnumeratedValue.ONE:
                    prizeData.message = { "id": 16777243, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = 'resources/base/media/ic_cake.png';
                    break;
                case EnumeratedValue.TWO:
                    prizeData.message = { "id": 16777240, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = 'resources/base/media/ic_hamburg.png';
                    break;
                case EnumeratedValue.THREE:
                    prizeData.message = { "id": 16777248, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = 'resources/base/media/ic_smile.png';
                    break;
                case EnumeratedValue.FOUR:
                    prizeData.message = { "id": 16777247, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = 'resources/base/media/ic_watermelon.png';
                    break;
                case EnumeratedValue.FIVE:
                    prizeData.message = { "id": 16777246, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = 'resources/base/media/ic_fast.png';
                    break;
                case EnumeratedValue.SIX:
                    prizeData.message = { "id": 16777239, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
                    prizeData.imageSrc = 'resources/base/media/ic_noodles.png';
                    break;
                default:
                    break;
            }
        }
        return prizeData;
    }
}
