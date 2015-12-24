#import "../Common.h"
#import "../EffectsFunctions.h"
#import "../Prefs.h"
#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Social/Social.h>

#include <objc/runtime.h>
#include <sys/sysctl.h>

UIColor *fitColor = [UIColor systemBlueColor];
NSString *updateFooterNotification = @"com.PS.EffectsPlus.prefs.footerUpdate";

@interface PSViewController (EffectsPlus)
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex;
@end

@interface EffectsPlusFiltersSelectionController : PSViewController
- (UITableView *)tableView;
@end

@interface EffectsPlusFiltersSelectionController () <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	NSMutableOrderedSet *_enabledEffects;
	NSMutableOrderedSet *_disabledEffects;
}
@end

static BOOL boolValueForKey(NSString *key, BOOL defaultValue)
{
	NSDictionary *pref = prefDict();
	return pref[key] ? [pref[key] boolValue] : defaultValue;
}

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

- (NSMutableArray *)arrayByAddingDefaults
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CIPhotoEffectMono"]; [array addObject:@"CIPhotoEffectTonal"];
	[array addObject:@"CIPhotoEffectNoir"]; [array addObject:@"CIPhotoEffectFade"];
	[array addObject:CINoneName];
	[array addObject:@"CIPhotoEffectChrome"]; [array addObject:@"CIPhotoEffectProcess"];
	[array addObject:@"CIPhotoEffectTransfer"];	[array addObject:@"CIPhotoEffectInstant"];
	return array;
}

- (NSMutableArray *)arrayByAddingPhotoBooths
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CIThermal"]; [array addObject:@"CIMirror"];
	[array addObject:@"CIXRay"]; [array addObject:@"CITriangleKaleidoscope"];
	[array addObject:@"CILightTunnel"]; [array addObject:@"CIPinchDistortion"];
	[array addObject:@"CITwirlDistortion"];	[array addObject:@"CIStretch"];
	return array;
}

- (NSMutableArray *)arrayByAddingPhotoBoothsStock
{
	NSMutableArray *array = [self arrayByAddingPhotoBooths];
	[array insertObject:CINoneName atIndex:4];
	return array;
}

- (NSMutableArray *)arrayByAddingExternal1
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CISepiaTone"]; [array addObject:@"CIVibrance"];
	[array addObject:@"CIColorMonochrome"]; [array addObject:@"CIColorPosterize"];
	[array addObject:@"CIGloom"]; [array addObject:@"CIBloom"];
	[array addObject:@"CISharpenLuminance"]; [array addObject:@"CILinearToSRGBToneCurve"];
	[array addObject:@"CIPixellate"];
	return array;
}

