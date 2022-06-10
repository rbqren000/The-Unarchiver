//
//  XADHelper.m
//  ABox
//
//  Created by SWING on 2022/6/9.
//

#import "XADHelper.h"
#import "XADUnarchiver.h"
#import "XADArchiveParser.h"
#import "XADSimpleUnarchiver.h"

@interface XADHelper()

@property (nonatomic, assign) XADError error;
@property (nonatomic, copy) NSString *lastPath;
@property (nonatomic, assign) BOOL isEncrypted;

@end

@implementation XADHelper

- (BOOL)archiverIsEncryptedWithPath:(NSString *)path {
    XADArchiveParser *archiveParser = [XADArchiveParser archiveParserForPath:path];
    XADSimpleUnarchiver *unarchiver = [[XADSimpleUnarchiver alloc] initWithArchiveParser:archiveParser];
    [unarchiver parse];
    archiveParser = [unarchiver archiveParser];
    NSLog(@"archiveParser properties:%@",archiveParser.properties);
    return [archiveParser isEncrypted];
}


- (int)unarchiverWithPath:(NSString *)path dest:(NSString *)destpath password:(NSString *)password {
    NSLog(@"unarchiverWithPath:%@ destpath:%@",path,destpath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:destpath]) {
        [[NSFileManager defaultManager] removeItemAtPath:destpath error:nil];
    }
    self.error = XADNoError;
    XADArchiveParser *archiveParser = [XADArchiveParser archiveParserForPath:path];
    NSLog(@"properties:%@",archiveParser.properties);
    [archiveParser setPassword:password];
    XADSimpleUnarchiver *unarchiver = [[XADSimpleUnarchiver alloc] initWithArchiveParser:archiveParser];
    [unarchiver setDelegate:self];
    [unarchiver setDestination:destpath];
    [unarchiver parse];
    [unarchiver unarchive];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.lastPath]) {
        self.error = XADUnknownError;
    }
    if (self.error == XADNoError) {
        NSLog(@"no error 解压成功");
    } else {
        NSLog(@"解压失败：%@",[XADException describeXADError:self.error]);
        [[NSFileManager defaultManager] removeItemAtPath:destpath error:nil];
    }
    return self.error;
}

-(void)simpleUnarchiverNeedsPassword:(XADSimpleUnarchiver *)unarchiver {
    NSLog(@"unarchiverNeedsPassword");
}

- (BOOL)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver shouldExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path {
    NSLog(@"shouldExtractEntryWithDictionary\ndict:%@\nto:%@",dict, path);
    return YES;
}

- (void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver willExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path {
    NSLog(@"willExtractEntryWithDictionary\ndict:%@\nto:%@",dict, path);
}

- (void)simpleUnarchiver:(XADSimpleUnarchiver *)unarchiver didExtractEntryWithDictionary:(NSDictionary *)dict to:(NSString *)path error:(XADError)error {
    NSLog(@"didExtractEntryWithDictionary\ndict:%@\nto:%@\nerror:%d",dict, path, error);
    self.lastPath = path;
    if (error != XADNoError) {
        self.error = error;
    }
}



@end
