//
//  iHomeTests.m
//  iHomeTests
//
//  Created by Alex Hong on 6/1/20.
//  Copyright © 2020 alexhongs. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "HomeStore.h"

// TODO: Current problem is that this test only builds when target is on simulated devices.
@interface iHomeTests : XCTestCase

@property (strong, nonatomic) HomeStore *homeStore;
@end

@implementation iHomeTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _homeStore = HomeStore.shared;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results
    
    XCTAssert(2 + 1 == 3);
    NSString *s = @"somes   6tring";
    XCTAssertNotNil(s);
}

- (void)testHomeStore {
    XCTAssertNotNil(_homeStore);
    XCTAssertEqual(_homeStore, HomeStore.shared);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end