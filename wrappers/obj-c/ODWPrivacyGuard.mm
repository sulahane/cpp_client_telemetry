//
// Copyright (c) Microsoft Corporation. All rights reserved.
// SPDX-License-Identifier: Apache-2.0
//
#include <stdexcept>
#include "ILogger.hpp"
#include "LogManager.hpp"
#include "PrivacyGuard.hpp"
#import <Foundation/Foundation.h>
#import "ODWLogConfiguration.h"
#import "ODWPrivacyGuard.h"
#import "ODWPrivacyGuard_private.h"
#import "ODWPrivacyGuardInitConfig.h"

using namespace MAT;

@implementation ODWPrivacyGuard

std::shared_ptr<PrivacyGuard> _privacyGuardPtr;

+(CommonDataContext)convertToNativeCommonDataContexts:(ODWCommonDataContext *)odwCDC
{
    CommonDataContext cdc;
    if([ [odwCDC DomainName] length] != 0)
    {
        cdc.DomainName = [[odwCDC DomainName] UTF8String];
    }
    
    if([[odwCDC MachineName] length] != 0)
    {
        cdc.MachineName = [[odwCDC MachineName] UTF8String];
    }

    if([odwCDC UserNames] != nil && [[odwCDC UserNames] count] != 0)
    {
        for(NSString* userName in [odwCDC UserNames])
        {
            cdc.UserNames.push_back([userName UTF8String]);
        }
    }

    if([odwCDC UserAliases] != nil && [[odwCDC UserAliases] count] != 0)
    {
        for(NSString* userAlias in [odwCDC UserAliases])
        {
            cdc.UserAliases.push_back([userAlias UTF8String]);
        }
    }

    if([odwCDC IpAddresses] != nil && [[odwCDC IpAddresses] count] != 0)
    {
        for(NSString* ipAddress in [odwCDC IpAddresses])
        {
            cdc.IpAddresses.push_back([ipAddress UTF8String]);
        }
    }

    if([odwCDC LanguageIdentifiers] != nil && [[odwCDC LanguageIdentifiers] count] != 0)
    {
        for(NSString* languageIdentifiers in [odwCDC LanguageIdentifiers])
        {
            cdc.LanguageIdentifiers.push_back([languageIdentifiers UTF8String]);
        }
    }
    
    if([odwCDC MachineIds] != nil && [[odwCDC MachineIds] count] != 0)
    {
        for(NSString* machineIds in [odwCDC MachineIds])
        {
            cdc.MachineIds.push_back([machineIds UTF8String]);
        }
    }

    if([odwCDC OutOfScopeIdentifiers] != nil && [[odwCDC OutOfScopeIdentifiers] count] != 0)
    {
        for(NSString* outOfScopeIdentifiers in [odwCDC OutOfScopeIdentifiers])
        {
            cdc.OutOfScopeIdentifiers.push_back([outOfScopeIdentifiers UTF8String]);
        }
    }

    return cdc;
}

+(void)initializePrivacyGuard:(ILogger *)logger withODWPrivacyGuardInitConfig:(ODWPrivacyGuardInitConfig *)initConfigObject
{
    if (_privacyGuardPtr != nullptr)
    {
        return;
    }

    InitializationConfiguration config(logger, [ODWPrivacyGuard convertToNativeCommonDataContexts:[initConfigObject dataContext]]);
    if ([initConfigObject notificationEventName] != nil)
    {
        config.NotificationEventName = [[initConfigObject notificationEventName] UTF8String];
    }
    if ([initConfigObject semanticContextNotificationEventName] != nil)
    {
        config.SemanticContextNotificationEventName = [[initConfigObject semanticContextNotificationEventName] UTF8String];
    }
    if ([initConfigObject summaryEventName] != nil)
    {
        config.SummaryEventName = [[initConfigObject summaryEventName] UTF8String];
    }
    config.UseEventFieldPrefix = [initConfigObject useEventFieldPrefix];
    config.ScanForUrls = [initConfigObject scanForUrls];
    _privacyGuardPtr = std::make_shared<PrivacyGuard>(config);
    LogManager::GetInstance()->SetDataInspector(_privacyGuardPtr);
}

+(void)setEnabled:(bool)enabled
{
    if(_privacyGuardPtr != nullptr)
    {
        _privacyGuardPtr->SetEnabled(enabled);
    }
}

+(bool)enabled
{
    return _privacyGuardPtr != nullptr && _privacyGuardPtr->IsEnabled();
}

+(void)appendCommonDataContext:(ODWCommonDataContext *) freshCommonDataContexts
{
    _privacyGuardPtr->AppendCommonDataContext([ODWPrivacyGuard convertToNativeCommonDataContexts:freshCommonDataContexts]);
}

/*!
 @brief Add ignored concern to prevent generation of notification signals when this
 concern is found for the given EventName and Field combination.
 @param EventName Event that the ignored concern should apply to. <b>Note:</b> If the ignored concern applies to Semantic Context field, set the Event name to 'SemanticContext'.
 @param FieldName Field that the ignored concern should apply to.
 @param IgnoredConcern The concern that is expected and should be ignored.
 */
+(void)addIgnoredConcern:(NSString *) EventName withNSString:(NSString *)FieldName withODWDataConcernType:(ODWDataConcernType)IgnoredConcern
{
    const std::string eventName = [EventName UTF8String];
    const std::string fieldName = [FieldName UTF8String];
    const uint8_t ignoredConcern = (uint8_t)IgnoredConcern;
    
    _privacyGuardPtr->AddIgnoredConcern(eventName, fieldName, static_cast<DataConcernType>(ignoredConcern));
}

+(void)resetPrivacyGuardInstance
{
    _privacyGuardPtr = nullptr;
}

@end
