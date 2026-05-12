# Lunch Picker

A HarmonyOS lunch decision app built with ArkTS and ArkUI. It helps users decide what to eat for lunch with candidate management, tag filtering, confirmation before saving, local persistence, simple statistics, and anti-indecision reroll limits.

## Highlights

- Generate a recommendation first, then save it only after confirmation.
- Reroll up to 3 times per round; the third reroll is automatically confirmed.
- Filter candidates by tags such as rice, noodles, light food, takeout, or healthy.
- Store candidates, tags, and history locally with HarmonyOS Preferences.
- Keep the main screen focused by folding less frequent tools such as add, history, and management panels.

## Features

- Add and delete lunch candidates.
- Add multiple tags to each candidate.
- Filter candidates by tag.
- Confirm recommendations before they enter history.
- Avoid recently confirmed meals and reduce the weight of frequently chosen meals.
- View simple stats: total confirmations, most frequent meal, and longest unchosen meal.
- Restore default candidates.
- Clear current result or history.

## Tech Stack

- HarmonyOS
- ArkTS
- ArkUI
- Stage model
- Preferences local storage

## Main Files

```text
entry/src/main/ets/entryability/EntryAbility.ts
entry/src/main/ets/pages/LunchPickerPage.ets
entry/src/main/ets/viewmodel/LunchPickerViewModel.ets
entry/src/main/ets/viewmodel/LunchHistoryItem.ets
entry/src/main/ets/common/utils/LunchStorage.ets
entry/src/main/resources/base/profile/main_pages.json
```

## Requirements

- Device type: phone
- HarmonyOS 5.0.5 Release or later
- DevEco Studio 6.0.2 Release or later
- HarmonyOS SDK 6.0.2 Release SDK or later

## Run

1. Open the `Lunch_chooser` project with DevEco Studio.
2. Wait for project sync to complete.
3. Select a HarmonyOS emulator or device.
4. Run the `entry` module.

## License

Apache License 2.0. See [LICENSE](./LICENSE).
