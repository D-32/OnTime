//
//  PremiumViewController.m
//  AppleWatchSBB
//
//  Created by Dylan Marriott on 20.06.15.
//  Copyright (c) 2015 Dylan Marriott. All rights reserved.
//

#import "PremiumViewController.h"
#import "PremiumItem.h"
#import <StoreKit/StoreKit.h>
#import "UIBAlertView.h"

@interface PremiumViewController () <SKPaymentTransactionObserver, SKProductsRequestDelegate>
@end

@implementation PremiumViewController {
    UIView *_bg;
    UIView *_container;
    UILabel *_buyLabel;
    UITapGestureRecognizer *_tapGesture;
    NSUserDefaults *_userDefaults;
}

- (instancetype)init {
    if (self = [super init]) {
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.dylanmarriott.applewatchsbb"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _bg = [[UIView alloc] initWithFrame:self.view.bounds];
    _bg.backgroundColor = [UIColor clearColor];
    [_bg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];
    [self.view addSubview:_bg];
    
    _container = [[UIView alloc] initWithFrame:CGRectMake(20, self.view.frame.size.height / 2, self.view.frame.size.width - 40, 0)];
    _container.backgroundColor = [UIColor whiteColor];
    _container.layer.cornerRadius = 6;
    _container.clipsToBounds = YES;
    [self.view addSubview:_container];
    
    PremiumItem *swissItem = [[PremiumItem alloc] initWithFrame:CGRectMake(0, 0, _container.frame.size.width, 85) icon:[UIImage imageNamed:@"premiumFlag"] title:l10n(@"Swiss Developer") desc:l10n(@"Suppert a local swiss developer.\nApps aren't free to develop.")];
    [_container addSubview:swissItem];
    
    PremiumItem *favItem = [[PremiumItem alloc] initWithFrame:CGRectMake(0, 85, _container.frame.size.width, 85) icon:[UIImage imageNamed:@"premiumFav"] title:l10n(@"Favourites") desc:l10n(@"Favourites offer a quick access to your most used connections.")];
    [_container addSubview:favItem];
    
    PremiumItem *rssItem = [[PremiumItem alloc] initWithFrame:CGRectMake(0, 170, _container.frame.size.width, 85) icon:[UIImage imageNamed:@"premiumRss"] title:l10n(@"RSS") desc:l10n(@"Configure which region you want to include for the rail traffic info.")];
    [_container addSubview:rssItem];
    
    PremiumItem *notificationItem = [[PremiumItem alloc] initWithFrame:CGRectMake(0, 255, _container.frame.size.width, 85) icon:[UIImage imageNamed:@"premiumNotification"] title:l10n(@"Notifications") desc:l10n(@"Get notifications with connection info when changing trains.")];
    [_container addSubview:notificationItem];
    
    UIView *buyContainer = [[UIView alloc] initWithFrame:CGRectMake(25, 380, _container.frame.size.width - 50, 50)];
    buyContainer.backgroundColor = [UIColor colorWithRed:0.78 green:0.08 blue:0.09 alpha:1.00];
    buyContainer.layer.cornerRadius = 8;
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startProcess)];
    [buyContainer addGestureRecognizer:_tapGesture];
    [_container addSubview:buyContainer];
    
    _buyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, buyContainer.frame.size.width, buyContainer.frame.size.height)];
    _buyLabel.font = [UIFont systemFontOfSize:18];
    _buyLabel.textColor = [UIColor whiteColor];
    _buyLabel.textAlignment = NSTextAlignmentCenter;
    [buyContainer addSubview:_buyLabel];
    
    [self resetBuyLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIView animateWithDuration:0.3 animations:^{
        _bg.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        CGRect f = _container.frame;
        f.origin.y = self.view.frame.size.height / 2 - 225;
        f.size.height = 450;
        _container.frame = f;
    }];
}

- (void)close {
    [UIView animateWithDuration:0.3 animations:^{
        _bg.backgroundColor = [UIColor clearColor];
        CGRect f = _container.frame;
        f.origin.y = self.view.frame.size.height;
        _container.frame = f;
    } completion:^(BOOL finished) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)resetBuyLabel {
    _buyLabel.text = l10n(@"Activate for 2 CHF");
    _tapGesture.enabled = YES;
}

- (void)startProcess {
    _buyLabel.text = l10n(@"Processing...");
    _tapGesture.enabled = NO;
    if ([SKPaymentQueue canMakePayments]) {
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"SBBWatchPremium"]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    } else {
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    NSUInteger count = [response.products count];
    if (count > 0) {
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    } else if (!validProduct) {
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self handleSuccess];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                [self handleSuccess];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                if (transaction.error.code == SKErrorPaymentCancelled) {
                    NSLog(@"Transaction state -> Cancelled");
                }
                [self resetBuyLabel];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateDeferred:
                break;
        }
    }
}

- (void)handleSuccess {
    [_userDefaults setBool:YES forKey:@"premium"];
    [self close];
}

@end
