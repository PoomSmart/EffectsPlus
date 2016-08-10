#define KILL_PROCESS
#import "../Common.h"
#import "../EffectsFunctions.h"
#import "../Prefs.h"
#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Social/Social.h>
#import <Cephei/HBAppearanceSettings.h>
#import <Cephei/HBListController.h>
#import "../../PSPrefs.x"

#import <dlfcn.h>
#include <objc/runtime.h>
#include <sys/sysctl.h>

DeclarePrefsTools()

UIColor *fitColor = UIColor.systemBlueColor;
NSString *updateFooterNotification = @"com.PS.EffectsPlus.prefs.footerUpdate";

static NSArray <UIColor *> *colors = [@[UIColor.systemRedColor, UIColor.systemGreenColor, UIColor.systemBlueColor] retain];
#define targetColor colors[arc4random() % 3].copy

@interface PSViewController (EffectsPlus)
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface EffectsPlusFiltersSelectionController : PSViewController
@end

@interface EffectsPlusFiltersSelectionController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	NSMutableOrderedSet *_enabledEffects;
	NSMutableOrderedSet *_disabledEffects;
}
@end

static NSBundle *epBundle()
{
	return [NSBundle bundleWithPath:@"/Library/PreferenceBundles/EffectsPlusPref.bundle"];
}

@implementation EffectsPlusFiltersSelectionController

- (NSString *)title
{
	return @"Select Filters";
}

- (UITableView *)tableView
{
    return (UITableView *)self.view;
}

- (NSArray *)arrayByAddingDefaults
{
	return @[@"CIPhotoEffectMono", @"CIPhotoEffectTonal", @"CIPhotoEffectNoir", @"CIPhotoEffectFade", CINoneName,
							@"CIPhotoEffectChrome", @"CIPhotoEffectProcess", @"CIPhotoEffectTransfer", @"CIPhotoEffectInstant"];
}

- (NSArray *)arrayByAddingPhotoBooths
{
	return @[@"CIThermal", @"CIMirror", @"CIXRay", @"CITriangleKaleidoscope", @"CILightTunnel", @"CIPinchDistortion",
							@"CITwirlDistortion", @"CIStretch"];
}

- (NSArray *)arrayByAddingPhotoBoothsStock
{
	NSMutableArray *array = [[self arrayByAddingPhotoBooths] mutableCopy];
	[array insertObject:CINoneName atIndex:4];
	NSArray *_array = array.copy;
	[array release];
	return _array;
}

- (NSArray *)arrayByAddingExternal1
{
	return @[@"CISepiaTone", @"CIVibrance", @"CIColorMonochrome", @"CIColorPosterize", @"CIGloom", @"CIBloom",
							@"CISharpenLuminance", @"CILinearToSRGBToneCurve", @"CIPixellate"];
}

- (NSArray *)arrayByAddingExternal2
{
	return @[@"CIGaussianBlur", @"CIFalseColor", @"CIWrapMirror", @"CIColorInvert", @"CIHoleDistortion",
							@"CICircleSplashDistortion", @"CICircularScreen", @"CILineScreen"];
}

- (NSMutableArray *)arrayByAddingExtras
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObjectsFromArray:[self arrayByAddingExternal1]];
	[array addObjectsFromArray:[self arrayByAddingExternal2]];
	[array addObjectsFromArray:[self arrayByAddingPhotoBooths]];
	return array;
}

