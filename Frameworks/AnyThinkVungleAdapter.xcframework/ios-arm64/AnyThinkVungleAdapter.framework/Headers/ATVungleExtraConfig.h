//
//  ATVungleExtraConfig.h
//  AnyThinkVungleAdapter
//
//  Created by GUO PENG on 2022/8/25.
//  Copyright © 2022 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class VunglePrivacySettings;

@interface ATVungleExtraConfig : NSObject

+ (void)setExtraConfig:(void(^_Nullable)(VunglePrivacySettings* _Nullable configuration))extraConfigBlock;



@end

NS_ASSUME_NONNULL_END
