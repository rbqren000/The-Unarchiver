//
//  TUApplication.h
//  The-Unarchiver
//
//  Created by SWING on 2022/6/14.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUApplication : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *bundleIdentifier;
@property (nonatomic, copy, readonly) NSString *version;
@property (nonatomic, copy, readonly) NSString *executableName;
@property (nonatomic, copy, readonly) NSURL *executableFileURL;
@property (nonatomic, readonly, nullable) UIImage *icon;

@property (nonatomic, readonly) NSSet<TUApplication *> *appExtensions;
@property (nonatomic, readonly) NSOperatingSystemVersion minimumiOSVersion;
@property (nonatomic, copy, readonly) NSURL *fileURL;
@property (nonatomic, readonly) NSBundle *bundle;

- (nullable instancetype)initWithFileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
