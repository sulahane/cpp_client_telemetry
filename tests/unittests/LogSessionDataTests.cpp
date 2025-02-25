//
// Copyright (c) Microsoft Corporation. All rights reserved.
// SPDX-License-Identifier: Apache-2.0
//

#include "common/Common.hpp"
#include "offline/LogSessionDataProvider.hpp"
#include <LogSessionData.hpp>

using namespace testing;
using namespace Microsoft::Applications::Events;

class TestLogSessionDataProvider : public LogSessionDataProvider
{
public:
    TestLogSessionDataProvider(const std::string &str): LogSessionDataProvider(str) {}
    using LogSessionDataProvider::parse;
};

const char* const PathToTestSesFile = "";
std::string sessionSDKUid;
uint64_t sessionFirstTimeLaunch;


TEST(LogSessionDataTests, parse_EmptyString_ReturnsFalse)
{   
   TestLogSessionDataProvider logSessionDataProvider(PathToTestSesFile);
   ASSERT_FALSE(logSessionDataProvider.parse(std::string {}, sessionFirstTimeLaunch, sessionSDKUid));
}

TEST(LogSessionDataTests, parse_OneLine_ReturnsFalse)
{

   TestLogSessionDataProvider logSessionDataProvider(PathToTestSesFile);
   ASSERT_FALSE(logSessionDataProvider.parse(std::string {"foo" }, sessionFirstTimeLaunch, sessionSDKUid));
}

TEST(LogSessionDataTests, parse_ThreeLines_ReturnsFalse)
{
   TestLogSessionDataProvider logSessionDataProvider(PathToTestSesFile);
   ASSERT_FALSE(logSessionDataProvider.parse(std::string { "foo\nbar\n\baz" }, sessionFirstTimeLaunch, sessionSDKUid));
}

TEST(LogSessionDataTests, parse_TwoLinesFirstLaunchNotNumber_ReturnsFalse)
{
   TestLogSessionDataProvider logSessionDataProvider(PathToTestSesFile);
   ASSERT_FALSE(logSessionDataProvider.parse(std::string { "foo\nbar" }, sessionFirstTimeLaunch, sessionSDKUid));
}

TEST(LogSessionDataTests, parse_TwoLinesFirstLaunchTooLarge_ReturnsFalse)
{
   TestLogSessionDataProvider logSessionDataProvider(PathToTestSesFile);
   ASSERT_FALSE(logSessionDataProvider.parse(std::string { "1111111111111111111111111111111111111111111111111111111111111111111\nbar" },
               sessionFirstTimeLaunch, sessionSDKUid));
}

TEST(LogSessionDataTests, parse_ValidInput_ReturnsTrue)
{
   TestLogSessionDataProvider logSessionDataProvider(PathToTestSesFile);
   ASSERT_TRUE(logSessionDataProvider.parse(std::string { "1234567890\nbar" }, sessionFirstTimeLaunch, sessionSDKUid));
}

