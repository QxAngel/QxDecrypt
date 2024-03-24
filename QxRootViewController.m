#import "QxRootViewController.h"
#import "QxFileManagerViewController.h"
#import "QxUtils.h"

@implementation QxRootViewController

- (void)loadView {
    [super loadView];

    self.apps = appList();
    self.title = @"QxDecrypt";
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: [UIColor redColor]};
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"info.circle"] style:UIBarButtonItemStylePlain target:self action:@selector(about:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"folder"] style:UIBarButtonItemStylePlain target:self action:@selector(openDocs:)];

    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshApps:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewDidAppear:(bool)animated {
    [super viewDidAppear:animated];

    fetchLatestQxDecryptVersion(^(NSString *latestVersion) {
        NSString *currentVersion = qxDecryptVersion();
        NSComparisonResult result = [currentVersion compare:latestVersion options:NSNumericSearch];
        NSLog(@"[qxdecrypter] Current version: %@, Latest version: %@", currentVersion, latestVersion);
        if (result == NSOrderedAscending) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Actualización disponible" message:@"Hay una actualización disponible para QxDecrypt." preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil];
                UIAlertAction *update = [UIAlertAction actionWithTitle:@"Descargar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://github.com/QxAngel/QxDecryp/releases/latest"]] options:@{} completionHandler:nil];
                }];

                [alert addAction:update];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }
    });
}

- (void)openDocs:(id)sender {
    QxFileManagerViewController *fmVC = [[QxFileManagerViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:fmVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)about:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"QxDecrypt" message:@"By QxAngel/@6ky_l\nbfdecrypt by @bishopfox\ndumpdecrypted by @i0n1c\nUpdated for TrollStore by @wh1te4ever" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)refreshApps:(UIRefreshControl *)refreshControl {
    self.apps = appList();
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return self.apps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AppCell";
    UITableViewCell *cell;
    if (([self.apps count] - 1) != indexPath.row) {
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
        NSDictionary *app = self.apps[indexPath.row];

        cell.textLabel.text = app[@"name"];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ • %@", app[@"version"], app[@"bundleID"]];
        cell.imageView.image = [UIImage _applicationIconImageForBundleIdentifier:app[@"bundleID"] format:iconFormat() scale:[UIScreen mainScreen].scale];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        
        cell.textLabel.text = @"Avanzado";
        cell.detailTextLabel.text = @"Descifrar app con PID especifico ";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert;
    
    if (([self.apps count] - 1) != indexPath.row) {
        NSDictionary *app = self.apps[indexPath.row];

        alert = [UIAlertController alertControllerWithTitle:@"Descifrar" message:[NSString stringWithFormat:@"Descifrar %@?", app[@"name"]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *decrypt = [UIAlertAction actionWithTitle:@"Si" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            decryptApp(app);
        }];

        [alert addAction:decrypt];
        [alert addAction:cancel];
    } else {
        alert = [UIAlertController alertControllerWithTitle:@"Descifrar" message:@"Ingresar PID para descifrar" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"PID";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *decrypt = [UIAlertAction actionWithTitle:@"Descifrar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *pid = alert.textFields.firstObject.text;
            decryptAppWithPID([pid intValue]);
        }];

        [alert addAction:decrypt];
        [alert addAction:cancel];
    }

    [self presentViewController:alert animated:YES completion:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end