- (void)toggleFiltersArray
{
	UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
		@"Default",
		@"Enable All",
		@"Disable All",
		@"Photo Booth",
		@"Extra Set #1",
		@"Extra Set #2",
		@"All Extra Enabled",
		nil];
	sheet.tag = 9596;
	[sheet showInView:self.view];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (popup.tag == 9596) {
		switch (buttonIndex) {
			case 0:
				_enabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingDefaults]] retain];
				_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExtras]] retain];
				break;
			case 1:
				[_enabledEffects addObjectsFromArray:_disabledEffects.array];
				_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]] retain];
				break;
			case 2:
				[_disabledEffects addObjectsFromArray:_enabledEffects.array];
				_enabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]] retain];
				break;
			case 3:
			{
				_enabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingPhotoBoothsStock]] retain];
				NSMutableArray *array3 = [NSMutableArray array];
				[array3 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array3 removeObject:CINoneName];
				[array3 addObjectsFromArray:[self arrayByAddingExternal1]];
				[array3 addObjectsFromArray:[self arrayByAddingExternal2]];
				_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:array3] retain];
				break;
			}
			case 4:
			{
				_enabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExternal1]] retain];
				NSMutableArray *array4 = [NSMutableArray array];
				[array4 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array4 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				[array4 addObjectsFromArray:[self arrayByAddingExternal2]];
				_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:array4] retain];
				break;
			}
			case 5:
			{
				_enabledEffects = [[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExternal2]] retain];
				NSMutableArray *array5 = [NSMutableArray array];
				[array5 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array5 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				[array5 addObjectsFromArray:[self arrayByAddingExternal1]];
				_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:array5] retain];
				break;
			}
			case 6:
			{
				NSMutableArray *array6 = [NSMutableArray array];
				[array6 addObjectsFromArray:[self arrayByAddingExternal1]];
				[array6 addObjectsFromArray:[self arrayByAddingExternal2]];
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:array6];
				NSMutableArray *array7 = [NSMutableArray array];
				[array7 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array7 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:array7] retain];
				break;
			}
		}
		[self saveSettings];
		[self.tableView reloadData];
		killProcess("Camera");
		killProcess("MobileSlideShow");
	} else
		[super actionSheet:popup clickedButtonAtIndex:buttonIndex];
}

- (void)setReorderColor:(UIColor *)color forCell:(UITableViewCell *)cell
{
	for (UIView *view in cell.subviews) {
		if (isiOS8Up) {
			if ([[[view class] description] isEqualToString:@"UITableViewCellReorderControl"]) {
				for (UIImageView *reorderIcon in view.subviews) {
					UIImage *defaultIcon = reorderIcon.image;
					reorderIcon.image = [defaultIcon _flatImageWithColor:color];
					return;
				}
			}
		}
		else {
			if ([[[view class] description] isEqualToString:@"UITableViewCellScrollView"]) {
				for (UIView *reorderControl in view.subviews) {
					if ([[[reorderControl class] description] isEqualToString:@"UITableViewCellReorderControl"]) {
						for (UIImageView *reorderIcon in reorderControl.subviews) {
							UIImage *defaultIcon = reorderIcon.image;
							reorderIcon.image = [defaultIcon _flatImageWithColor:color];
							return;
						}
					}
				}
			}
		}
	}
}

- (UIColor *)reorderColorForCell:(UITableViewCell *)cell
{
	NSString *identifier = cell.reuseIdentifier;
	NSMutableArray *defaults = [[self arrayByAddingDefaults] mutableCopy];
	[defaults removeObject:CINoneName];
	NSArray *_defaults = defaults.copy;
	[defaults release];
	if ([_defaults containsObject:identifier])
		return [UIColor systemBlueColor];
	if ([[self arrayByAddingPhotoBooths] containsObject:identifier])
		return [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
	return UIColor.blackColor;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self setReorderColor:[self reorderColorForCell:cell] forCell:cell];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.allowsSelectionDuringEditing = YES;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EffectCell"];
	self.tableView.editing = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return section == 0 ? _enabledEffects.count : _disabledEffects.count;
}

- (BOOL)tableView:(UITableView *)view shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)view shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case 0: return [NSString stringWithFormat:@"Enabled Filters (%lu)", (unsigned long)_enabledEffects.count];
		case 1: return [NSString stringWithFormat:@"Disabled Filters (%lu)", (unsigned long)_disabledEffects.count];
	}
	return nil;
}

