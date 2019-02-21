package com.admob.flutteradmob;

import android.view.Gravity;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.google.android.gms.ads.AdListener;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.AdSize;
import com.google.android.gms.ads.AdView;
import com.google.android.gms.ads.InterstitialAd;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.reward.RewardItem;
import com.google.android.gms.ads.reward.RewardedVideoAd;
import com.google.android.gms.ads.reward.RewardedVideoAdListener;

/** FlutterAdmobPlugin */
public class FlutterAdmobPlugin implements MethodCallHandler {

  private enum Size {
    BANNER,
    LARGE_BANNER,
    MEDIUM_RECTANGLE,
    FULL_BANNER,
    LEADER_BOARD,
    SMART_BANNER,
  }

  private enum Gravity {
    TOP,
    BOTTOM
  }


  private final Registrar registrar;
//  private final MethodChannel channel;

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_admob");
    channel.setMethodCallHandler(new FlutterAdmobPlugin(registrar, channel));
  }

  private FlutterAdmobPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
//    this.channel = channel;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if (call.method.equals("init")) {
      String appId = call.argument("app_id");
      MobileAds.initialize(this.registrar.activity(), appId);
      result.success(1);
    } else if (call.method.equals("show_banner")) {
      showBanner(call);
      result.success(1);
    } else if (call.method.equals(("show_interstitial"))) {
      showInterstitial(call);
      result.success(1);
    } else if (call.method.equals("show_rewardvideo")) {
      showRewardedVideo(call);
    } else {
      result.notImplemented();
    }
  }

  private void showInterstitial(MethodCall call) {
    String unitId = call.argument("unit_id");
    final InterstitialAd mInterstitialAd = new InterstitialAd(registrar.activity());
    mInterstitialAd.setAdUnitId(unitId);
    mInterstitialAd.loadAd(new AdRequest.Builder().build());
    mInterstitialAd.setAdListener(new AdListener() {
      @Override
      public void onAdLoaded() {
        mInterstitialAd.show();
      }
    });
  }

  private void showBanner(MethodCall call) {
    AdSize size = getAdSize((int)call.argument("size"));
    String unitId = call.argument("unit_id");
    Gravity gravity = getGravity((int)call.argument("gravity"));
    double anchorOffset = call.argument("anchor_offset");

    System.out.println(unitId);
    System.out.println(size);
    System.out.println(gravity);

    AdView adView = new AdView(registrar.activity());
    if (size != null) {
      adView.setAdSize(size);
    }
    adView.setAdUnitId(unitId);
    AdRequest adRequest = new AdRequest.Builder().build();
    adView.loadAd(adRequest);

    LinearLayout content = new LinearLayout(registrar.activity());
    content.setOrientation(LinearLayout.VERTICAL);
    if (gravity == Gravity.BOTTOM) {
      content.setGravity(android.view.Gravity.BOTTOM);
    } else {
      content.setGravity(android.view.Gravity.TOP);
    }
    content.addView(adView);
    final float scale =  registrar.activity().getResources().getDisplayMetrics().density;

    if (gravity == Gravity.BOTTOM) {
      content.setPadding(0, 0, 0, (int) (anchorOffset * scale));
    } else {
      content.setPadding(0, (int) (anchorOffset * scale), 0, 0);
    }
    registrar.activity().addContentView(
      content,
      new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
  }

  private void showRewardedVideo(MethodCall call) {
    String unitId = call.argument("unit_id");
    final RewardedVideoAd mRewardedVideoAd = MobileAds.getRewardedVideoAdInstance(registrar.activity());
    mRewardedVideoAd.loadAd(unitId,
            new AdRequest.Builder().build());
    mRewardedVideoAd.setRewardedVideoAdListener(new RewardedVideoAdListener() {
      @Override
      public void onRewardedVideoAdLoaded() {
        mRewardedVideoAd.show();
      }

      @Override
      public void onRewardedVideoAdOpened() {

      }

      @Override
      public void onRewardedVideoStarted() {

      }

      @Override
      public void onRewardedVideoAdClosed() {

      }

      @Override
      public void onRewarded(RewardItem rewardItem) {

      }

      @Override
      public void onRewardedVideoAdLeftApplication() {

      }

      @Override
      public void onRewardedVideoAdFailedToLoad(int i) {

      }

      @Override
      public void onRewardedVideoCompleted() {

      }
    });
  }

  private AdSize getAdSize(int size) {
    System.out.println(size);
    if (Size.BANNER.ordinal() == size) {
      return AdSize.BANNER;
    } else if (Size.FULL_BANNER.ordinal() == size) {
      return AdSize.FULL_BANNER;
    } else if (Size.LARGE_BANNER.ordinal() == size) {
      return  AdSize.LARGE_BANNER;
    } else if (Size.LEADER_BOARD.ordinal() == size) {
      return AdSize.LEADERBOARD;
    } else if (Size.MEDIUM_RECTANGLE.ordinal() == size) {
      return AdSize.MEDIUM_RECTANGLE;
    } else if (Size.SMART_BANNER.ordinal() == size) {
      return AdSize.SMART_BANNER;
    }
    return null;
  }

  private Gravity getGravity(int gravity) {
    System.out.println(gravity);
    if (Gravity.BOTTOM.ordinal() == gravity) {
      return Gravity.BOTTOM;
    }
    return Gravity.TOP;
  }
}
