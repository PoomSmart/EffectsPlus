#import <Foundation/Foundation.h>

NSString *EnabledKey = @"Enabled";
NSString *FillGridKey = @"FillGrid";
NSString *AutoHideBBKey = @"AutoHideBB";
NSString *useOldEditorKey = @"useOldEditor";
NSString *qualityFactorKey = @"qualityFactor";
NSString *saveModeKey = @"saveMode";
NSString *ENABLED_EFFECT = @"EnabledEffects";
NSString *DISABLED_EFFECT = @"DisabledEffects";

#define abc(key) \
	NSString * (key ## Key) = (@ #key);
	
abc(CIColorMonochrome_R)
abc(CIColorMonochrome_G)
abc(CIColorMonochrome_B)
abc(CIFalseColor_R1)
abc(CIFalseColor_G1)
abc(CIFalseColor_B1)
abc(CIFalseColor_R2)
abc(CIFalseColor_G2)
abc(CIFalseColor_B2)
abc(CISepiaTone_inputIntensity)
abc(CIVibrance_inputAmount)
abc(CIColorMonochrome_inputIntensity)
abc(CIColorPosterize_inputLevels)
abc(CIGloom_inputRadius)
abc(CIGloom_inputIntensity)
abc(CIBloom_inputRadius)
abc(CIBloom_inputIntensity)
abc(CISharpenLuminance_inputSharpness)
abc(CIPixellate_inputScale)
abc(CIGaussianBlur_inputRadius)
abc(CITwirlDistortion_inputRadius)
abc(CITwirlDistortion_inputAngle)
abc(CITriangleKaleidoscope_inputSize)
abc(CITriangleKaleidoscope_inputDecay)
abc(CIPinchDistortion_inputRadius)
abc(CIPinchDistortion_inputScale)
abc(CILightTunnel_inputRadius)
abc(CILightTunnel_inputRotation)
abc(CIHoleDistortion_inputRadius)
abc(CICircleSplashDistortion_inputRadius)
abc(CICircularScreen_inputWidth)
abc(CICircularScreen_inputSharpness)
abc(CILineScreen_inputAngle)
abc(CILineScreen_inputWidth)
abc(CILineScreen_inputSharpness)
abc(CIMirror_inputAngle)