- (void)saveSettings
{
	setValueForKey(_enabledEffects.array, ENABLED_EFFECT, NO);
	setValueForKey(_disabledEffects.array, DISABLED_EFFECT, NO);
	DoPostNotification();
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	if (fromIndexPath.row == toIndexPath.row && fromIndexPath.section == toIndexPath.section)
		return;
	if (fromIndexPath.section == 0 && toIndexPath.section == 0) {
		NSObject *o = [_enabledEffects[fromIndexPath.row] retain];
    	[_enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_enabledEffects insertObject:o atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 1) {
		NSObject *o = [_disabledEffects[fromIndexPath.row] retain];
    	[_disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_disabledEffects insertObject:o atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 0 && toIndexPath.section == 1) {
		NSObject *o = [_enabledEffects[fromIndexPath.row] retain];
    	[_enabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_disabledEffects insertObject:o atIndex:toIndexPath.row];
    }
    else if (fromIndexPath.section == 1 && toIndexPath.section == 0) {
		NSObject *o = [_disabledEffects[fromIndexPath.row] retain];
    	[_disabledEffects removeObjectAtIndex:fromIndexPath.row];
    	[_enabledEffects insertObject:o atIndex:toIndexPath.row];
    }
	[self saveSettings];
}

- (void)updateSectionsTitle
{
	[self.tableView headerViewForSection:0].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:0];
	[self.tableView headerViewForSection:1].textLabel.text = [self tableView:self.tableView titleForHeaderInSection:1];
}

- (void)tableView:(UITableView *)tableView didEndReorderingRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self updateFilterNameColor];
	[self updateSectionsTitle];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (instancetype)init
{
	if (self == [super init]) {
		UIBarButtonItem *toggleBtn = [[UIBarButtonItem alloc]
        	initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered
        	target:self action:@selector(toggleFiltersArray)];
			((UINavigationItem *)[super navigationItem]).rightBarButtonItem = toggleBtn;
		NSArray *_enabledArray = valueForKey(ENABLED_EFFECT, [self arrayByAddingDefaults]);
		_enabledEffects = [[NSMutableOrderedSet orderedSetWithArray:_enabledArray] retain];
		NSArray *_disabledArray = valueForKey(DISABLED_EFFECT, [self arrayByAddingExtras]);
		_disabledEffects = [[NSMutableOrderedSet orderedSetWithArray:_disabledArray] retain];
		[self saveSettings];
		[self.tableView reloadData];
	}
	return self;
}

- (void)loadView
{
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	tableView.dataSource = self;
	tableView.delegate = self;
	tableView.autoresizingMask = 1;
	self.view = tableView;
}

static BOOL filterFit(NSUInteger filterCount)
{
	NSUInteger cellPerRow = (NSUInteger)sqrt(filterCount);
	return cellPerRow*cellPerRow == filterCount;
}

- (void)updateFilterNameColor
{
	NSMutableArray *enabledIndexArray = [NSMutableArray array];
	NSUInteger enabledIndexCount = [self.tableView numberOfRowsInSection:0];
	for (NSUInteger i = 0; i < enabledIndexCount; i++) {
		NSIndexPath *enabledIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
		[enabledIndexArray addObject:enabledIndexPath];
		UITableViewCell *enabledCell = [self.tableView cellForRowAtIndexPath:enabledIndexPath];
		enabledCell.textLabel.textColor = filterFit(enabledIndexCount) ? fitColor : UIColor.blackColor;
		if (isiOS8Up) {
			BOOL modern = !boolForKey(useOldEditorKey, NO);
			if (modern) {
				NSString *effectName = _enabledEffects[i];
				BOOL isCINone = [effectName isEqualToString:CINoneName];
				if ([effectsThatNotSupportedModernEditor() containsObject:effectName] && !isCINone)
					enabledCell.textLabel.textColor = UIColor.systemRedColor;
			}
		}
	}
	NSMutableArray *disabledIndexArray = [NSMutableArray array];
	NSUInteger disabledIndexCount =  [self.tableView numberOfRowsInSection:1];
	for (NSUInteger i = 0; i < disabledIndexCount; i++) {
		NSIndexPath *disabledIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
		[disabledIndexArray addObject:disabledIndexPath];
		UITableViewCell *disabledCell = [self.tableView cellForRowAtIndexPath:disabledIndexPath];
		disabledCell.textLabel.textColor = UIColor.blackColor;
	}
}