- (NSMutableArray *)arrayByAddingExternal2
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CIGaussianBlur"]; [array addObject:@"CIFalseColor"];
	[array addObject:@"CIWrapMirror"]; [array addObject:@"CIColorInvert"];
	[array addObject:@"CIHoleDistortion"]; [array addObject:@"CICircleSplashDistortion"];
	[array addObject:@"CICircularScreen"]; [array addObject:@"CILineScreen"];
	return array;
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
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingDefaults]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExtras]];
				break;
			case 1:
				[_enabledEffects addObjectsFromArray:_disabledEffects.array];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]];
				break;
			case 2:
				[_disabledEffects addObjectsFromArray:_enabledEffects.array];
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]];
				break;
			case 3:
			{
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingPhotoBoothsStock]];
				NSMutableArray *array3 = [NSMutableArray array];
				[array3 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array3 removeObject:CINoneName];
				[array3 addObjectsFromArray:[self arrayByAddingExternal1]];
				[array3 addObjectsFromArray:[self arrayByAddingExternal2]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array3];
				break;
			}
			case 4:
			{
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExternal1]];
				NSMutableArray *array4 = [NSMutableArray array];
				[array4 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array4 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				[array4 addObjectsFromArray:[self arrayByAddingExternal2]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array4];
				break;
			}
			case 5:
			{
				_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExternal2]];
				NSMutableArray *array5 = [NSMutableArray array];
				[array5 addObjectsFromArray:[self arrayByAddingDefaults]];
				[array5 addObjectsFromArray:[self arrayByAddingPhotoBooths]];
				[array5 addObjectsFromArray:[self arrayByAddingExternal1]];
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array5];
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
				_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:array7];
				break;
			}
		}
		[self saveSettings];
		[[NSUserDefaults standardUserDefaults] synchronize];
		[self.tableView reloadData];
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
	NSMutableArray *defaults = [self arrayByAddingDefaults];
	[defaults removeObject:CINoneName];
	if ([defaults containsObject:identifier])
		return [UIColor systemBlueColor];
	if ([[self arrayByAddingPhotoBooths] containsObject:identifier])
		return [UIColor colorWithRed:1 green:0.5 blue:0.5 alpha:1];
	return [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self setReorderColor:[self reorderColorForCell:cell] forCell:cell];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.tableView setAllowsSelectionDuringEditing:YES];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"EffectCell"];
	[self.tableView setEditing:YES];
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
	NSMutableDictionary *prefDict = [NSMutableDictionary dictionary];
	[prefDict addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREF_PATH]];
	prefDict[ENABLED_EFFECT] = _enabledEffects.array;
	prefDict[DISABLED_EFFECT] = _disabledEffects.array;
	[prefDict.copy writeToFile:PREF_PATH atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), PreferencesChangedNotification, NULL, NULL, YES);
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
	self = [super init];
	if (self) {
		UIBarButtonItem *toggleBtn = [[UIBarButtonItem alloc]
        	initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered
        	target:self action:@selector(toggleFiltersArray)];
			((UINavigationItem *)[super navigationItem]).rightBarButtonItem = toggleBtn;
		
		NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
		
		_enabledEffects = prefDict[ENABLED_EFFECT] != nil ?
							[NSMutableOrderedSet orderedSetWithArray:prefDict[ENABLED_EFFECT]] :
							[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingDefaults]];
		_disabledEffects = prefDict[DISABLED_EFFECT] != nil ?
							[NSMutableOrderedSet orderedSetWithArray:prefDict[DISABLED_EFFECT]] :
							[NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExtras]];

		[self saveSettings];
		[[NSUserDefaults standardUserDefaults] synchronize];
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
		enabledCell.textLabel.textColor = filterFit(enabledIndexCount) ? fitColor : [UIColor blackColor];
		if (isiOS8Up) {
			BOOL modern = !boolValueForKey(@"useOldEditor", NO);
			if (modern) {
				NSString *effectName = _enabledEffects[i];
				BOOL isCINone = [effectName isEqualToString:CINoneName];
				if ([effectsThatNotSupportedModernEditor() containsObject:effectName] && !isCINone)
					enabledCell.textLabel.textColor = [UIColor systemRedColor];
			}
		}
	}
	NSMutableArray *disabledIndexArray = [NSMutableArray array];
	NSUInteger disabledIndexCount =  [self.tableView numberOfRowsInSection:1];
	for (NSUInteger i = 0; i < disabledIndexCount; i++) {
		NSIndexPath *disabledIndexPath = [NSIndexPath indexPathForRow:i inSection:1];
		[disabledIndexArray addObject:disabledIndexPath];
		UITableViewCell *disabledCell = [self.tableView cellForRowAtIndexPath:disabledIndexPath];
		disabledCell.textLabel.textColor = [UIColor blackColor];
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
	NSString *CellIdentifier = index0 ? _enabledEffects.array[indexPath.row] : _disabledEffects.array[indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UIColor *stockColor = [UIColor colorWithRed:0.8 green:0.9 blue:0.9 alpha:1];
	UIColor *pbColor = [UIColor colorWithRed:1 green:0.8 blue:0.8 alpha:1];
	NSArray *pbArray = [self arrayByAddingPhotoBooths];
	NSBundle *plBundle = [NSBundle bundleWithPath:self.bundlePath];
	UIImage *FilterOn = [UIImage imageNamed:@"CAMFilterButtonOn" inBundle:plBundle];
	UIImage *Filter = [UIImage imageNamed:@"CAMFilterButton" inBundle:plBundle];
	UIImage *PB = [UIImage imageNamed:@"PB" inBundle:epBundle()];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.numberOfLines = 1;
		cell.textLabel.backgroundColor = [UIColor clearColor];
		cell.textLabel.textColor = [UIColor blackColor];
	}

	NSMutableOrderedSet *effectDict = index0 ? _enabledEffects : _disabledEffects;
	NSUInteger filterCount = effectDict.count;
	cell.textLabel.textColor = filterFit(_enabledEffects.count) && index0 ? fitColor : [UIColor blackColor];
	if (filterCount - 1 >= indexPath.row) {
		NSString *effectName = effectDict[indexPath.row];
		BOOL isCINone = [effectName isEqualToString:CINoneName];
		if (isiOS8Up) {
			BOOL modern = !boolValueForKey(@"useOldEditor", NO);
			if ([effectsThatNotSupportedModernEditor() containsObject:effectName] && modern && !isCINone) {
				if (index0)
					cell.textLabel.textColor = [UIColor systemRedColor];
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
				cell.backgroundColor = [UIColor clearColor];
			}
		}
	}
    return cell;
}

