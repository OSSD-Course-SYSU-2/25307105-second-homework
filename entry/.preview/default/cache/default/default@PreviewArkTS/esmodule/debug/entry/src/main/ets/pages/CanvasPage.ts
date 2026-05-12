if (!("finalizeConstruction" in ViewPU.prototype)) {
    Reflect.set(ViewPU.prototype, "finalizeConstruction", () => { });
}
interface CanvasPage_Params {
    settings?: RenderingContextSettings;
    canvasContext?: CanvasRenderingContext2D;
    drawModel?: DrawModel;
    screenWidth?: number;
    screenHeight?: number;
    rotateDegree?: number;
    enableFlag?: boolean;
    prizeData?: PrizeData;
    isMoneyMode?: boolean;
    foodList?: FoodItem[];
    newFoodName?: string;
    dialogController?: CustomDialogController;
}
import window from "@ohos:window";
import Logger from "@bundle:com.example.canvascomponent/entry/ets/common/utils/Logger";
import DrawModel from "@bundle:com.example.canvascomponent/entry/ets/viewmodel/DrawModel";
import type { FoodItem } from "@bundle:com.example.canvascomponent/entry/ets/viewmodel/DrawModel";
import PrizeDialog from "@bundle:com.example.canvascomponent/entry/ets/view/PrizeDialog";
import PrizeData from "@bundle:com.example.canvascomponent/entry/ets/viewmodel/PrizeData";
import StyleConstants from "@bundle:com.example.canvascomponent/entry/ets/common/constants/StyleConstants";
import CommonConstants from "@bundle:com.example.canvascomponent/entry/ets/common/constants/CommonConstants";
import type { Context } from "@ohos:abilityAccessCtrl";
// Get context.
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context: Context = uiContext!.getHostContext()!;
class CanvasPage extends ViewPU {
    constructor(parent, params, __localStorage, elmtId = -1, paramsLambda = undefined, extraInfo) {
        super(parent, __localStorage, elmtId, extraInfo);
        if (typeof paramsLambda === "function") {
            this.paramsGenerator_ = paramsLambda;
        }
        this.settings = new RenderingContextSettings(true);
        this.canvasContext = new CanvasRenderingContext2D(this.settings);
        this.__drawModel = new ObservedPropertyObjectPU(new DrawModel(), this, "drawModel");
        this.__screenWidth = new ObservedPropertySimplePU(0, this, "screenWidth");
        this.__screenHeight = new ObservedPropertySimplePU(0, this, "screenHeight");
        this.__rotateDegree = new ObservedPropertySimplePU(0, this, "rotateDegree");
        this.__enableFlag = new ObservedPropertySimplePU(true, this, "enableFlag");
        this.__prizeData = new ObservedPropertyObjectPU(new PrizeData(), this, "prizeData");
        this.__isMoneyMode = new ObservedPropertySimplePU(true, this, "isMoneyMode");
        this.__foodList = new ObservedPropertyObjectPU([
            { name: '中餐', icon: 'resources/base/media/ic_chinese.png', bgColor: '#FFB6C1' },
            { name: '西餐', icon: 'resources/base/media/ic_western.png', bgColor: '#FFE4B5' },
            { name: '日料', icon: 'resources/base/media/ic_japanese.png', bgColor: '#98FB98' },
            { name: '快餐', icon: 'resources/base/media/ic_fast.png', bgColor: '#FFB6C1' },
            { name: '素食', icon: 'resources/base/media/ic_vegetarian.png', bgColor: '#FFE4B5' }
        ], this, "foodList");
        this.__newFoodName = new ObservedPropertySimplePU('', this, "newFoodName");
        this.dialogController = new CustomDialogController({
            builder: () => {
                let jsDialog = new PrizeDialog(this, {
                    prizeData: this.__prizeData,
                    enableFlag: this.__enableFlag
                }, undefined, -1, () => { }, { page: "entry/src/main/ets/pages/CanvasPage.ets", line: 51, col: 14 });
                jsDialog.setController(this.dialogController);
                ViewPU.create(jsDialog);
                let paramsLambda = () => {
                    return {
                        prizeData: this.__prizeData,
                        enableFlag: this.__enableFlag
                    };
                };
                jsDialog.paramsGenerator_ = paramsLambda;
            },
            autoCancel: false,
            alignment: DialogAlignment.Center,
            cancel: () => {
                this.enableFlag = !this.enableFlag;
            }
        }, this);
        this.setInitiallyProvidedValue(params);
        this.finalizeConstruction();
    }
    setInitiallyProvidedValue(params: CanvasPage_Params) {
        if (params.settings !== undefined) {
            this.settings = params.settings;
        }
        if (params.canvasContext !== undefined) {
            this.canvasContext = params.canvasContext;
        }
        if (params.drawModel !== undefined) {
            this.drawModel = params.drawModel;
        }
        if (params.screenWidth !== undefined) {
            this.screenWidth = params.screenWidth;
        }
        if (params.screenHeight !== undefined) {
            this.screenHeight = params.screenHeight;
        }
        if (params.rotateDegree !== undefined) {
            this.rotateDegree = params.rotateDegree;
        }
        if (params.enableFlag !== undefined) {
            this.enableFlag = params.enableFlag;
        }
        if (params.prizeData !== undefined) {
            this.prizeData = params.prizeData;
        }
        if (params.isMoneyMode !== undefined) {
            this.isMoneyMode = params.isMoneyMode;
        }
        if (params.foodList !== undefined) {
            this.foodList = params.foodList;
        }
        if (params.newFoodName !== undefined) {
            this.newFoodName = params.newFoodName;
        }
        if (params.dialogController !== undefined) {
            this.dialogController = params.dialogController;
        }
    }
    updateStateVars(params: CanvasPage_Params) {
    }
    purgeVariableDependenciesOnElmtId(rmElmtId) {
        this.__drawModel.purgeDependencyOnElmtId(rmElmtId);
        this.__screenWidth.purgeDependencyOnElmtId(rmElmtId);
        this.__screenHeight.purgeDependencyOnElmtId(rmElmtId);
        this.__rotateDegree.purgeDependencyOnElmtId(rmElmtId);
        this.__enableFlag.purgeDependencyOnElmtId(rmElmtId);
        this.__prizeData.purgeDependencyOnElmtId(rmElmtId);
        this.__isMoneyMode.purgeDependencyOnElmtId(rmElmtId);
        this.__foodList.purgeDependencyOnElmtId(rmElmtId);
        this.__newFoodName.purgeDependencyOnElmtId(rmElmtId);
    }
    aboutToBeDeleted() {
        this.__drawModel.aboutToBeDeleted();
        this.__screenWidth.aboutToBeDeleted();
        this.__screenHeight.aboutToBeDeleted();
        this.__rotateDegree.aboutToBeDeleted();
        this.__enableFlag.aboutToBeDeleted();
        this.__prizeData.aboutToBeDeleted();
        this.__isMoneyMode.aboutToBeDeleted();
        this.__foodList.aboutToBeDeleted();
        this.__newFoodName.aboutToBeDeleted();
        SubscriberManager.Get().delete(this.id__());
        this.aboutToBeDeletedInternal();
    }
    private settings: RenderingContextSettings;
    private canvasContext: CanvasRenderingContext2D;
    private __drawModel: ObservedPropertyObjectPU<DrawModel>;
    get drawModel() {
        return this.__drawModel.get();
    }
    set drawModel(newValue: DrawModel) {
        this.__drawModel.set(newValue);
    }
    private __screenWidth: ObservedPropertySimplePU<number>;
    get screenWidth() {
        return this.__screenWidth.get();
    }
    set screenWidth(newValue: number) {
        this.__screenWidth.set(newValue);
    }
    private __screenHeight: ObservedPropertySimplePU<number>;
    get screenHeight() {
        return this.__screenHeight.get();
    }
    set screenHeight(newValue: number) {
        this.__screenHeight.set(newValue);
    }
    private __rotateDegree: ObservedPropertySimplePU<number>;
    get rotateDegree() {
        return this.__rotateDegree.get();
    }
    set rotateDegree(newValue: number) {
        this.__rotateDegree.set(newValue);
    }
    private __enableFlag: ObservedPropertySimplePU<boolean>;
    get enableFlag() {
        return this.__enableFlag.get();
    }
    set enableFlag(newValue: boolean) {
        this.__enableFlag.set(newValue);
    }
    private __prizeData: ObservedPropertyObjectPU<PrizeData>;
    get prizeData() {
        return this.__prizeData.get();
    }
    set prizeData(newValue: PrizeData) {
        this.__prizeData.set(newValue);
    }
    private __isMoneyMode: ObservedPropertySimplePU<boolean>; // true: 钱多模式, false: 钱少模式
    get isMoneyMode() {
        return this.__isMoneyMode.get();
    }
    set isMoneyMode(newValue: boolean) {
        this.__isMoneyMode.set(newValue);
    }
    // 动态数据源
    private __foodList: ObservedPropertyObjectPU<FoodItem[]>;
    get foodList() {
        return this.__foodList.get();
    }
    set foodList(newValue: FoodItem[]) {
        this.__foodList.set(newValue);
    }
    private __newFoodName: ObservedPropertySimplePU<string>; // 新食物名称输入
    get newFoodName() {
        return this.__newFoodName.get();
    }
    set newFoodName(newValue: string) {
        this.__newFoodName.set(newValue);
    }
    private dialogController: CustomDialogController;
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
        });
    }
    initialRender() {
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Column.create();
            Column.debugLine("entry/src/main/ets/pages/CanvasPage.ets(77:5)", "entry");
            Column.width(StyleConstants.FULL_PERCENT);
            Column.height(StyleConstants.FULL_PERCENT);
            Column.backgroundImage({ "id": 16777267, "type": 20000, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" }, ImageRepeat.NoRepeat);
            Column.backgroundImageSize({
                width: StyleConstants.FULL_PERCENT,
                height: StyleConstants.BACKGROUND_IMAGE_SIZE
            });
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 模式切换按钮
            Row.create({ space: 20 });
            Row.debugLine("entry/src/main/ets/pages/CanvasPage.ets(79:7)", "entry");
            // 模式切换按钮
            Row.width('100%');
            // 模式切换按钮
            Row.justifyContent(FlexAlign.Center);
            // 模式切换按钮
            Row.padding({ top: 20, bottom: 10 });
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel(this.getModeText());
            Button.debugLine("entry/src/main/ets/pages/CanvasPage.ets(80:9)", "entry");
            Button.fontSize(16);
            Button.fontWeight(FontWeight.Medium);
            Button.backgroundColor(this.isMoneyMode ? '#FF6B35' : '#4CAF50');
            Button.fontColor(Color.White);
            Button.padding({ left: 20, right: 20, top: 10, bottom: 10 });
            Button.borderRadius(20);
            Button.onClick(() => {
                this.isMoneyMode = !this.isMoneyMode;
                // 切换模式后重新绘制转盘
                this.drawModel.setMode(this.isMoneyMode);
                this.drawModel.setFoodList(ObservedObject.GetRawObject(this.foodList));
                this.drawModel.draw(this.canvasContext, this.screenWidth, this.screenHeight);
            });
        }, Button);
        Button.pop();
        // 模式切换按钮
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Stack.create({ alignContent: Alignment.Center });
            Stack.debugLine("entry/src/main/ets/pages/CanvasPage.ets(99:7)", "entry");
            Stack.width(StyleConstants.FULL_PERCENT);
            Stack.height(StyleConstants.FULL_PERCENT);
        }, Stack);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Canvas.create(this.canvasContext);
            Canvas.debugLine("entry/src/main/ets/pages/CanvasPage.ets(100:9)", "entry");
            Canvas.width(StyleConstants.FULL_PERCENT);
            Canvas.height(StyleConstants.FULL_PERCENT);
            Canvas.onReady(() => {
                this.drawModel.setFoodList(ObservedObject.GetRawObject(this.foodList));
                this.drawModel.draw(this.canvasContext, this.screenWidth, this.screenHeight);
            });
            Canvas.rotate({
                x: 0,
                y: 0,
                z: 1,
                angle: this.rotateDegree,
                centerX: this.screenWidth / CommonConstants.TWO,
                centerY: this.screenHeight / CommonConstants.TWO
            });
        }, Canvas);
        Canvas.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Image.create({ "id": 16777222, "type": 20000, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" });
            Image.debugLine("entry/src/main/ets/pages/CanvasPage.ets(116:9)", "entry");
            Image.width(StyleConstants.CENTER_IMAGE_WIDTH);
            Image.height(StyleConstants.CENTER_IMAGE_HEIGHT);
            Image.enabled(this.enableFlag);
            Image.onClick(() => {
                this.enableFlag = !this.enableFlag;
                this.startAnimator();
            });
        }, Image);
        Stack.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            // 动态添加食物UI
            Column.create({ space: 10 });
            Column.debugLine("entry/src/main/ets/pages/CanvasPage.ets(129:7)", "entry");
            // 动态添加食物UI
            Column.width('100%');
            // 动态添加食物UI
            Column.padding({ left: 20, right: 20, top: 10, bottom: 20 });
            // 动态添加食物UI
            Column.backgroundColor('#FFFFFF');
        }, Column);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Text.create('当前食物数量: ' + this.foodList.length);
            Text.debugLine("entry/src/main/ets/pages/CanvasPage.ets(130:9)", "entry");
            Text.fontSize(14);
            Text.fontColor('#666666');
        }, Text);
        Text.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Row.create({ space: 10 });
            Row.debugLine("entry/src/main/ets/pages/CanvasPage.ets(134:9)", "entry");
            Row.width('100%');
            Row.justifyContent(FlexAlign.Center);
        }, Row);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            TextInput.create({ placeholder: '输入新食物名称' });
            TextInput.debugLine("entry/src/main/ets/pages/CanvasPage.ets(135:11)", "entry");
            TextInput.width(200);
            TextInput.height(40);
            TextInput.onChange((value: string) => {
                this.newFoodName = value;
            });
        }, TextInput);
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            Button.createWithLabel('添加');
            Button.debugLine("entry/src/main/ets/pages/CanvasPage.ets(142:11)", "entry");
            Button.fontSize(16);
            Button.fontWeight(FontWeight.Medium);
            Button.backgroundColor('#4CAF50');
            Button.fontColor(Color.White);
            Button.width(80);
            Button.height(40);
            Button.borderRadius(8);
            Button.onClick(() => {
                this.addNewFood();
            });
        }, Button);
        Button.pop();
        Row.pop();
        this.observeComponentCreation2((elmtId, isInitialRender) => {
            If.create();
            // 食物列表（可删除）
            if (this.foodList.length > 0) {
                this.ifElseBranchUpdateFunction(0, () => {
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        Text.create('食物列表（点击删除）');
                        Text.debugLine("entry/src/main/ets/pages/CanvasPage.ets(159:11)", "entry");
                        Text.fontSize(12);
                        Text.fontColor('#999999');
                        Text.margin({ top: 5 });
                    }, Text);
                    Text.pop();
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        List.create({ space: 8 });
                        List.debugLine("entry/src/main/ets/pages/CanvasPage.ets(164:11)", "entry");
                        List.width('100%');
                        List.height(Math.min(this.foodList.length * 50, 150));
                        List.margin({ top: 5 });
                    }, List);
                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                        ForEach.create();
                        const forEachItemGenFunction = (_item, index: number) => {
                            const item = _item;
                            {
                                const itemCreation = (elmtId, isInitialRender) => {
                                    ViewStackProcessor.StartGetAccessRecordingFor(elmtId);
                                    ListItem.create(deepRenderFunction, true);
                                    if (!isInitialRender) {
                                        ListItem.pop();
                                    }
                                    ViewStackProcessor.StopGetAccessRecording();
                                };
                                const itemCreation2 = (elmtId, isInitialRender) => {
                                    ListItem.create(deepRenderFunction, true);
                                    ListItem.debugLine("entry/src/main/ets/pages/CanvasPage.ets(166:15)", "entry");
                                };
                                const deepRenderFunction = (elmtId, isInitialRender) => {
                                    itemCreation(elmtId, isInitialRender);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Row.create({ space: 10 });
                                        Row.debugLine("entry/src/main/ets/pages/CanvasPage.ets(167:17)", "entry");
                                        Row.width('100%');
                                        Row.padding({ left: 12, right: 12, top: 8, bottom: 8 });
                                        Row.backgroundColor('#F5F5F5');
                                        Row.borderRadius(8);
                                    }, Row);
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create(item.name);
                                        Text.debugLine("entry/src/main/ets/pages/CanvasPage.ets(168:19)", "entry");
                                        Text.fontSize(14);
                                        Text.fontColor('#333333');
                                        Text.layoutWeight(1);
                                    }, Text);
                                    Text.pop();
                                    this.observeComponentCreation2((elmtId, isInitialRender) => {
                                        Text.create('删除');
                                        Text.debugLine("entry/src/main/ets/pages/CanvasPage.ets(173:19)", "entry");
                                        Text.fontSize(12);
                                        Text.fontColor('#FF4444');
                                        Text.padding({ left: 8, right: 8, top: 4, bottom: 4 });
                                        Text.backgroundColor('#FFEEEE');
                                        Text.borderRadius(4);
                                        Text.onClick(() => {
                                            this.deleteFood(index);
                                        });
                                    }, Text);
                                    Text.pop();
                                    Row.pop();
                                    ListItem.pop();
                                };
                                this.observeComponentCreation2(itemCreation2, ListItem);
                                ListItem.pop();
                            }
                        };
                        this.forEachUpdateFunction(elmtId, this.foodList, forEachItemGenFunction, (item: FoodItem, index: number) => index.toString(), true, true);
                    }, ForEach);
                    ForEach.pop();
                    List.pop();
                });
            }
            else {
                this.ifElseBranchUpdateFunction(1, () => {
                });
            }
        }, If);
        If.pop();
        // 动态添加食物UI
        Column.pop();
        Column.pop();
    }
    /**
     * Get mode text for button.
     */
    getModeText(): string {
        const resource = this.isMoneyMode ? { "id": 16777259, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" } : { "id": 16777258, "type": 10003, params: [], "bundleName": "com.example.canvascomponent", "moduleName": "entry" };
        try {
            return uiContext!.getHostContext()!.resourceManager.getStringSync(resource.id);
        }
        catch (error) {
            return this.isMoneyMode ? '钱多模式' : '钱少模式';
        }
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
        });
    }
    /**
     * Add new food item to the list.
     */
    addNewFood() {
        if (this.newFoodName.trim() === '') {
            return;
        }
        // 默认颜色循环
        let colors = ['#FFB6C1', '#FFE4B5', '#98FB98', '#87CEEB', '#DDA0DD'];
        let colorIndex = this.foodList.length % colors.length;
        // 默认图标循环
        let icons = [
            'resources/base/media/ic_chinese.png',
            'resources/base/media/ic_western.png',
            'resources/base/media/ic_japanese.png',
            'resources/base/media/ic_fast.png',
            'resources/base/media/ic_vegetarian.png',
            'resources/base/media/ic_noodles.png'
        ];
        let iconIndex = this.foodList.length % icons.length;
        let newFood: FoodItem = {
            name: this.newFoodName.trim(),
            icon: icons[iconIndex],
            bgColor: colors[colorIndex]
        };
        this.foodList.push(newFood);
        this.newFoodName = '';
        // 更新drawModel并重绘Canvas
        this.drawModel.setFoodList(this.foodList);
        this.drawModel.draw(this.canvasContext, this.screenWidth, this.screenHeight);
    }
    /**
     * Delete food item from the list.
     *
     * @param index index of the food item to delete.
     */
    deleteFood(index: number) {
        if (index >= 0 && index < this.foodList.length) {
            this.foodList.splice(index, 1);
            // 更新drawModel并重绘Canvas
            this.drawModel.setFoodList(this.foodList);
            this.drawModel.draw(this.canvasContext, this.screenWidth, this.screenHeight);
        }
    }
    rerender() {
        this.updateDirtyElements();
    }
    static getEntryName(): string {
        return "CanvasPage";
    }
}
registerNamedRoute(() => new CanvasPage(undefined, {}), "", { bundleName: "com.example.canvascomponent", moduleName: "entry", pagePath: "pages/CanvasPage", pageFullPath: "entry/src/main/ets/pages/CanvasPage", integratedHsp: "false", moduleType: "followWithHap" });
