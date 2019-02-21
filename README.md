# flutter_admob

Flutter plugin support [AdMob](https://admob.google.com/home/?gclid=EAIaIQobChMI8MrZ7-HL4AIVhB-tBh1KrQUNEAAYASAAEgLgUvD_BwE)

## Getting Started

```dart
import 'package:flutter_admob/flutter_admob.dart';

...

FlutterAdmob.init("ca-app-pub-3940256099942544~3347511713").then((_) {
  // FlutterAdmob.showBanner("ca-app-pub-3940256099942544/6300978111", 
  //   size: Size.SMART_BANNER,
  //   gravity: Gravity.BOTTOM,
  //   anchorOffset: 60,
  // ); // Banner 广告
  // FlutterAdmob.showInterstitial("ca-app-pub-3940256099942544/1033173712"); // 插页广告
  FlutterAdmob.showRewardVideo("ca-app-pub-3940256099942544/5224354917"); // 激励广告
});

```

## Android

Must add `<meta-data>` to `AndroidManifest.xml` to `<application>` tag

```xml
<application>
   <meta-data
      android:name="com.google.android.gms.ads.APPLICATION_ID"
      android:value="[ADMOB_APP_ID]"/>
</application>
```
