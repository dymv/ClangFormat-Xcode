//
//  TRVSCodeFragment.m
//  ClangFormat
//
//  Created by Travis Jeffery on 1/9/14.
//  Copyright (c) 2014 Travis Jeffery. All rights reserved.
//

#import "TRVSCodeFragment.h"

@implementation TRVSCodeFragment

- (void)formatWithStyle:(NSString *)style
    usingClangFormatAtLaunchPath:(NSString *)launchPath {
  NSURL *tmpFileURL = [self.fileURL URLByAppendingPathExtension:@"trvs"];
  [self.string writeToURL:tmpFileURL
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:NULL];

  NSPipe *outputPipe = [NSPipe pipe];

  NSTask *task = [[NSTask alloc] init];
  task.standardOutput = outputPipe;
  task.launchPath = launchPath;

  NSMutableArray* arguments = [NSMutableArray arrayWithArray:@[
    [NSString stringWithFormat:@"-style=%@", style],
    @"-i"
  ]];

  if (self.characterRange.length > 0) {
    [arguments addObjectsFromArray:@[
      [NSString stringWithFormat:@"-offset=%lu", self.characterRange.location],
      [NSString stringWithFormat:@"-length=%lu", self.characterRange.length]
    ]];
  }

  [arguments addObject:[tmpFileURL path]];

  task.arguments = [arguments copy];

  [outputPipe.fileHandleForReading readToEndOfFileInBackgroundAndNotify];

  [task launch];
  [task waitUntilExit];

  self.formattedString = [NSString stringWithContentsOfURL:tmpFileURL
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];

  [[NSFileManager defaultManager] removeItemAtURL:tmpFileURL error:NULL];
}

@end
