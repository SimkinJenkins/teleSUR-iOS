//
//  TSConfigurationTableViewController.m
//  teleSUR
//
//  Created by Simkin on 20/02/15.
//  Copyright (c) 2015 teleSUR. All rights reserved.
//

#import "TSConfigurationTableViewController.h"

#import <Pushwoosh/PushNotificationManager.h>
#import "UIView+TSBasicCell.h"

@implementation TSConfigurationTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    NSString *config = [[NSUserDefaults standardUserDefaults] stringForKey:@"pushNotificationConfig"];

    [self localStorePushNotificationConfiguration:(!config ? @"PLMDC" : config) ];

    if (!config) {
        NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:
                              currentPushConfig, @"seleccion", nil];
        
        [[PushNotificationManager pushManager] setTags:tags];
    }

    [self.tableView registerNib:[UINib nibWithNibName:@"TSSwitchViewCell" bundle:nil] forCellReuseIdentifier:@"TSSwitchViewCell"];

    [[PushNotificationManager pushManager] loadTags];

    self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, 100);

}



















#pragma mark - Private Functions

- (NSString *) getConfigStringOnSwitchChange:(int)changedSwitchIndex {

    BOOL pValue = [currentPushConfig rangeOfString:@"P"].length != 0;
    BOOL lValue = [currentPushConfig rangeOfString:@"L"].length != 0;
    BOOL mValue = [currentPushConfig rangeOfString:@"M"].length != 0;
    BOOL dValue = [currentPushConfig rangeOfString:@"D"].length != 0;
    BOOL cValue = [currentPushConfig rangeOfString:@"C"].length != 0;

    pValue = changedSwitchIndex == 0 ? !pValue : pValue;
    lValue = changedSwitchIndex == 1 ? !lValue : lValue;
    mValue = changedSwitchIndex == 2 ? !mValue : mValue;
    dValue = changedSwitchIndex == 3 ? !dValue : dValue;
    cValue = changedSwitchIndex == 4 ? !cValue : cValue;

//    NSLog(@"%hhd - %hhd - %hhd - %hhd - %hhd", pValue, lValue, mValue, dValue, cValue);
    return [NSString stringWithFormat:@"%@%@%@%@%@", pValue ? @"P" : @"", lValue ? @"L" : @"", mValue ? @"M" : @"", dValue ? @"D" : @"", cValue ? @"C" : @"" ];

}

- (NSString *) getSectionNameForIndex:(int)index {

    if ( index == 0 ) {
        return [NSString stringWithFormat:NSLocalizedString(@"portadaSection", nil)];
    } else if ( index == 1 ) {
        return [NSString stringWithFormat:NSLocalizedString(@"latinoamericaSection", nil)];
    } else if ( index == 2 ) {
        return [NSString stringWithFormat:NSLocalizedString(@"mundoSection", nil)];
    } else if ( index == 3 ) {
        return [NSString stringWithFormat:NSLocalizedString(@"deportesSection", nil)];
    }
    return [NSString stringWithFormat:NSLocalizedString(@"culturaSection", nil)];

}

- (BOOL) isSwitchSelected:(int)index {

    if ( index == 0 ) {
        if ([currentPushConfig rangeOfString:@"P"].length != 0 ) {
            return YES;
        }
    } else if ( index == 1 ) {
        if ([currentPushConfig rangeOfString:@"L"].length != 0 ) {
            return YES;
        }
    } else if ( index == 2 ) {
        if ([currentPushConfig rangeOfString:@"M"].length != 0 ) {
            return YES;
        }
    } else if ( index == 3 ) {
        if ([currentPushConfig rangeOfString:@"D"].length != 0 ) {
            return YES;
        }
    } else if ( index == 4 ) {
        if ([currentPushConfig rangeOfString:@"C"].length != 0 ) {
            return YES;
        }
    }
    return NO;
    
}

- (void) switchValueChanged:(UISwitch *)sender {

    [self localStorePushNotificationConfiguration:[self getConfigStringOnSwitchChange:(int)sender.tag - 200]];

    NSDictionary *tags = [NSDictionary dictionaryWithObjectsAndKeys:
                          currentPushConfig, @"seleccion", nil];

    [[PushNotificationManager pushManager] setTags:tags];

}

- (void) localStorePushNotificationConfiguration:(NSString *)config {

    NSLog(@"localStorePush : %@", config);
    currentPushConfig = config;
    [[NSUserDefaults standardUserDefaults] setObject:config forKey:@"pushNotificationConfig"];

}



















#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TSSwitchViewCell" forIndexPath:indexPath];

    ((UILabel *)[cell viewWithTag:100]).text = [self getSectionNameForIndex:(int)indexPath.row];

    UISwitch *switchView = ((UISwitch *)[cell viewWithTag:101]);
    [switchView addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];

    [switchView setOn:[self isSwitchSelected:(int)indexPath.row]];
    switchView.tag = (200 + indexPath.row);

    NSLog(@"%ld", (long)switchView.tag);

    return cell;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:
                                 CGRectMake(0, 0, tableView.frame.size.width, 50.0)];

    sectionHeaderView.backgroundColor = [UIColor lightGrayColor];

    UILabel *headerLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 10, sectionHeaderView.frame.size.width, 25.0)];

    UILabel *headerDescLabel = [[UILabel alloc] initWithFrame:
                            CGRectMake(15, 35, sectionHeaderView.frame.size.width - 30, 70)];

    [headerLabel setFont:[UIFont fontWithName:headerLabel.font.familyName size:24.0]];
    [headerDescLabel setFont:[UIFont fontWithName:headerDescLabel.font.familyName size:12.0]];

    headerLabel.text = @"Notificaciones";
    headerDescLabel.numberOfLines = 0;
    headerDescLabel.text = @"Personaliza las notificaciones que recibirás de TeleSUR";

    [self.view adjustSizeFrameForLabel:headerDescLabel constriainedToSize:CGSizeMake(sectionHeaderView.frame.size.width - 30, 70)];

    [sectionHeaderView addSubview:headerLabel];
    [sectionHeaderView addSubview:headerDescLabel];

    return sectionHeaderView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 70.0f;
}



















#pragma mark - SlideNavigationController Methods -

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu {
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu {
    return NO;
}

@end