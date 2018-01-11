
package com.reactlibrary;

import android.support.annotation.Nullable;
import android.util.Log;

import com.estimote.coresdk.common.config.EstimoteSDK;
import com.estimote.coresdk.common.requirements.SystemRequirementsChecker;
import com.estimote.coresdk.observation.region.beacon.BeaconRegion;
import com.estimote.coresdk.recognition.packets.Beacon;
import com.estimote.coresdk.recognition.packets.EstimoteTelemetry;
import com.estimote.coresdk.service.BeaconManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static com.estimote.coresdk.common.config.EstimoteSDK.getApplicationContext;


public class RNEstimoteWrapperModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  private static BeaconManager beaconManager;
  private BeaconRegion region;

  public RNEstimoteWrapperModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNEstimoteWrapper";
  }

  @ReactMethod
  public void startTelemetryListener(){

  }

  @ReactMethod
  public void startTelemetryListeningAndRanging(ReadableMap jsonRegion){

    region = new BeaconRegion("ranged region",
            UUID.fromString("B9407F30-F5F8-466E-AFF9-25556B57FE6D"), null, null);

    beaconManager.connect(new BeaconManager.ServiceReadyCallback() {
      @Override
      public void onServiceReady() {
        beaconManager.startTelemetryDiscovery();
        beaconManager.startRanging(region);
      }
    });
  }

  void telemetryCallback(List<EstimoteTelemetry> telemetries){
    for (EstimoteTelemetry tlm: telemetries) {
      Log.d("Estimote","beaconID: " + tlm.deviceId +
              ", temperature: " + tlm.temperature + " °C" + ", light: " + tlm.ambientLight + ", pressure: " + tlm.pressure);

      WritableMap wm = Arguments.createMap();
      wm.putString("shortId",tlm.deviceId.toString());
      wm.putDouble("temperature",tlm.temperature);
      wm.putDouble("light",tlm.ambientLight);
      wm.putDouble("battery",tlm.batteryPercentage);

      sendEvent("TELEMETRY_RECEIVED", wm);
    }
  }

  void rangingCallback(List<Beacon> beacons){
    WritableArray wa = Arguments.createArray();
    Log.d("Estimote","ranging beacons: " + beacons.size());
    for (Beacon beacon: beacons) {
      WritableMap wm = Arguments.createMap();
      wm.putString("uuid",beacon.getProximityUUID().toString());

      wa.pushMap(wm);

    }
    sendEvent("BEACON_DID_RANGE", wa);
  }

  @ReactMethod
  public void registerForTelemetryListener(String appId, String appToken){
    SystemRequirementsChecker.checkWithDefaultDialogs(getCurrentActivity());
    EstimoteSDK.initialize(reactContext, appId, appToken);

    beaconManager = new BeaconManager(reactContext);

    beaconManager.setTelemetryListener(new BeaconManager.TelemetryListener() {
      @Override
      public void onTelemetriesFound(List<EstimoteTelemetry> telemetries) {
        telemetryCallback(telemetries);
      }
    });

    beaconManager.setRangingListener(new BeaconManager.BeaconRangingListener() {
      @Override
      public void onBeaconsDiscovered(BeaconRegion beaconRegion, List<Beacon> beacons) {
        rangingCallback(beacons);
      }
    });
  }

  private void sendEvent(String eventName, @Nullable WritableMap params) {
    getReactApplicationContext()
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
  }

  private void sendEvent(String eventName, @Nullable WritableArray params) {
    getReactApplicationContext()
            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
            .emit(eventName, params);
  }
}