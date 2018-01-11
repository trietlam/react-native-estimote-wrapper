
# react-native-estimote-wrapper

## Getting started

`$ npm install react-native-estimote-wrapper --save`

### Manual installation

#### iOS
1. Naviage to ios folder, add podfile and install pod
	`pod 'EstimoteSDK','~>4.26.3'`
2. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
3. Go to `node_modules` ➜ `react-native-estimote-wrapper` and add `RNEstimoteWrapper.xcodeproj`
4. In XCode, in the project navigator, select your root project. Add `libRNEstimoteWrapper.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
5. Build (`Cmd+B`) or Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.reactlibrary.RNEstimoteWrapperPackage;` to the imports at the top of the file
  - Add `new RNEstimoteWrapperPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-estimote-wrapper'
  	project(':react-native-estimote-wrapper').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-estimote-wrapper/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-estimote-wrapper')
  	```

#### Windows
[Not supported :D](https://github.com/ReactWindows/react-native)

## Usage
```javascript
import { NativeEventEmitter, Platform } from 'react-native';
import RNBeaconManager from 'react-native-estimote-wrapper';

const RNBeaconEmitter = new NativeEventEmitter(RNEstimoteBeaconManager);

// TODO: What to do with the module?
RNBeaconManager;
```
  