#import <Foundation/Foundation.h>

static NSDictionary *prefDict()
{
	return [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
}

static int integerValueForKey(NSString *key, int defaultValue)
{
	NSDictionary *pref = prefDict();
	return pref[key] ? [pref[key] intValue] : defaultValue;
}
