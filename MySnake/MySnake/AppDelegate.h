//
//  AppDelegate.h
//  MySnake
//
//  Created by 首汽租赁 on 2017/7/18.
//  Copyright © 2017年 杜俊楠. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

