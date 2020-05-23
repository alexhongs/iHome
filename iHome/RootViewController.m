//
//  RootViewController.m
//  iHome
//
//  Created by Alex Hong on 5/6/20.
//  Copyright © 2020 alexhongs. All rights reserved.
//

#import "RootViewController.h"
#import "AccessoryViewController.h"
#import "HomeSettingsViewController.h"
#import "HomeStore.h"

@interface RootViewController ()
@property (strong, nonatomic) HomeStore *sharedManager;

@property (nonatomic, strong) HMHomeManager *homeManager;
@property (nonatomic, strong) NSArray<HMHome *> *homes;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"RootViewContoller - View Did Load");
    // Do any additional setup after loading the view.
    _sharedManager = [HomeStore shared];
    
    self.homeManager = _sharedManager.homeManager;
    self.homeManager.delegate = self;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

-(void)accessoryClicked: (HMAccessory *)accessory{
    [self performSegueWithIdentifier:@"toAccessory" sender:accessory];
}

- (IBAction)menuClicked:(UIButton *)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Your Homes" message:@"Choose your home" preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (HMHome *home in self.homes) {
        UIAlertAction *homeAction = [UIAlertAction actionWithTitle:home.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.homeManager updatePrimaryHome:home completionHandler:^(NSError * _Nullable error) {
                [self updateView];
            }];
        }]; [alert addAction:homeAction];
    }
    
    UIAlertAction *addHomeAction = [UIAlertAction actionWithTitle:@"Add Home" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showAddHome];
    }]; [alert addAction:addHomeAction];
    
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Home Settings" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self showHomeSettings];
    }]; [alert addAction:settingsAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]; [alert addAction:cancelAction];

    [self presentViewController:alert animated:true completion:nil];
}

- (void)showHomeSettings {
    [self performSegueWithIdentifier:@"toSettings" sender:nil];
}

- (void)showAddHome {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Add Home" message:@"Provide your name" preferredStyle:UIAlertControllerStyleAlert];
    
    // Action Items
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *homeName = alertController.textFields[0].text;
        NSString *roomName = alertController.textFields[1].text;
        
        NSLog(@"Home Name : %@, Room Name : %@", homeName, roomName);
        [self addHome:homeName :roomName];
    }]; [alertController addAction:confirmAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]; [alertController addAction:cancelAction];
    
    // Text Fields
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter Home name";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Enter Room name";
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)updateView {
    self.titleLabel.text = self.homeManager.primaryHome.name;
    self.homes = self.homeManager.homes;
    [self.collectionView reloadData];
}

/**
 TODO: Need to move add home functionality to home settings controller later. Delegate will be moved to there.
 */
- (void)addHome:(NSString *) name :(NSString *) room {
    // Create new home and new room
    [self.homeManager addHomeWithName:name completionHandler:^(HMHome * _Nullable home, NSError * _Nullable error) {
        if(error == nil) {
            [home addRoomWithName: room completionHandler:^(HMRoom * _Nullable room, NSError * _Nullable error) {
                if(error != nil) {
                    NSLog(@"Error adding Room : %@", error);
                }
            }];
            // Make primary home the new home
            [self.homeManager updatePrimaryHome:home completionHandler:^(NSError * _Nullable error) {
                [self updateView];
            }];
        } else {
            NSLog(@"Error adding Home. Check if the %@ already exists", name);
        }
    }];
}

-(void)printHomes {
    NSLog(@"Homes List");
    for (HMHome *home in self.homes) {
        NSLog(@"Home: %@", home.name);
        for (HMAccessory *accessory in home.accessories) {
            NSLog(@"- Home Accessory: %@, room : %@", accessory.name, accessory.room.name);
        }
        
        for (HMRoom *room in home.rooms) {
            NSLog(@"- Room: %@", room.name);
            for (HMAccessory *accessory in room.accessories) {
                NSLog(@"- - Home Accessory: %@, room : %@", accessory.name, accessory.room.name);
                for (HMService *service in accessory.services) {
                    NSLog(@"s : %@", service.name);
                }
            }
        }
    }
    
    NSLog(@"Rooms List");
    for (HMRoom *room in _homeManager.primaryHome.rooms) {
        NSLog(@"- Room: %@", room.name);
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"prepare segue: ");
    
    if([segue.identifier  isEqual: @"toAccessory"]) {
        AccessoryViewController *vc = [segue destinationViewController];
        vc.accessory = sender;
    }
}

#pragma mark - HMHomeManagerDelegate

- (void)homeManagerDidUpdateHomes:(HMHomeManager *)manager {
    NSLog(@"Change occured at homes!");
    self.homes = self.homeManager.homes;
    [self updateView];
    [self printHomes];
}

#pragma mark - HMHomeDelegate
- (void)home:(HMHome *)home didAddAccessory:(HMAccessory *)accessory {
//    if([home isEqual:self.home]) {
//        return;
//    }
    
}

- (void)home:(HMHome *)home didRemoveAccessory:(HMAccessory *)accessory {
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.homeManager.primaryHome.accessories.count;
}

/**
 Get all accessories of primary home into cells
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    UICollectionViewCell *item = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"collectionCell" forIndexPath:indexPath];
    UILabel *label = [item viewWithTag:100];
    label.text = self.homeManager.primaryHome.accessories[indexPath.row].name;
    item.backgroundColor = UIColor.whiteColor;
    return item;
}

#pragma mark - UICollectionViewDelegate

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    UILabel *cellLabel = [cell viewWithTag:100];
    
    HMAccessory *accessory = self.homeManager.primaryHome.accessories[indexPath.row];
    NSLog(@"Selected Item at %@ : %@", cellLabel.text, accessory.name);
    HMCharacteristic *chrc;
    for (HMService *servic in accessory.services) {
        NSLog(@"- servic : %@", servic.name);
        for (HMCharacteristic *charac in servic.characteristics) {
            if([charac.localizedDescription  isEqual: @"Power State"]) {
                chrc = charac;
            }
            NSLog(@"- - servic : %@", charac.localizedDescription);
        }
    }

//    BOOL value = (BOOL) charac.value;
//    NSNumber *val = [NSNumber numberWithInt:0];
    [chrc readValueWithCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error reading %@", error);
    }];
    
    NSLog(@"val desc : %@", chrc.metadata.description);
    NSLog(@"val m M : %@ %@", chrc.metadata.minimumValue, chrc.metadata.maximumValue);
    NSLog(@"val desc : %@", [chrc value]);
    for (NSNumber *value in chrc.metadata.validValues) {
        NSLog(@"val : %@", value.description);
    }

    [chrc writeValue: chrc.value completionHandler:^(NSError * _Nullable error) {
        NSLog(@"Error writing %@", error);
    }];
}

/**
 Triggered when cell item is pressed
 */
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = UIColor.lightGrayColor;
    HMAccessory *accessory = self.homeManager.primaryHome.accessories[indexPath.row];
    // TODO: Figure out activate accessoryVC with some delay. click for 2 sec events
    //    [self accessoryClicked: accessory];
}

/**
Triggered when cell item is released
*/
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = UIColor.whiteColor;
}

@end