- (NSString *)bundlePath
{
	if (isiOS9Up)
		return @"/System/Library/PrivateFrameworks/CameraUI.framework";
	if (isiOS8)
		return @"/System/Library/PrivateFrameworks/CameraKit.framework";
	return @"/System/Library/PrivateFrameworks/PhotoLibrary.framework";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	BOOL index0 = indexPath.section == 0;
	static NSString *CellIdentifier = index0 ? _enabledEffects.array[indexPath.row] : _disabledEffects.array[indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UIColor *stockColor = [UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1];
	UIColor *pbColor = [UIColor colorWithRed:1 green:0.8 blue:0.8 alpha:1];
	NSArray *pbArray = [self arrayByAddingPhotoBooths];
	NSBundle *plBundle = [NSBundle bundleWithPath:self.bundlePath];
	UIImage *FilterOn = [UIImage imageNamed:@"CAMFilterButtonOn" inBundle:plBundle];
	UIImage *Filter = [UIImage imageNamed:@"CAMFilterButton" inBundle:plBundle];
	UIImage *PB = [UIImage imageNamed:@"PB" inBundle:epBundle()];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.numberOfLines = 1;
		cell.textLabel.backgroundColor = UIColor.clearColor;
		cell.textLabel.textColor = UIColor.blackColor;
	}

	NSMutableOrderedSet *effectDict = index0 ? _enabledEffects : _disabledEffects;
	NSUInteger filterCount = effectDict.count;
	cell.textLabel.textColor = filterFit(_enabledEffects.count) && index0 ? fitColor : UIColor.blackColor;
	if (filterCount - 1 >= indexPath.row) {
		NSString *effectName = effectDict[indexPath.row];
		BOOL isCINone = [effectName isEqualToString:CINoneName];
		if (isiOS8) {
			BOOL modern = !boolForKey(useOldEditorKey, NO);
			if ([effectsThatNotSupportedModernEditor() containsObject:effectName] && modern && !isCINone) {
				if (index0)
					cell.textLabel.textColor = UIColor.systemRedColor;
			}
		}
		cell.textLabel.text = displayNameFromCIFilterName(effectName);
		if ([effectName hasPrefix:@"CIPhotoEffect"]) {
			cell.backgroundColor = stockColor;
			cell.imageView.image = FilterOn;
		} else {
			BOOL pb = [pbArray containsObject:effectName] && !isCINone;
			if (pb) {
				cell.imageView.image = PB;
				cell.backgroundColor = pbColor;
			} else {
				cell.imageView.image = Filter;
				cell.backgroundColor = UIColor.clearColor;
			}
		}
	}
    return cell;
}

@end

@interface EffectsPlusFiltersSettingsController : HBListController
@end

@implementation EffectsPlusFiltersSettingsController

HavePrefs()

+ (nullable NSString *)hb_specifierPlist
{
	return @"FiltersSettings";
}

- (void)setInput:(id)value forSpecifier:(PSSpecifier *)spec
{
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	if ([formatter numberFromString:(NSString *)value] != nil) {
		float floatValue = [value floatValue];
		if (floatValue < 0)
			value = @0;
	} else
		value = @0;
	[formatter release];
	[self setPreferenceValue:value specifier:spec];
	[self reloadSpecifier:spec animated:NO];
}

- (id)init
{
	if (self == [super init]) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = targetColor;
		appearanceSettings.tableViewCellTextColor = targetColor;
		appearanceSettings.invertedNavigationBar = YES;
		self.hb_appearanceSettings = appearanceSettings;
	}
	return self;
}

@end

