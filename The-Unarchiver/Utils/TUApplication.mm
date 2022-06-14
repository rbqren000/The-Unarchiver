//
//  TUApplication.m
//  The-Unarchiver
//
//  Created by SWING on 2022/6/14.
//

#import "TUApplication.h"



@interface TUApplication ()

@property (nonatomic, copy, nullable, readonly) NSString *iconName;

@end

@implementation TUApplication

- (instancetype)initWithFileURL:(NSURL *)fileURL
{
    self = [super init];
    if (self)
    {
        NSBundle *bundle = [NSBundle bundleWithURL:fileURL];
        if (bundle == nil)
        {
            return nil;
        }
        
        // Load info dictionary directly from disk, since NSBundle caches values
        // that might not reflect the updated values on disk (such as bundle identifier).
        NSURL *infoPlistURL = [bundle.bundleURL URLByAppendingPathComponent:@"Info.plist"];
        NSDictionary *infoDictionary = [NSDictionary dictionaryWithContentsOfURL:infoPlistURL];
        if (infoDictionary == nil)
        {
            return nil;
        }
        
        NSString *executableName = infoDictionary[@"CFBundleExecutable"];
        NSURL *executableFileURL = [fileURL URLByAppendingPathComponent:executableName];
        
        NSString *name = infoDictionary[@"CFBundleDisplayName"] ?: infoDictionary[(NSString *)kCFBundleNameKey];
        NSString *bundleIdentifier = infoDictionary[(NSString *)kCFBundleIdentifierKey];
                
        if (name == nil || bundleIdentifier == nil)
        {
            return nil;
        }
        
        NSString *version = infoDictionary[@"CFBundleShortVersionString"] ?: @"1.0";
        NSString *minimumVersionString = infoDictionary[@"MinimumOSVersion"] ?: @"1.0";
        
        NSArray *versionComponents = [minimumVersionString componentsSeparatedByString:@"."];
        
        NSInteger majorVersion = [versionComponents.firstObject integerValue];
        NSInteger minorVersion = (versionComponents.count > 1) ? [versionComponents[1] integerValue] : 0;
        NSInteger patchVersion = (versionComponents.count > 2) ? [versionComponents[2] integerValue] : 0;
        
        NSOperatingSystemVersion minimumVersion;
        minimumVersion.majorVersion = majorVersion;
        minimumVersion.minorVersion = minorVersion;
        minimumVersion.patchVersion = patchVersion;
        

        
        NSDictionary *icons = infoDictionary[@"CFBundleIcons"];
        NSDictionary *primaryIcon = icons[@"CFBundlePrimaryIcon"];
        
        NSString *iconName = nil;
        
        if ([primaryIcon isKindOfClass:[NSString class]])
        {
            iconName = (NSString *)primaryIcon;
        }
        else
        {
            NSArray *iconFiles = primaryIcon[@"CFBundleIconFiles"];
            if (iconFiles == nil)
            {
                iconFiles = infoDictionary[@"CFBundleIconFiles"];
            }
            
            iconName = [iconFiles lastObject];
            if (iconName == nil)
            {
                iconName = infoDictionary[@"CFBundleIconFile"];
            }
        }
        
        _bundle = bundle;
        _fileURL = [fileURL copy];
        _name = [name copy];
        _bundleIdentifier = [bundleIdentifier copy];
        _version = [version copy];
        _minimumiOSVersion = minimumVersion;
        _iconName = [iconName copy];
        _executableName = [executableName copy];
        _executableFileURL = [executableFileURL copy];
    }
    
    return self;
}

- (UIImage *)icon
{
    NSString *iconName = self.iconName;
    if (iconName == nil)
    {
        return nil;
    }
    
    UIImage *icon = [UIImage imageNamed:iconName inBundle:self.bundle compatibleWithTraitCollection:nil];
    return icon;
}


- (NSSet<TUApplication *> *)appExtensions
{
    NSMutableSet *appExtensions = [NSMutableSet set];
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtURL:self.bundle.builtInPlugInsURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
    for (NSURL *fileURL in enumerator)
    {
        if (![fileURL.pathExtension.lowercaseString isEqualToString:@"appex"])
        {
            continue;
        }
        
        TUApplication *appExtension = [[TUApplication alloc] initWithFileURL:fileURL];
        if (appExtension == nil)
        {
            continue;
        }
        
        [appExtensions addObject:appExtension];
    }
    
    return appExtensions;
}


@end
