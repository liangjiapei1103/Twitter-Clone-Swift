//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Jiapei Liang on 2/21/17.
//  Copyright © 2017 jiapei. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    var tweets: [Tweet]!
    
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    var selectedImage: UIImage!
    
    var replyTweetIndexPath: IndexPath!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = UIColor.white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Added image view to navigation title
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "twitter")
        imageView.image = image
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        navigationItem.titleView = imageView
        
        // Initialize tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets

        
        // Get homeline tweets
        TwitterClient.sharedInstance?.homeTimeline(success: { (tweets: [Tweet]) in
            
            self.tweets = tweets
            
            self.tableView.reloadData()
            
        }, failure: { (error: Error) in
            print(error.localizedDescription)
        })
        
        // Initialize a UIRefreshControl
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        TwitterClient.sharedInstance?.pullToGetNewTweets(success: { (tweets: [Tweet]) in
            
            for tweet in tweets.reversed() {
                self.tweets.insert(tweet, at: 0)
            }
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                self.tableView.reloadData()
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
            })
    
        }, failure: { (error: Error) in
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                
                // Tell the refreshControl to stop spinning
                refreshControl.endRefreshing()
                
                print(error.localizedDescription)
            })
        })
        
    }

    
    @IBAction func onLogoutButton(_ sender: Any) {
        
        TwitterClient.sharedInstance?.logout()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tweets != nil {
            return tweets.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetTableViewCell
        
        cell.tweet = tweets[indexPath.row]
        
        cell.indexPath = indexPath
        
        cell.vc = self
        
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // Code to load more results
                loadMoreData()
            }
        }
    }
    
    func loadMoreData() {
        
        TwitterClient.sharedInstance?.scrollDownToGetOldTweets(success: { (tweets: [Tweet]) in
            
            var isFirstTweet = true
            
            for tweet in tweets {
                if !isFirstTweet {
                    self.tweets.append(tweet)
                } else {
                    isFirstTweet = false
                }
            }
            
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                self.tableView.reloadData()
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                self.tableView.reloadData()
                
                self.isMoreDataLoading = false
            })
            
        }, failure: { (error: Error) in
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (Timer) in
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                print(error.localizedDescription)
            })
        })
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showImageInFullScreenSegue" {
            let destination = segue.destination as! FullScreenImageViewController
            
            destination.image = self.selectedImage
            
        } else if segue.identifier == "showTweetDetailSegue" {
            
            let destination = segue.destination as! TweetDetailTableViewController
            
            if let indexPath = tableView.indexPathForSelectedRow {
                if let tweet = self.tweets[indexPath.row] as? Tweet {
                    destination.tweet = tweet
                    destination.tweetsViewController = self
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            
            
            
        } else if segue.identifier == "composeNewTweetSegue" {
            
            let destination = segue.destination as! ComposeViewController
            
            destination.tweetsViewController = self
            
        } else if segue.identifier == "showReplyViewSegue" {
            
            let destination = segue.destination as! ReplyViewController
            
            destination.tweetsViewController = self
            
            if let indexPath = replyTweetIndexPath {
                if let tweet = self.tweets[indexPath.row] as? Tweet {
                    // destination.tweetTextview.text = ("@\(tweet.screenName!) ")
                    print("Tweet: \(tweet)")
                    destination.tweetId = tweet.id
                    destination.screenName = tweet.screenName
                }
                self.tableView.deselectRow(at: indexPath, animated: true)
            }
            
        }
        
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
