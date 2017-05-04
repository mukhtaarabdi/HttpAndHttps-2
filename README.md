
this ios app benchmarks the http/2 against the old http.1.x
This project is part of thesis work in Nanjing university of science and technology(NJUST). 


### Overview
* Until recently, testing the performance impact of H2 has been largely
  speculative because there were very few existing reliable implementations of
  the protocol for both server side and for client side.
* This is starting to change, as evidenced here [link to implementations wiki].
* However, there is still not good performance data as it relates to _mobile
  phones_, which were indeed a major motivation for creating HTTP/2 in the
  first place.


#### Server
* We wanted to make sure the same framework would be used for both our H1 and
  H2 experimental trials.
* For this reason, Our app can communicate any designed server without problem.

#### Client
* Apple's iOS 9 contains a (private) implementation of HTTP/2 which is used
  automatically [via _ALPN_] when the server says it's
  available.
  * I found [some code](github.com/FGoessler/iOS-HTTP2-Test) that allows one to
  selectively choose which H-vrsn to use based on whether you use
  `NSURLConnection` (no H2) or `NSURLSession` (H2 in > iOS 9)
* However that code is kind of overly-complicated, and I want to use
  `Alamofire` and `SwiftyJSON` instead.
* So I'm going to start a new project, and leave it up to the _server_ to
  decide which protocol I should use, based on the port that the request comes
  in on.
* So I need a wrapper method `instrumentedGET(urlAndPort)``

  ##### Try again
* The new plan is to use the following code
  ```swift
  @IBOutlet var myWebView: UIWebView!
  func displayURL() {
    // let myURL = NSURL(string: "https://localhost:8443/index.html")
    let myURL = NSURL(string: "http://www.wired.com")
    let myURLTask = NSURLSession.sharedSession().dataTaskWithURL(myURL!) {
      (data, response, error) in
      if error == nil {
        var htmlString = NSString(data: data, encoding: NSUTF8StringEncoding)
        self.myWebView.loadHTMLString(myHtmlString as! String, baseURL: nil)
      }
    }
  }
  ```
* __But what does it all even mean??__

###### [NSURLSession](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/)

* Provides an API for downloading content
* Supports authentication and background downloads while app is suspended
* Supports `http` and `https` among others
* The place to start is apparently [here][url-loading]
* There is a lot there
* It seems like I need to implement `NSURLSessionDataDelegate` and plug into
  the `URLSession(_:dataTask:willCacheResponse:completionHandler:)` as well as
  the `URLSession(_:dataTask:didReceiveData:)`.
* Or _probably_, it should be `NSURLSessionDownloadDelegate`, for which I plug into `
  URLSession(_:downloadTask:didWriteData:totalBytesWritten:totalBytesExpectedTo
  Write:)` and `URLSession(_:downloadTask:didFinishDownloadingToURL:)`


[url-loading]: https://developer.apple.com/library/ios/documentation/Cocoa/Conceptual/URLLoadingSystem/URLLoadingSystem.html#//apple_ref/doc/uid/10000165i

##### Caching
* This is one of those things that could easily get pretty frustrating to deal
  with
* Check out what's going they're doing in the [relevant Alamofire unit
  tests][cachetests]

[cachetests]: https://github.com/Alamofire/Alamofire/blob/c634f6067f0b5a59992a10bbd848203aa1231ff6/Tests/CacheTests.swift

### The actual experimental condition
* We can't ask questions about server push, because according to the Tweeters,
  it is disabled in `NSURLSession` anyways.
    * This is a _real_ frickin bummer.
* In any case, we should keep in mind that the HSIS people found that the case
  in which H2 _worse than_ H1 was under conditions of __transmitting large
  objects over a high-loss connection__.
* So how about we have two `html` files, one has many _small_ resources, and
  one has many _large_ resources.
    * We expect that due to the multiplexability of H2, the small resources
      should perform better in that scenario.
    * As a way to try to replicate the effects seen in HSIS, we expect the
      large resources' condition to give the edge to H1.
      
     # Pseudocode
     
     ## HttpExperiment

```swift
button.fire {
    bg.thread {
        HttpBenchmarker.go()
    }
}

class HttpBenchmarker {
    func go() {
        for vrsn in [1, 2] {
            for rep in 1...numReps {
                EventedHttp(
                    httpVrsn,
                    index: i,
                    iphoneDisplay: screenRef,
                    resultMgr: self
                ).go()
                sema.down()
            }
        }
    }
}

class EventedHttp: Benchmarker, DownloadDelegate {
    func collectResult(forIndex i: Int) {
        let session = NSURLSession(config: myConfig, delegate: self)
        session.resetThen {
            note(Open)
            session.downloadTask(url).resume()
        }
    }
    Download.handle {
        case Finished:
            note(Closed)
            resultMgr.addResult(notes, index: i, release: true)
    }
}
```
