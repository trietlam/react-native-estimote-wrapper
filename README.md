
# react-native-estimote-wrapper

## Getting started

`$ npm install react-native-estimote-wrapper --save`

### Manual installation

#### iOS
1. Naviage to ios folder and add podfile 
`pod 'CocoaMQTT', '~>1.0.11'`
1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-estimote-wrapper` and add `RNEstimoteWrapper.xcodeproj`
3. In XCode, in the project navigator, select your root project. Add `libRNEstimoteWrapper.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Build (`Cmd+B`) or Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainApplication.java`
  - Add `import com.reactlibrary.RNEstimoteWrapperPackage;` to the imports at the top of the file
  - Add `new RNEstimoteWrapperPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-estimote-wrapper'
  	project(':react-native-estimote-wrapper').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-estimote-wrapper/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-estimote-wrapper')
  	```

#### Windows
[Not supported :D](https://github.com/ReactWindows/react-native)

## Usage
```javascript
import RNEstimoteWrapper from 'react-native-estimote-wrapper';

// TODO: What to do with the module?
RNEstimoteWrapper;
```
  