@end

@interface EffectsPlusFiltersSettingsController : PSListController
@end

@implementation EffectsPlusFiltersSettingsController

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
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self reloadSpecifier:spec animated:NO];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	if (!settings[specifier.properties[@"key"]])
		return specifier.properties[@"default"];
	return settings[specifier.properties[@"key"]];
}
 
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREF_PATH]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:PREF_PATH atomically:YES];
	CFStringRef post = (CFStringRef)specifier.properties[@"PostNotification"];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"FiltersSettings" target:self]] retain];			
		_specifiers = [specs copy];
  	}
	return _specifiers;
}

@end

@interface EffectsPlusPrefController : PSListController
@property (nonatomic, retain) PSSpecifier *oldEditorSpec;
@property (nonatomic, retain) PSSpecifier *asSpec;
@property (nonatomic, retain) PSSpecifier *footerSpec;
@end

@implementation EffectsPlusPrefController

- (void)donate:(id)param
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:PS_DONATE_URL]];
}

- (void)twitter:(id)param
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:PS_TWITTER_URL]];
}

- (void)reloadAS:(id)param
{
	system("launchctl kickstart -k system/com.apple.assetsd");
}

- (void)love
{
	SLComposeViewController *twitter = [[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter] retain];
	[twitter setInitialText:@"#EffectsPlus by @PoomSmart is awesome!"];
	if (twitter != nil)
		[[self navigationController] presentViewController:twitter animated:YES completion:nil];
	[twitter release];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	if (!settings[specifier.properties[@"key"]])
		return specifier.properties[@"default"];
	return settings[specifier.properties[@"key"]];
}
 
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PREF_PATH]];
	[defaults setObject:value forKey:specifier.properties[@"key"]];
	[defaults writeToFile:PREF_PATH atomically:YES];
	CFStringRef post = (CFStringRef)specifier.properties[@"PostNotification"];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), post, NULL, NULL, YES);
}

- (id)init
{
	if (self == [super init]) {
		UIButton *heart = [[[UIButton alloc] initWithFrame:CGRectZero] autorelease];
		[heart setImage:[UIImage imageNamed:@"Heart" inBundle:epBundle()] forState:UIControlStateNormal];
		[heart sizeToFit];
		[heart addTarget:self action:@selector(love) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:heart] autorelease];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFooter:) name:updateFooterNotification object:nil];
	}
	return self;
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [[NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"EffectsPlusPref" target:self]] retain];	
		
		for (PSSpecifier *spec in specs) {
			NSString *Id = [[spec properties] objectForKey:@"id"];
			if ([Id isEqualToString:@"footer"])
				self.footerSpec = spec;
			else if ([Id isEqualToString:@"oldEditor"])
				self.oldEditorSpec = spec;
			else if ([Id isEqualToString:@"as"])
				self.asSpec = spec;
		}
		[self updateFooter:nil];	
		if (!isiOS8Up) {
			[specs removeObject:self.oldEditorSpec];
			[specs removeObject:self.asSpec];
		}
			
		_specifiers = [specs copy];
  	}
	return _specifiers;
}

- (NSString *)footerText
{
	int mode = integerValueForKey(saveMode, 1);
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

static void writeIntegerValueForKey(int value, NSString *key)
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict addEntriesFromDictionary:prefDict()];
	[dict setObject:@(value) forKey:key];
	[dict writeToFile:PREF_PATH atomically:YES];
}

@interface EPSaveOptionCell : PSTableCell
@end

@implementation EPSaveOptionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)identifier specifier:(PSSpecifier *)specifier
{
	if (self == [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier specifier:specifier]) {
		UISegmentedControl *modes = [[[UISegmentedControl alloc] initWithItems:@[@"❗ ", @"#1", @"#2", @"#3"]] autorelease];
		modes.tintColor = [UIColor systemRedColor];
		[modes addTarget:self action:@selector(modeAction:) forControlEvents:UIControlEventValueChanged];
		modes.selectedSegmentIndex = integerValueForKey(saveMode, 1) - 1;
		[self setAccessoryView:modes];
	}
	return self;
}

- (void)modeAction:(UISegmentedControl *)segment
{
	writeIntegerValueForKey(segment.selectedSegmentIndex + 1, saveMode);
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), PreferencesChangedNotification, NULL, NULL, YES);
	[[NSNotificationCenter defaultCenter] postNotificationName:updateFooterNotification object:nil userInfo:nil];
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