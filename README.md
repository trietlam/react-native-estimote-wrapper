
# react-native-estimote-wrapper

## Getting started

`$ npm install react-native-estimote-wrapper --save`

### Mostly automatic installation

`$ react-native link react-native-estimote-wrapper`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-estimote-wrapper` and add `RNEstimoteWrapper.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNEstimoteWrapper.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
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
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNEstimoteWrapper.sln` in `node_modules/react-native-estimote-wrapper/windows/RNEstimoteWrapper.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Estimote.Wrapper.RNEstimoteWrapper;` to the usings at the top of the file
  - Add `new RNEstimoteWrapperPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNEstimoteWrapper from 'react-native-estimote-wrapper';

// TODO: What to do with the module?
RNEstimoteWrapper;
```
  