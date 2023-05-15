//
//  CCNavigationController.m
//  OptimizationDemo
//
//  Created by Murphy on 2022/11/25.
//

#import "CCNavigationController.h"

@interface CCNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation CCNavigationController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = YES;
    }
    
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithDefaultBackground];
        [appearance setBackgroundImage:[UIImage imageNamed:@"nav_back"]];
        appearance.shadowColor = [UIColor clearColor];
        appearance.shadowImage = [UIImage new];
        
        UINavigationBar *navBar = [UINavigationBar appearanceWhenContainedInInstancesOfClasses:@[[CCNavigationController class]]];
        navBar.standardAppearance = appearance;
        navBar.scrollEdgeAppearance = appearance;
    } else {
        // Fallback on earlier versions
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav_back"] forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
    }
    
    
    
    NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,[UIFont boldSystemFontOfSize:16],NSFontAttributeName, nil];
    [self.navigationBar setTitleTextAttributes:dic];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return true;
    }
    return false;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0]) {
            return false;
        }
    }
    return true;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
