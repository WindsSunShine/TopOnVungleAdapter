//
//  ATVungleConfigure.h
//  AnyThinkVungleAdapter
//
//  Created by Ben on 2022/6/13.
//  Copyright © 2022 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/ATNetwokBaseConfigure.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATVungleConfigure : ATNetwokBaseConfigure

@property (nonatomic,strong,readonly) NSString *appid;

/// init
/// @param appid  appid
- (instancetype)initWithAppid:(NSString *)appid;
@end

NS_ASSUME_NONNULL_END
