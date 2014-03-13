#import "../Common.h"
#import <UIKit/UIKit.h>
#import <Preferences/PSViewController.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <notify.h>

#include <objc/runtime.h>
#include <sys/sysctl.h>

@interface PSViewController (EffectsPlus)
- (void)setView:(id)view;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (void)viewDidLoad;
@end

@interface UITableViewCell (EffectsPlus)
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)identifier;
@end

@interface PSTableCell (EffectsPlus)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier;
@end

@interface EffectsPlusFiltersSelectionController : PSViewController
- (UITableView *)tableView;
@end

@interface EffectsPlusFiltersSelectionController () <UITableViewDelegate, UITableViewDataSource> {
	NSMutableOrderedSet *_enabledEffects;
	NSMutableOrderedSet *_disabledEffects;
}
@end

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
	[array addObject:@"CIPhotoEffectChrome"]; [array addObject:@"CIPhotoEffectProcess"];
	[array addObject:@"CIPhotoEffectTransfer"];	[array addObject:@"CIPhotoEffectInstant"];
	return array;
}

- (NSMutableArray *)arrayByAddingExtras
{
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"CISepiaTone"]; [array addObject:@"CIVibrance"];
	[array addObject:@"CIColorMonochrome"]; [array addObject:@"CIColorPosterize"];
	[array addObject:@"CIGloom"]; [array addObject:@"CIBloom"];
	[array addObject:@"CISharpenLuminance"]; [array addObject:@"CILinearToSRGBToneCurve"];
	[array addObject:@"CIPixellate"]; [array addObject:@"CIGaussianBlur"];
	[array addObject:@"CIFalseColor"]; [array addObject:@"CIWrapMirror"];
	[array addObject:@"CIColorInvert"]; [array addObject:@"CIHoleDistortion"];
	[array addObject:@"CICircleSplashDistortion"];
	
	[array addObject:@"CIThermal"]; [array addObject:@"CIMirror"];
	[array addObject:@"CIXRay"]; [array addObject:@"CITriangleKaleidoscope"];
	[array addObject:@"CILightTunnel"]; [array addObject:@"CIPinchDistortion"];
	[array addObject:@"CITwirlDistortion"];	[array addObject:@"CIStretch"];
	return array;
}

- (void)toggleFiltersArray
{
	NSString *title = ((UINavigationItem *)[super navigationItem]).rightBarButtonItem.title;
	if ([title isEqualToString:@"Reset"]) {
		_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingDefaults]];
		_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:[self arrayByAddingExtras]];
	}
	else if ([title isEqualToString:@"Enable All"]) {
		[_enabledEffects addObjectsFromArray:_disabledEffects.array];
		_disabledEffects = [NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]];
	}
	else if ([title isEqualToString:@"Disable All"]) {
		[_disabledEffects addObjectsFromArray:_enabledEffects.array];
		_enabledEffects = [NSMutableOrderedSet orderedSetWithArray:[NSMutableArray array]];
	}
	[self saveSettings];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self.tableView reloadData];
	[self setToggleTitle];
}

- (void)setToggleTitle
{
	NSString *title = @"Reset";
	NSDictionary *prefDict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
	if (prefDict != nil) {
		if (_disabledEffects.count == 0)
			title = @"Disable All";
		if (_enabledEffects.count == 0)
			title = @"Enable All";
	}
	UIBarButtonItem *toggleBtn = [[UIBarButtonItem alloc]
        	initWithTitle:title style:UIBarButtonItemStyleBordered
        	target:self action:@selector(toggleFiltersArray)];
	((UINavigationItem *)[super navigationItem]).rightBarButtonItem = toggleBtn;
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
		case 0: return @"Enabled Filters";
		case 1: return @"Disabled Filters";
	}
	return nil;
}

