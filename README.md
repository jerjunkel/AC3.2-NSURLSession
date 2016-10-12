### AC3.2 `NSURLSession / URLSession`
---

### Readings:
1. [`URLSession` - Apple](https://developer.apple.com/reference/foundation/urlsession) (just the "Overview section for now")
2. [`NSURLSession` - Objc.io (video)](https://www.objc.io/issues/5-ios7/from-nsurlconnection-to-nsurlsession/)
3. [Fundamentals of Callbacks for Swift Developers](https://www.andrewcbancroft.com/2016/02/15/fundamentals-of-callbacks-for-swift-developers/)

### Reference:
2. [`URL` - Apple](https://developer.apple.com/reference/foundation/url) 
4. [`JSONSerialization` - Apple](https://developer.apple.com/reference/foundation/jsonserialization)

### Neat Resources:
1. [`myjson` - simple JSON hosting](http://myjson.com/)
2. [`JSONlint` - json format validation](http://jsonlint.com/)

---
### 0. Goals 

  - Understanding that `URL` truly is "universal" as it can refer to a file on your local machine, or a web URL
  - Handling `json` data from web requests is exactly like dealing with a local `dictionary/json`
  - Reusuability of code makes building something up to the point much easier as we can reuse the same parsing function from the prior lesson here. 

---
### 1. Focusing on the MVC Pattern

In MVC a (view) controller is only meant to coordinate data in the model and use that to update its views. In the first part of this lesson, we put all of our code inside of our main view controller class. This lesson begins with the same code we wrote, but arranged differently:

1. The `InstaCat` struct has been moved into its own file
2. The code used to retrieve `URL` info and parse `Data` into `InstaCat` has been moved into its own class, `InstaCatFactory`
3. `InstaCatFactory` communicates publicly through the class function `makeInstaCats(fileName:)`, which accepts a `String` parameter that represents the name of the file that contains our `json`
  4. Since we want to treat our factory as a "black box", we make functions we used last time to be `fileprivate`, meaning the scope of those functions are limited to the `.swift` file they are in. 
  

> #### *The more you know*: The Singleton
> You may notice that `InstaCatFactory` is using something you haven't seen before: 
```swift
  // this is called a "singleton"
  static let manager: InstaCatFactory = InstaCatFactory()
  private init() {}
```
> The goal of a singleton is that there only is ever one of them that exists in the lifetime of your app. The line `private init(){}` makes it so that you cannot initialize the class anywhere outside of itself. Go ahead, try create an instance of `InstaCatFactory` inside of the `InstaCatTableViewController` like so `let instaFactory: InstaCatFactory = InstaCatFactory`. You will not be allowed to do so! In effect, if you want to use an instance of `InstaCatFactory` you *have* to reference it's `manager` property. Singletons work well for managing data in simple apps, but can cause problems in more complex situations.


Now, in our table view controller's `viewDidLoad` we replace our previous code with:
```swift
      // In the MVC design architecture, a view controller should only coordinate model data to the views
      if let instaCatsAll: [InstaCat] = InstaCatFactory.makeInstaCats(fileName: instaCatJSONFileName) {
          self.instaCats = instaCatsAll
      }
```

---
### 2. The Internet and the Universality of URLs

Start out by adding the following line to your tableviewcontroller:
```swift
  internal let instaCatEndpoint: String = "https://api.myjson.com/bins/254uw"
```
(Plug in the URL into your browser too, just to see what comes up)

A fundamental principal in computer systems architecture is coming to the understanding that the "internet" is just a lot of interconnected computers. And what I mean by that is, every image you've ever viewed, every video you've ever watched, and every website you've visited are files that live on someone else's computer, that you were accessing with your own. 

That's why when you plug in that URL into a browser, you're seeing exactly what you would see in a file called `254uw.json` if it lived on your computer. A URL describes where a file is, whether that's on your computer or on someone else's on the internet. In this case, there is a service called "myjson" that hosts json files that you create. The one we're looking as is one that I made using the same data/file as `InstaCat.json`

> In fact, if you located the `InstaCat.json` file that lives on your computer and dragged it into your browser window, the address bar would change to the URL of the file's local address, and you'd see the same data. 

To locate files in our application's bundle we used `Bundle.main` to query for the data at a **local** `URL`. 

To locate a file on the internet, we need to use `URLSession` to query for the data at a **remote** `URL`. 

---
### 3. URLSession 
To our `InstaCatFactory`, add 

```swift
class func makeInstaCats(apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
  }
  
}
```

Every web request begins with a `URLSession`, which gets instatiated with a specified `URLSessionConfiguration`. 
  - For our purposes, we will only ever use `URLSessionConfiguration.default`

```swift
class func makeInstaCats(apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {

    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  }
  
}
```

We then use the `dataTask(with:)` method of `URLSession` to initiate our request

```swift
class func makeInstaCats(apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  
    // 2. dataTaskWithURL
    session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
    
    }
  }
}
```
>  Why all the optionals in `dataTask(with:)`? Well, you might not get `Data` back if the request is bad, you might not get a response if the internet is down, or you might not get an `Error` is everything goes right.


Best practices says to check for errors first

```swift
class func makeInstaCats(apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  
    // 2. dataTaskWithURL
    session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
    
      // 3. check for errors right away
        if error != nil {
          print("Error encountered!: \(error!)")
        }
    }
  }
}
```

At this point, we could check to see if we have any data being returned and print it out...

```swift
class func makeInstaCats(apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  
    // 2. dataTaskWithURL
    session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
    
      // 3. check for errors right away
      if error != nil {
        print("Error encountered!: \(error!)")
      }
    
      // 4. printing out the data
      if let validData: Data = data {
        print(validData)
      }
    }
  
  // 4a. ALSO THIS!
  }.resume()
}
```
You're almost always going to forget to add `.resume()` at first and until you call it, the `dataTask` won't actually execute. 

Anyhow that doesn't give us much information as the data is still in its raw encoded form. Now, in theory the `Data` we're getting back is *exactly* the same at if we were accessing the data from `InstaCat.json`... soo... 

```swift
class func makeInstaCats(apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  
    // 2. dataTaskWithURL
    session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
    
      // 3. check for errors right away
      if error != nil {
        print("Error encountered!: \(error!)")
      }
    
      // 4. printing out the data
      if let validData: Data = data {
        print(validData)
        
          // 5. reuse our code to make some cats from Data
          let allTheCats: [InstaCat]? = InstaCatFactory.manager.getInstaCats(from: validData)
      }
    }
    
  // 4a. ALSO THIS!
  }.resume 
}
```

Now, we just need to return the `[InstaCats` with `return allTheCats`...

`Unexpected non-void return value in void function`

Almost. 

---
### 4. Callbacks

Networks can be unreliable, especially on a mobile device. 
- explain request cycle (request, response, repeat)
- slow connects result in longer loading times, but once the data is retrieved it's loaded on screen
- a loading sign indicates that a request has not yet processed
- but while that request is happening, you phone is doing its own thing while waiting for the response to come 
- when the response arrives, your phone is alerted and the UI is updated
- To work with asynchronous network requests, we need to make use of closure callbacks. 
- As you recall, closures are just functions. using a closure as a callback we can delay execution of some function until we're notified that we have the data ready. 

```swift
    class func makeInstaCats(apiEndpoint: String, callback: @escaping ([InstaCat]?) -> Void) {
    } 
```

Now with the function updated to use a callback closure, we can finish:

```swift
class func makeInstaCats(apiEndpoint: String, callback: @escaping ([InstaCat]?) -> Void) {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  
    // 2. dataTaskWithURL
    session.dataTask(with: validInstaCatEndpoint) { (data: Data?, response: URLResponse?, error: Error?) in
    
      // 3. check for errors right away
      if error != nil {
        print("Error encountered!: \(error!)")
      }
    
      // 4. printing out the data
      if let validData: Data = data {
        print(validData)
        
          // 5. reuse our code to make some cats from Data
          let allTheCats: [InstaCat]? = InstaCatFactory.manager.getInstaCats(from: validData)
          
          callback(allTheCats)
      }
    }
    
  // 4a. ALSO THIS!
  }.resume 
}
```

To verify all is working, back in `viewDidLoad`, comment out the code for getting our local `InstaCat` and add in: 

```swift
        InstaCatFactory.makeInstaCats(apiEndpoint: instaCatEndpoint) { (instaCats: [InstaCat]?) in
            if instaCats != nil {
                for cat in instaCats! {
                    print(cat.description)
                    
                    self.instaCats = instaCats!
                }
            }
        }
```

Awesome! The data printed out to console.. but nothing showed up in our table view? You just met one of the biggest issues you'll encounter with network calls: updating your UI when your data is ready. Here's the most common way to update your UI following an asynchronous network request:

```swift
  DispatchQueue.main.async {
    self.tableView.reloadData()
  }
```

**For now, just know that this is what you need to do: wrap up your UI-updating code in `DispatchQueue.main.async`**

---
### 5. Exercise


