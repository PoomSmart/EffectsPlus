#import "../Common.h"

static BOOL internalBlurHook = NO;
static BOOL globalFilterHook = NO;

static BOOL TweakEnabled;
static BOOL FillGrid;
static BOOL AutoHideBB;
static BOOL oldEditor;

static CGFloat CISepiaTone_inputIntensity;
static CGFloat CIVibrance_inputAmount;
static CGFloat CIColorMonochrome_inputIntensity;
static CGFloat CIColorMonochrome_R, CIColorMonochrome_G, CIColorMonochrome_B;
static CGFloat CIColorPosterize_inputLevels;
static CGFloat CIGloom_inputRadius, CIGloom_inputIntensity;
static CGFloat CIBloom_inputRadius, CIBloom_inputIntensity;
static CGFloat CISharpenLuminance_inputSharpness;
static CGFloat CIPixellate_inputScale;
static CGFloat CIGaussianBlur_inputRadius;
static CGFloat CIFalseColor_R1, CIFalseColor_G1, CIFalseColor_B1;
static CGFloat CIFalseColor_R2, CIFalseColor_G2, CIFalseColor_B2;
static CGFloat CITwirlDistortion_inputRadius, CITwirlDistortion_inputAngle;
static CGFloat CITriangleKaleidoscope_inputSize, CITriangleKaleidoscope_inputDecay;
static CGFloat CIPinchDistortion_inputRadius, CIPinchDistortion_inputScale;
static CGFloat CILightTunnel_inputRadius, CILightTunnel_inputRotation;
static CGFloat CIHoleDistortion_inputRadius;
static CGFloat CICircleSplashDistortion_inputRadius;
static CGFloat CICircularScreen_inputWidth, CICircularScreen_inputSharpness;
static CGFloat CILineScreen_inputAngle, CILineScreen_inputWidth, CILineScreen_inputSharpness;
static CGFloat CIMirror_inputAngle;