//
//  MoviesViewController.m
//  Flix
//
//  Created by emily13hsiao on 6/26/19.
//  Copyright © 2019 emily13hsiao. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *filteredData;

@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    //Set datasource and delegate.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //Set up refresh control.
    [self.activityIndicatorView startAnimating];
    [self fetchMovies];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];

    
    self.searchBar.delegate = self;
    
    
}

//Network request.
- (void)fetchMovies {
    //[self.activityIndicatorView startAnimating];
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error" message:@"Please check your connection and try again." preferredStyle:(UIAlertControllerStyleAlert)];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
            [alert addAction:okAction];
            [self presentViewController:alert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];

        }
        else {
            NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            // TODO: Get the array of movies
            // TODO: Store the movies in a property to use elsewhere
            // TODO: Reload your table view data
            //NSLog(@"%@", dataDictionary);
            
            self.movies = dataDictionary[@"results"];
            self.data = self.movies;
            self.filteredData = self.movies;
            for (NSDictionary *movie in self.movies) {
                NSLog(@"%@", movie[@"title"]);
            }
            [self.activityIndicatorView stopAnimating];
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    cell.posterView.image = nil;
    [cell.posterView setImageWithURL: posterURL];
    cell.titleLabel.text = movie[@"title"];
    cell.synopsisLabel.text = movie[@"overview"];
    
    return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length != 0) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return [evaluatedObject[@"title"] containsString:searchText];
        }];
        self.filteredData = [self.data filteredArrayUsingPredicate:predicate];
        
    }
    else {
        self.filteredData = self.data;
    }
    [self.tableView reloadData];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = NO;
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
    self.filteredData = self.data;
    [self.tableView reloadData];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewCell *tappedCell = sender;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    NSDictionary *movie = self.filteredData[indexPath.row];
    
    DetailsViewController *detailViewController = [segue destinationViewController];
    detailViewController.movie = movie;
}


@end
