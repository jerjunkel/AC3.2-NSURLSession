### AC3.2 `NSURLSession / URLSession`
---

### Readings:
1. [`URLSession` - Apple](https://developer.apple.com/reference/foundation/urlsession) (just the "Overview section for now")
2. [Move from NSURLConnection to Session - Objc.io](https://www.objc.io/issues/5-ios7/from-nsurlconnection-to-nsurlsession/)
3. [Fundamentals of Callbacks for Swift Developers](https://www.andrewcbancroft.com/2016/02/15/fundamentals-of-callbacks-for-swift-developers/)
4. [Concurrency - Wiki](https://en.wikipedia.org/wiki/Concurrency_%28computer_science%29)
5. [Concurrency - Objc.io](https://www.objc.io/issues/2-concurrency/concurrency-apis-and-pitfalls/)
6. [Concurrency’s relation to Async Network requests (scroll down)](https://www.objc.io/issues/2-concurrency/common-background-practices/)
7. [Great talk on networking - Objc.io](https://talk.objc.io/episodes/S01E01-networking) (a bit advanced! uses flatmap, generics, computed properties and closure as properties) 

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
  4. Since we want to treat our factory as a "black box", we make some of the functions we used last time to be `fileprivate`, meaning the scope of those functions are limited to the `.swift` file they are in. 
  

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

To our `InstaCatTableViewController`, add 
```swift
    func getInstaCats(from apiEndpoint: String) -> [InstaCat]? {
      if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {
  
      }

    }
```

Every web request begins with a `URLSession`, which gets instatiated with a specified `URLSessionConfiguration`. 
  - For our purposes, we will only ever use `URLSessionConfiguration.default`

```swift
func getInstaCats(from apiEndpoint: String) -> [InstaCat]? {
  if let validInstaCatEndpoint: URL = URL(string: apiEndpoint) {

    // 1. URLSession/Configuration
    let session = URLSession(configuration: URLSessionConfiguration.default)
  }
  
}
```

We then use the `dataTask(with:)` method of `URLSession` to initiate our request

```swift
func getInstaCats(from apiEndpoint: String) -> [InstaCat]? {
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
func getInstaCats(from apiEndpoint: String) -> [InstaCat]? {
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
func getInstaCats(from apiEndpoint: String) -> [InstaCat]? {
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
        print(validData) // not of much use other than to tell us that data does exist
      }
    }
  
  // 4a. ALSO THIS!
  }.resume()
}
```
You're almost always going to forget to add `.resume()` at first and until you call it, the `dataTask` won't actually execute. 

Anyhow that doesn't give us much information as the data is still in its raw encoded form. Now, in theory the `Data` we're getting back is *exactly* the same at if we were accessing the data from `InstaCat.json`... soo... 

```swift
func getInstaCats(from apiEndpoint: String) -> [InstaCat]? {
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

Now, we just need to return the `[InstaCats]` with `return allTheCats`...

`Unexpected non-void return value in void function` (screenshot)

Almost. 

Hmm, ok look like we can't `return` from this block because the functions signature isn't expecting it. We're going to need to make some changes to the function to have it function correctly. For one, we can remove the `return` value and just do our updating work in the tableview controller directly.

```swift
  func getInstaCats(from apiEndpoint: String) { // <<< returns Void
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
        
        // 6. if we're able to get non-nil [InstaCat], set our variable and reload the data
        if let allTheCats: [InstaCat] = InstaCatFactory.manager.getInstaCats(from: validData) {
          self.instaCats = allTheCats
          self.tableView.reloadData()
        }
      }
      }.resume() // Other: Easily forgotten, but we need to call resume to actually launch the task
    }
  }
```

And lastly, add this to `viewDidLoad`:

```swift
  self.getInstaCats(from: instaCatEndpoint)
```
Rerun the project... Awesome! The data printed out to console.. but nothing showed up in our table view? You just met one of the biggest issues you'll encounter with network calls: updating your UI when your data is ready. Here's the most common way to update your UI following a network request:

```swift
    // update the UI by wrapping the UI-updating code inside of a DispatchQueue closure
    DispatchQueue.main.async {
      self.tableView.reloadData()
    }
```

**For now, just know that this is what you need to do: wrap up your UI-updating code in `DispatchQueue.main.async`**

All should be well now: your request is made, data is retrieved and your tableview's UI reloads. But you might be left with some questions:

1. Why didn't we follow the MVC design pattern and put this in `[InstaCatFactory]`?
  2. If we do move this into `[InstaCatFactory]`, how do we get the `[InstaCat]` array to the table view controller if we can't return a value?
3. Why do we need to update the UI in such a special manner? 

---
### 4. Out of Order Operations (Concurrency)

Concurrency in computer science refers to _order independent execution and handling_. More importantly, it also says that although the actions you take are out of order, you always get the same expected results at the end.

For example, if you need to cook a pasta dish you could follow these broard instructions: 

1. Add water to a pot, turn on the heat. 
2. **Wait**
3. When it starts boiling, add the pasta
4. **Wait**
5. Strain the pasta when its done cooking

But doing things one after another like this, referred to as _serial_ execution, would take a very long time, despite the guarantee that everything necessary will be done by a certain time. Not only would it take a long time, there would be stretches of time where you were doing _nothing_... just standing there, staring at a pot of water. A much more efficient way of doing is through doing _concurrent_ operations:

1. Add water to pot, turn on heat
2. **While** water comes to a boil, chop ingredients for sauce
3. Add pasta to boiling water
4. **While** the the pasta cooks, add sauce ingredients to a pan 

And if you have multiple burners on your stove, then it makes even more sense to do things in a concurrent manner.
 
Well, computers kind of work the same way. It used to be that computers only had one "burner" (called a "single core" processor) available but now they have many more at their disposal ("multi-core" processors). The purpose of this is to do as many things as possible at the same time and allow the computer to bounce between tasks as needed.

---
### 5. Network Reuqests are Asynchronous 

Networks can be unreliable, especially on a mobile device. And even when the network connection is good there's still a non-trivial amount of time needed for content, especially images and video, to load. Though, while that loading takes place your phone is still working, doing hundreds of other things. Though when the image or video finally does load, it appears on screen and you continue your browsing. In other words, thanks to concurrency your phone continue to add things to its burners while one of them waits for the "water" to boil. 

More specifically, when we talk about concurrency in networking requests, it’s usually in the realm of **asynchronous** requests. An asynchronous request is similar to concurrency in that you start it, go do something else for a little bit, and then you get alerted when it is finished. In a kitchen, you may ask your sous chef to go prep some onions for your pasta sauce while you do something else. Then once they finish chopping, you get the chopped onions back. You don’t know exactly how long this is going to take the chef; you just know you need the onions and you can’t stop everything else you’re doing while you wait for them.
 
Concurrency is a complicated topic, but Objective C and Swift make great strides towards you not having to worry about it too much. But, making network requests are always going to be done asynchronously because you can't stop other things your app is doing in order to wait for an unknown amount of time for a request to finish. You don't cook in serial, a restarant doesn't cook only one dish at a time, and your app will never only do one thing at a time. 

#### The Network Cycle

At a very basic level, a network request follows the following steps:

1. `Request` is made
2. `Response` is received after some time
3. Application responds to response (either `success` or `failure`)
4. Execution continues (another request could start, or an error alert shown if there was a problem)

#### Callbacks

A common pattern to "listen" for **network** responses is through the use of closures, referred to as **callbacks**. You already know that you can pass functions as a parameter to another function; that's in essence all callback are. The twist here is that your closure is intended to be executed once your network request receives its response. So, it "waits" for the response to be retrieved while your app continues executing other code. Not only this, but it's important to think about this: the "lifetime" of the closure you pass into a function in this manner can "outlive" the "lifetime" of the function it's being passed to. In other words, this **closure** enters a time machine where time stands still until the network request finishes. In the meanwhile, the rest of the function goes through each line of its code and finishes execution, unaware of the closure in the time machine. When the network call does finish, the **callback** gets the results and exits the time chamber. 

Let's now look at how this affects our current project

---
### 6. Updating `getInstaCats(apiEndpoint:) to use a callback

The syntax is going to take a little getting used to, but in effect what we're doing is taking the previous return value (`[InstaCat]?`) and make it the single parameter in a closure that returns `Void`. 

```swift
  // original
  func getInstaCats(apiEndpoint: String) -> [InstaCat]? {
  }
  
  // updating with no return
  func getInstaCats(apiEndpoint: String) {
  }

  // with callback
  // closure with single parameter of [InstaCat], returning nothing. function now returns nothing
  // ****** just know for Swift 3, you need to include that `@escaping` keyword for callbacks *****
  // ****** if you forget it, don't worry, Xcode will give you an error and ask to correct it for you ******
  func getInstaCats(apiEndpoint: String, callback: @escaping ([InstaCat]?) -> Void) {
  }
```

Now with the function updated to use a callback closure, we can finish:

```swift
func getInstaCats(apiEndpoint: String, callback: @escaping ([InstaCat]?) -> Void) {
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
        self.getInstaCats(apiEndpoint: instaCatEndpoint) { (instaCats: [InstaCat]?) in
            if instaCats != nil {
                for cat in instaCats! {
                    print(cat.description)
                    
                    DispatchQueue.main.async {
                       self.instaCats = instaCats!
                       self.tableview.reloadData()
                    }
                }
            }
        }
```

---
### 5. Exercise

(Proof of concept)
Add a `print` statement on the line just after `}.resume` along with a `print` statment just before you call `callback(allTheCats)`. Check to see which one gets printed first to console. This should help illustrate how the closure "outlives" the function.

(Warm up)
As we've learned, our callback extends the lifetime of the closure until at least the network requests finishes (in error or success). It's also what allows us to call this function from other classes. For this first exercise, refactor the code for `getInstaCat(from:callback:)` and move it into `InstaCatFactory` as a `class func`