- (void)saveSettings
{
	NSMutableDictionary *prefDict = [[NSDictionary dictionaryWithContentsOfFile:PREF_PATH] mutableCopy];
	if (prefDict == nil)
		prefDict = [NSMutableDictionary dictionary];
	prefDict[ENABLED_EFFECT] = _enabledEffects.array;
	prefDict[DISABLED_EFFECT] = _disabledEffects.array;
	[prefDict.copy writeToFile:PREF_PATH atomically:YES];
	notify_post(PreferencesChangedNotification);
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
	[self setToggleTitle];
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
        	initWithTitle:nil style:UIBarButtonItemStyleBordered
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
		[self setToggleTitle];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *const CellIdentifier = [NSString stringWithFormat:@"eff %ld", (long)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UIColor *stockColor = [UIColor colorWithRed:.8 green:.9 blue:.9 alpha:1];
	UIColor *pbColor = [UIColor colorWithRed:1 green:.8 blue:.8 alpha:1];
	NSArray *pbArray = @[@"CIXRay", @"CITwirlDistortion", @"CIStretch", @"CIMirror", @"CITriangleKaleidoscope", @"CIPinchDistortion", @"CIThermal", @"CILightTunnel"];
	NSBundle *plBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/PhotoLibrary.framework"];
	UIImage *FilterOn = [UIImage imageNamed:@"CAMFilterButtonOn" inBundle:plBundle];
	UIImage *Filter = [UIImage imageNamed:@"CAMFilterButton" inBundle:plBundle];
	UIImage *PB = [UIImage imageNamed:@"PB" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/EffectsPlusPref.bundle"]];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		[cell.textLabel setNumberOfLines:1];
		[cell.textLabel setBackgroundColor:[UIColor clearColor]];
	}
	
	if (indexPath.section == 0) {
		if (_enabledEffects.count - 1 >= indexPath.row) {
			NSString *enabledName = [_enabledEffects objectAtIndex:indexPath.row];
    		[cell.textLabel setText:displayNameFromCIFilterName(enabledName)];
    		if ([enabledName hasPrefix:@"CIPhotoEffect"]) {
				[cell setBackgroundColor:stockColor];
				[[cell imageView] setImage:FilterOn];
			}
    		else {
    			BOOL pb = NO;
    			for (NSString *name in pbArray) {
    				if ([name isEqualToString:enabledName]) {
    					pb = YES;
    					break;
    				}
    			}
    			if (pb) {
    				[[cell imageView] setImage:PB];
    				[cell setBackgroundColor:pbColor];
    			}
    			else {
    				[[cell imageView] setImage:Filter];
    				[cell setBackgroundColor:[UIColor clearColor]];
    			}
    		}
    	}
    }
    else if (indexPath.section == 1) {
    	if (_disabledEffects.count - 1 >= indexPath.row) {
    		NSString *disabledName = [_disabledEffects objectAtIndex:indexPath.row];
    		[cell.textLabel setText:displayNameFromCIFilterName(disabledName)];
    		if ([disabledName hasPrefix:@"CIPhotoEffect"]) {
				[cell setBackgroundColor:stockColor];
				[[cell imageView] setImage:FilterOn];
			}
    		else {
    			BOOL pb = NO;
    			for (NSString *name in pbArray) {
    				if ([name isEqualToString:disabledName]) {
    					pb = YES;
    					break;
    				}
    			}
    			if (pb) {
    				[[cell imageView] setImage:PB];
    				[cell setBackgroundColor:pbColor];
    			}
    			else {
    				[[cell imageView] setImage:Filter];
    				[cell setBackgroundColor:[UIColor clearColor]];
    			}
			}
    	}
    }
    return cell;
}

- (void)dealloc
{
	[super dealloc];
}

@end

@interface EffectsPlusFiltersSettingsController : PSListController
@end

@implementation EffectsPlusFiltersSettingsController

- (void)hideKeyboard
{
	[[super view] endEditing:YES];
}

- (void)addBtn
{
	UIBarButtonItem *hideKBBtn = [[UIBarButtonItem alloc]
        initWithTitle:@"Hide KB" style:UIBarButtonItemStyleBordered
        target:self action:@selector(hideKeyboard)];
	((UINavigationItem *)[super navigationItem]).rightBarButtonItem = hideKBBtn;
	[hideKBBtn release];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self addBtn];
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
	[[NSUserDefaults standardUserDefaults] synchronize];
	[self reloadSpecifier:spec animated:NO];
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
@end

@implementation EffectsPlusPrefController

- (void)donate:(id)param
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=GBQGZL8EFMM86"]];
}

- (NSArray *)specifiers
{
	if (_specifiers == nil) {
		NSMutableArray *specs = [NSMutableArray arrayWithArray:[self loadSpecifiersFromPlistName:@"EffectsPlusPref" target:self]];			
		_specifiers = [specs copy];
  	}
	return _specifiers;
}

@end