@interface EffectsPlusPrefController : HBListController
@property (nonatomic, retain) PSSpecifier *oldEditorSpec;
@property (nonatomic, retain) PSSpecifier *asSpec;
@property (nonatomic, retain) PSSpecifier *footerSpec;
@end

@implementation EffectsPlusPrefController

HavePrefs()

- (void)masterSwitch:(id)value specifier:(PSSpecifier *)spec
{
	[self setPreferenceValue:value specifier:spec];
	killProcess("Camera");
	killProcess("MobileSlideShow");
}

HaveBanner2(tweakName, targetColor, @"Beautify your photos", targetColor)

- (void)reloadAS:(id)param
{
	system("launchctl kickstart -k system/com.apple.assetsd");
}

- (void)love
{
	SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
	twitter.initialText = @"#EffectsPlus by @PoomSmart is really awesome!";
	[self.navigationController presentViewController:twitter animated:YES completion:nil];
	[twitter release];
}

- (id)init
{
	if (self == [super init]) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = targetColor;
		appearanceSettings.tableViewCellTextColor = targetColor;
		appearanceSettings.invertedNavigationBar = YES;
		self.hb_appearanceSettings = appearanceSettings;
		UIButton *heart = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
		[heart setImage:[[UIImage imageNamed:@"Heart" inBundle:epBundle()] _flatImageWithColor:UIColor.whiteColor] forState:UIControlStateNormal];
		[heart sizeToFit];
		[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:heart] autorelease];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateFooter:) name:updateFooterNotification object:nil];
	}
	return self;
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"EffectsPlusPref" target:self]] retain];	
		
		for (PSSpecifier *spec in specs) {
			NSString *Id = [spec properties][@"id"];
			if ([Id isEqualToString:@"footer"])
				self.footerSpec = spec;
			else if ([Id isEqualToString:@"oldEditor"])
				self.oldEditorSpec = spec;
			else if ([Id isEqualToString:@"as"])
				self.asSpec = spec;
		}
		[self updateFooter:nil];	
		if (!isiOS8)
			[specs removeObject:self.oldEditorSpec];
		if (!isiOS8Up)
			[specs removeObject:self.asSpec];
		_specifiers = specs.copy;
  	}
	return _specifiers;
}

- (NSString *)footerText
{
	int mode = intForKey(saveModeKey, 1);
	switch (mode) {
		case 1:
			return @"Prompt saving options (#1, #2, and #3) when user taps at Save button.";
		case 2:
			return @"Save using system default method without prompt.";
		case 3:
			return @"Save as a new image without prompt. (Not keep photo adjustments)";
		case 4:
			return @"Save as a new image without prompt. (Keep photo adjustments)";
	}
	return nil;
}

- (void)updateFooter:(NSNotification *)notification
{
	[self.footerSpec setProperty:[self footerText] forKey:@"footerText"];
	[self reloadSpecifier:self.footerSpec animated:YES];
}

@end

@interface EPSaveOptionCell : PSTableCell
@end

@implementation EPSaveOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier
{
	if (self == [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier]) {
		UISegmentedControl *modes = [[[UISegmentedControl alloc] initWithItems:@[@"❗ ", @"#1", @"#2", @"#3"]] autorelease];
		modes.tintColor = targetColor;
		[modes addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventValueChanged];
		modes.selectedSegmentIndex = intForKey(saveModeKey, 1) - 1;
		self.accessoryView = modes;
	}
	return self;
}

- (void)modeAction:(UISegmentedControl *)segment
{
	setIntForKey(segment.selectedSegmentIndex + 1, saveModeKey);
	DoPostNotification();
	[NSNotificationCenter.defaultCenter postNotificationName:updateFooterNotification object:nil userInfo:nil];
}

- (SEL)action
{
	return nil;
}

- (id)target
{
	return nil;
}

- (SEL)cellAction
{
	return nil;
}

- (id)cellTarget
{
	return nil;
}

- (void)dealloc
{
	[super dealloc];
}

@end

__attribute__((constructor)) static void ctor()
{
	if (isiOS9Up)
		openCamera9();
}