# API Design in C++

I've been thinking about API design for about 15 years, since I started reading library reviews on Boost mailing lists around 2008. Everything I'll share here is based on my personal experience.

In the first part, I will focus on basic concepts that are applicable to almost any imperative programming language, not just C++. There will also be a part 2, about C++ specifically, where I will talk about C++ language features and standard library utilities that will help you make your APIs even better.


# Software Architecture

First, let's talk about software architecture. When talking to engineers today, the word "architecture" is often associated with whatever the Big Tech companies are expecting you to do a System Design interview — e.g. building a service using Kafka, Redis, and PostgreSQL to move JSONs around.

Today, we will talk about architecture at a lower level — the architecture of a single program or a service.

Have you ever been in a situation where you have implemented a feature, didn't quite like the code you ended up with, then proceeded to pile more features on top of it, each next feature being progressively harder and harder to implement, with you having to insert questionable hacks all over the codebase to make it all work, only to go for a walk one Friday evening after a hard week of chasing down bugs that, you feel, should not even be there, and suddenly start questioning your life choices? "Adding a button should **not be so damn hard**," you say to yourself, as you're trying to pin down the source of the uneasy feeling that there should be simpler ways to do what you're doing, and you're just missing something very obvious. But what is it?

You don't have much time to contemplate the answer as you get a call from your product manager. "The requirements... have changed," he says gravely. You feel the darkness closing in around you, an all-encompassing dread slowly creeping up your spine. "Damn, it will be easier to throw away the whole damn thing that I've been working on for the past month and start from scratch than trying to fix it!"

Sounds familiar? This is what happens when you never think about software architecture.

Architecture is a bird's-eye view of your software. For example, if you're writing a graphic editor, you will likely need to write code for saving and loading various image formats, undo/redo functionality, various filters, and so on. Architecture is about connecting all these pieces of code into a cohesive whole to create a flexible set of tools for you as an engineer.

How does architecture that is thoughtfully designed differ from architecture that has evolved on its own, like life in a pot of macaroni you've left on your balcony last month? And what is "good architecture," anyway? I like the [take](https://gameprogrammingpatterns.com/architecture-performance-and-games.html) from the author of Game Programming Patterns:

> What is *good* software architecture?
>
> For me, good design means that when I make a change, it’s as if the entire program was crafted in anticipation of it. I can solve a task with just a few choice function calls that slot in perfectly, leaving not the slightest ripple on the placid surface of the code.
>
> That sounds pretty, but it’s not exactly actionable. “Just write your code so that changes don’t disturb its placid surface.” Right.
>
> Let me break that down a bit. The first key piece is that architecture is about change. Someone has to be modifying the codebase. If no one is touching the code — whether because it’s perfect and complete or so wretched no one will sully their text editor with it — its design is irrelevant. The measure of a design is how easily it accommodates changes. With no changes, it’s a runner who never leaves the starting line.

There is a lot to unpack here:
* Good architecture helps you quickly understand the code. This requires minimizing the number of abstractions and moving parts that you need to keep in working memory when writing new or modifying existing code.
* Good architecture helps with the locality of changes. Have you ever had to add a dozen or two if-statements throughout the entire codebase to implement a new feature? This is an example of a non-local change.
* Good architecture helps you write bug-free code.
* If you do introduce a bug, good architecture helps you find it quickly.
* Good architecture finds a balance between flexibility and simplicity. You've probably been involved in projects where developers went overboard with *over-architecting* — this often happens when product requirements are unclear, and engineers try to prepare for every possible scenario, losing the sight of the product they're working on in the process.
* Good architecture helps you ship faster.

Most importantly, good architecture meets external requirements. For example, if you're writing a prototype, software architecture shouldn't even be on your mind — you simply need to quickly hack together something that works. You might throw away the prototype later.

In my opinion, you should think about architecture if:
* You're writing code that will live long and will be used by many.
* You're writing library code.
* You tend to *over-architect* uncontrollably and want to learn to do it in a controlled manner.

The question of investing developers' efforts in good architecture is essentially about whether these investments will pay off. It can be difficult to assess this without experience. Deciding not to invest time in architecture because it is not needed at the moment, and not investing in architecture because you don't understand how and why, are two very different situations. They might look the same to an outside observer, but in the first case, it's you who have made the call, and in the second case, everything just *happened by itself*. In this article, I will try to help you understand what steps to take to make your code better, so that you will more often find yourself in situations where you could make informed decisions on program architecture.

> 📝 I won't teach you how to decide whether it's worth it investing your time and effort in a better architecture — it's a separate complex topic. My goal here is to help you avoid situations where the decision *happens by itself*, teach you to see problems at the API level before they start causing you pain, and help you better understand what needs to be done to avoid these problems.


# What is API Design?

The concept of API design is closely related to the concept of software architecture.

If architecture is about a bird's-eye view of your software, then API design is about the zoomed-in view. API design governs what happens between the individual components of the system – how do you connect components A and B, how do you write code so that you don't end up chasing bugs into wee hours, and so on.

Architecture is something you really think about only when designing or redesigning your software, and when making global refactorings. API design should be something you think about every day. Every time you write a new function signature, you are designing an API. That is, if you're writing code, you are an API designer!

All the principles of good software architecture translate neatly into the principles of API design.


# Why Do We Need Good APIs?

Here are two links:
* [The Wonderfully Terrible World of C and C++ Encoding APIs (with Some Rust)](https://thephd.dev/the-c-c++-rust-string-text-encoding-api-landscape).
* And its continuation — [cuneicode, and the Future of Text in C](https://thephd.dev/cuneicode-and-the-future-of-text-in-c).

If you follow these links, you will find a member of the C and C++ standards committee passionately *dunking* on badly designed libraries. Many people have an aversion to the phrase "C++ standards committee" — they immediately picture a gathering of bearded old men constantly standardizing something, and each time the result is something out of touch with reality. The author of the article belongs to both camps and has decided to constructively address his struggles — "if the committee is doing a poor job, I'll join the committee myself and teach them how it should be done!" Recently, he [introduced](https://open-std.org/JTC1/SC22/WG14/www/docs/n3017.htm) `#embed` in C.

He's passionately critical because, despite it being 2023, we  still no proper library for working with different encodings, and we still sometimes see something like this:

![Ooooof....](https://habrastorage.org/webt/io/bc/3v/iobc3vnemsgv93nwfv3h50thkni.png)

The problem in the screenshot is deeper and more multifaceted than the simple absence of a library for working with different encodings, but at the root of the problem are poor APIs.

Poor APIs are also at the root of many other problems in the [National Vulnerability Database](https://nvd.nist.gov/). Often, it starts with code like this:
```cpp
char buf[1024];
```

And ends with code like this:
```cpp
// Checking string size is for retards!
strcpy(buf, totally_safe_string);
```

`strcpy` is a typical example of a broken API that cannot be fixed, only discarded. This function is [over 40 years old](https://stackoverflow.com/questions/25300040/is-it-possible-to-find-out-when-the-current-syntax-of-strcpy-was-added-to-the-c), continues to be used, and still [causes issues](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=strcpy).

But I can already hear your objections. An API deep within the standard library? Broken `strcpy`? I handle JSON data and can't even remember the last time I wrote a `strcpy` call manually, what does this have to do with me?

It's very simple. You have colleagues who use your code just as we all use the standard library. They get frustrated in the same way when they try to reuse something you wrote without thinking about making your API convenient. After struggling a bit, they decide to do the same thing but better in their own way. "No, we're not reinventing the wheel," they say when you find out about it and start asking uncomfortable questions, "it's just that the existing solution doesn't suit us." Of course, they don't think about API design either, and after a few years, your company ends up with five copies of the same functionality, spread out across various solutions. Team leads rightfully point out that you need more programmers to maintain this, and you get new colleagues who also don't think about API design. "Ah, if only we could throw everything out and rewrite it from scratch," you sigh over a beer with colleagues in a bar a few years later.


# API Design Rule #1
## Design APIs so they cannot be used incorrectly

The idea behind this rule is very simple — your code should either work correctly or terminate with an error (or an `assert`), and there should be no sequence of calls that can put your class (or module) into an incorrect state.

Moreover, the fewer ways your API can terminate with an error, the better! Why think about and handle errors if you can design an API that simply doesn't have them?

Let's look at a few examples.


### Example #1: Logging

For instance, suppose you are writing a wrapper around a logging library:
```cpp
class Logger {
public:
/**
* @param category      Log category name. Category must have a log level
*                      assigned (`setCategoryLogLevel` must be called
*                      first).
* @param level         Message log level.
* @param fmt, args     Log message.
*/
template<class... Args>
void log(std::string_view category, LogLevel level,
fmt::format_string<Args...> fmt, Args &&... args);

    /**
     * @param category      Log category name.
     * @param level         New log level for this category. Log messages with 
     *                      lower log level will be ignored.
     */
    void setCategoryLogLevel(std::string_view category, LogLevel level);
};
```

You want to catch typos in category names, so in the `log` method, you check that the category is already registered — you know that your colleagues have fat fingers and are bound to make typos. But there's a better way to do the same thing:
```cpp
class LogCategory {
public:
LogCategory(std::string_view name, LogLevel level);

    void setLogLevel(LogLevel level);

    // ...
};

class Logger {
public:
template<class... Args>
void log(const LogCategory &category, LogLevel level,
fmt::format_string<Args...> fmt, Args &&... args);

    // Don't do `log(LogCategory("blabla", LOG_INFO), ...)`, 
    // create a variable for your `LogCategory` and reuse it.
    template<class... Args>
    void log(LogCategory &&, Args &&...) = delete;
};
```

With this API, you immediately eliminate the problem of the user making a typo in the category name — there is nowhere to make a typo now! Only in the variable name of type `LogCategory`, which the compiler will catch.


### Example #2: CSV File Manager

Let's consider another example. Suppose you are writing some automation for machine learning, and unfortunately, all data is stored on disk in CSV files. The application's logic is that statistics are calculated from the CSV files, which are then used in the code, and the code can decide to update the CSV file. You decide to write a wrapper:

```cpp
struct CsvStats {
DateTime startTime; // First timestamp in CSV table.
DateTime endTime;   // Last timestamp in CSV table.
// ...
};

class CsvDb {
public:
explicit CsvDb(std::string_view path);

    std::string path(std::string_view tableName);

    CsvStats stats(std::string_view tableName);
    void setStats(std::string_view tableName, CsvStats stats);
};
```

> 📝 You might be wondering why all this is necessary. You could store the data in a database. You could live like a human and use industry-standard solutions — set up Hadoop and Spark, for example. Let's assume that in this example you need the most lightweight solution possible.

The `CsvDb` has a very simple interface — it allows you to get the full path to a table by its name, and it has getter and setter methods for the statistics. The statistics are saved on disk in some `db.ini` file and flushed after each call to `setStats`. It is expected that users of your wrapper will do something like this:
1. Get the statistics by the table name.
2. If the table lacks data, they will download it.
3. Get the path to the table file by calling `path` and merge the downloaded data into it.
4. Call `setStats` to update the statistics with the new data.
5. Use the updated table.

What can go wrong here? For example, the calculation of the statistics is entirely up to the user, and merging the table and updating the statistics is not an atomic operation.

How can we make this better:

```cpp
struct CsvStats {
DateTime startTime;
DateTime endTime;
// ...
};

class CsvDb {
public:
explicit CsvDb(std::filesystem::path path);

    CsvTableReader open(std::string_view tableName);
    CsvTableWriter replace(std::string_view tableName);

    CsvStats stats(std::string_view tableName);
};

// Skipping CsvTableReader & CsvTableWriter for brevity.
```

What's changed:
* Now, the user of our interface knows nothing about the files.
* The statistics are calculated and saved inside `CsvTableWriter`. The user does not need to do this themselves.
* The interface better reflects the essence of what's happening — `open` and `replace` are essentially getter and setter methods for individual tables, and the setter can now be implemented so that the table and its statistics are updated atomically. The previous version of the API focused on getter and setter methods for the statistics.

However, we now have 4 classes instead of two. This should give you something to think about!


# API Design Rule #2
## Divide & Conquer

You are probably familiar with the acronym SOLID. I must admit, I have never been able to remember what all the letters stand for, but I remember two of them very clearly. Even if you wake me up in the middle of the night, I can confidently tell you that S stands for Single Responsibility, and L stands for Liskov Substitution.

The S in SOLID actually represents a profound idea. The original rule states, "there should never be more than one reason for a class to change," which means that the responsibilities of classes should be very small. Therefore, the classes themselves should also be small.

Why are small classes good? Let's think about how you actually write code:
1. First, you need to understand the task — what functionality you want to implement.
2. Then, you need to understand the context — literally, load all the code you need to change into your head and any code that the new functionality will depend on.
3. After that, you need to come up with a solution — *how* you will change the code that is now in your head.
4. Finally, type on the keyboard.

Often, the real complexity lies not in step 4. If you work with large classes, they don't fit into your working memory. You either struggle and spend more time than you could have, or you introduce bugs.

Moreover, within a class, there are no boundaries; all fields are accessible from any method, and the number of possible interactions between parts of the class grows **quadratically** with the size of the class. As the number of interactions increases, so does the number of bugs.

By breaking classes into smaller pieces, you set boundaries where they logically belong, reduce the number of possible interactions, organize existing interactions, and thus make your life easier — small classes are easier to read and understand.

The same applies to libraries. Classes in a "class dump" start to depend on each other, leading to a quadratic growth in dependencies and bugs. Break your code into small libraries! The same logic applies to functions — there’s a reason why everyone criticizes functions that span 10 screens.


### Example #3: Parsing String Data

This is real code from one of my projects. Suppose you have null-terminated strings in binary form in a file, and you need to load them into memory. You already have code like this:

```cpp
/**
* @param buffer            Input buffer to parse, contains null-terminated
*                          strings.
* @param[out] result       Parsed strings.
  */
  void parseStrings(const Buffer &buffer, std::vector<std::string> *result) {
  size_t pos = 0;                                                        
  while (pos < buffer.size()) {
  // Extract the next string.
  const char *nextPos = static_cast<const char *>(memchr(buffer.data() + pos, '\0', buffer.size() - pos));
  size_t size = (nextPos ? nextPos - buffer.data() : buffer.size()) - pos;
  std::string str = std::string(buffer.data() + pos, size);

       // Remove quotes if the string is quoted.
       if (str.size() >= 2 && str.front() == '"' && str.back() == '"')
           str = str.substr(1, str.size() - 2);

       // Store result & advance.
       result->push_back(std::move(str));
       pos += size + 1;
  }
  }
  ```

You've probably seen similar code many times. What's wrong with it? For one, it is not immediately clear to an unprepared reader what happens in the first three lines inside the loop. Just try to read it carefully — do you even remember what `memchr` returns?

The same code can be written much more clearly by introducing a few abstractions:

```cpp
void parseStrings(const Buffer &buffer, std::vector<std::string> *result) {
MemoryInput input(buffer);

    std::string line;
    while (input.readLine(&line, '\0'))
        result->push_back(unquote(line));
}
```

The new function does the same thing as the old one, but unlike the old one, the code is now written in a way that makes it immediately clear what is happening in this function. We achieved this by introducing two new entities:
1. The `MemoryInput` class, which handles streaming reads from a memory segment.
2. The `unquote` function, which removes quotes.

Both the class and the new function can now be covered with tests and reused in other places.

The refactoring can be seen as breaking our solution into *layers of abstraction*. For convenient streaming reads from memory, we needed an appropriate abstraction — we separated it into a class with a clearly defined interface, and now we interact with memory only through this interface. This interface divides our code into *layers* — the code lower in the stack works with raw memory, and the code higher up works with a more high-level interface.

Overall, this is a very good approach to API design. If you see complex code:
1. Think about what abstractions you are missing.
2. Separate them into distinct entities and divide your code into layers using them.

> 📝 If you go a bit further, it becomes clear that this code shouldn't exist at all. If you have null-terminated strings in a file, just map the file into memory and create an array of `std::string_view` that point to that memory. Even better — if you don't have hundreds of thousands of strings, just store them in some human-readable format for which smart people have already written parsers. JSON, TOML, INI, YAML, CSV, Prototext, etc.


### Example #4: QFuture

Let's take a look at a real-life example from the Qt library — the `QFuture` class. It's essentially an enhanced version of `std::future`, an abstraction over asynchronous computation. The interface looks something like this:

```cpp
template<class T>
class QFuture {
public:
QFuture(const QFuture &other);

    const_iterator begin() const;
    const_iterator end() const;
    QList<T> results() const;

    void cancel();
    T takeResult();
    T result() const;

    template<class Function>
    auto then(Function &&function);
    template<class Function>
    auto then(QThreadPool *pool, Function &&function);
    template<class Function>
    auto then(QObject *context, Function &&function);

    bool isCanceled() const;
    bool isFinished() const;
    bool isRunning() const;
    bool isStarted() const;
    bool isValid() const;

    // ...
};
```

What are the problems with this interface:
* `QFuture` is a ref-counted class, so essentially `QFuture` is analogous to `std::shared_future`.
* On the other hand, `QFuture` has a `takeResult` method, which clearly doesn't fit into the concept of `std::shared_future`.
* `begin` / `end` are about a channel / asynchronous sequence.
* The `then` method with one argument is fundamentally broken — you have no way to guarantee that the function passed to `then` won't be called directly in the same thread where you called `then`.
* The `then` method taking a `QObject *` as a context doesn't work as an experienced Qt user might expect — unlike `QObject::connect`, `QFuture::then` doesn't track the lifetime of the passed object, and it will crash if the passed object is destroyed before the continuation is called.
* The large number of `isXYZ` methods provide access to the current state of the object, but even the documentation doesn't clarify which states are mutually exclusive and which are not. If the states are mutually exclusive, it's better to provide a single `state()` method.

In general, `QFuture` tries to be everything at once. This desire has a significant downside, and you will see it if you try to read the source code — `QFutureInterfaceBasePrivate` has as many as 20 fields, and keeping track of what's happening there is very difficult.

Moreover, if you read the source code and try to come up with a name for this class that accurately reflects its functionality, you won't be able to. And this should make you think.

<!-- About QFuture::then(QObject*) - it asserts with QPointer<QObject> internally because the call happens through 
     QMetaObject::invoke. So it will crash even if you don't use the object itself.

     About QFuture::then - yes, I double-checked, then can indeed execute in place. 
     boost::future is smarter - it preserves context, so even if the computation is complete, 
     the continuation will still be run in a pool. But this doesn't work if the launch_policy is set to deferred - 
     in this case, then is executed in place, and the calling side doesn't know which policy was set. 
     So boost::future::then is also broken, just in a different way. -->


# API Design Rule #3
## Spend Time Thinking of Good Names!

As is well known, there are only two hard problems in Computer Science — cache invalidation and naming things. This joke contains a lot of truth — if you can't come up with a good name for something, it often means you're trying to do something weird, and you need to rethink your design.

Before naming, take the time to formulate the conceptual essence of the abstraction you need to name. Don't succumb to temptations — nobody will be happy with yet another class ending in `Helper`. If you still can't come up with a name, use [thesaurus.com](https://www.thesaurus.com/) or [ChatGPT](http://chat.openai.com/). If even after that you can't find a good name, it means you've come up with a poor abstraction. Think again.

### Continuing Example #4: QFuture

In the case of `QFuture` from the previous example, if you ask yourself the right questions, it will become clear that several abstractions are hidden within `QFuture` that should be separated:

```cpp
template<class T>
class QAsyncSequence {
public:
void cancel();
const_iterator begin() const;
const_iterator end() const;
QList<T> results() const;
// ...
};

template<class T>
class QUniqueFuture {
public:
QUniqueFuture(QUniqueFuture &&other);
void cancel();
T takeResult();
// ...
};

template<class T>
class QSharedFuture {
public:
QSharedFuture(const QSharedFuture &other);
QSharedFuture(QUniqueFuture<T> &&other);
void cancel();
T result() const;
// ...
};
```

`QAsyncSequence` is an abstraction over an asynchronous sequence, while `QSharedFuture` and `QUniqueFuture` are analogs of `std::shared_future` and `std::future`. The original `QFuture` had incorrect usage scenarios that led to runtime errors — for example, you could copy a `QFuture`, call `takeResult` on both copies, and crash with an `assert`. With the new interfaces, such code cannot be written!

It's important to note how we arrived at the new interfaces — we thought about *abstractions* rather than *classes*. This is a very important point — API design is primarily about working with abstractions. Translating abstractions into concrete interfaces is the final step in this work.

But back to `QFuture`. Earlier, I pointed out that the `QFuture::then` method with one argument is fundamentally broken — you have no way to guarantee that the function passed to `then` will be executed in the context of the operation whose result is provided by `QFuture`. If the asynchronous operation completes before `then` is called, the continuation will be called directly from within `then`, and this cannot be avoided.

> 📝 In practice, this is a rather rare scenario — usually, operations within `QFuture` are substantial, and you have time to attach the continuation via `then` before they complete. But the fact that such a simple scenario is fundamentally broken should give you pause.
>
> A keen reader may also notice that you could simply use `boost::future`, which *almost* doesn't have these problems. But the fact is that *almost* doesn't satisfy us — the `then` method with one argument is still broken, and the passed continuation can still be executed in the call site, although unlike `QFuture`, this is entirely deterministic and defined by the `boost::launch` policy with which this `boost::future` was created.

<!-- In boost::future, there is a private method launch_policy, and then creates a new future with the same launch policy.
     So even if the original computation is already completed, if launch_policy() = async, the continuation will be run in a separate thread. The problem arises when launch_policy() = deferred, in this case, the code is called directly from then(). And at the call site, we generally do not control what launch_policy will be set! Of course, you can peek at launch_policy(), but in reality,
     this means you simply should not use then with one argument. -->

These problems should make you think. In my opinion, `QFuture` and `std::future` are just bad abstractions. They combine in one interface an asynchronous operation and the context in which this operation is executed, leading to problems. Can it be done better?


### Example #5: Better than QFuture

A good practice in API design is to start with client code. If you don't know which API will be more convenient, first implement several usage examples without having a ready implementation of the API itself. This will help you understand which option best suits your requirements, and the written code can then be used for testing.

Suppose we need to implement an asynchronous operation that fetches and parses data from the network — for example, parsing Twitter. The user code could look like this:

```cpp
/**
* @param network           Network access object.
* @param opts              Fetch options - login, number of posts, etc.
* @return                  Async fetch task.
  */
  Task<TwitterPosts> fetchTwitterPosts(Network &network,
  const TwitterFetchOptions &opts) {
  Task<std::string> requestTask = network.request(makeRequestUrl(opts));

  return requestTask.then([](std::string_view jsonData) {
  TwitterPosts result;
  deserialize(Json::parse(jsonData), &result);
  return result;
  });
  }

void myAwesomeFunction(Network &network) {
// Download the latest 20 posts by Bjarne Stroustrup & print them.
TwitterFetchOptions opts("@stroustrup", 20);
TwitterPosts posts = fetchTwitterPosts(network, opts)
.run(globalThreadPool())
.join();
fmt::println("{}", posts);
}
```

Here, `Network::request` returns an object of type `Task` — an abstraction over an asynchronous operation, not tied to an execution context. Continuation support is implemented via the `Task::then` method, which also returns a `Task`. The `fetchTwitterPosts` function knows nothing about the execution context — it only contains the logic of the operation, while the context is passed to the `Task::run` method within `myAwesomeFunction` — in this case, the request is executed in the global thread pool.

The key point of the proposed API is the *orthogonality* of the abstractions we work with. Asynchronous operations are separate, execution contexts are separate. If desired, one could even implement a context that executes operations in separate *processes*, all without changing the code of the operations themselves.

Orthogonality is one of the key properties that abstractions in well-designed libraries possess.

> 📝 If you have used `boost::asio` or `Qt`, the code above may raise questions — for example, where is the event loop? Asynchronous operations can vary — you can wait for bytes to arrive over the network, or you can compute the MD5 of a 10-gigabyte file, and for the first example, a separate thread might not be necessary at all. There are no short answers to these questions; if you want to delve deeper into the subject, I recommend watching [Eric Niebler's talk on executors](https://www.youtube.com/watch?v=xLboNIf7BTg).


### Example #5: Better than QFuture

A good practice in API design is to start with client code. If you don't know which API will be more convenient, first implement several usage examples without having a ready implementation of the API itself. This will help you understand which option best suits your requirements, and the written code can then be used for testing.

Suppose we need to implement an asynchronous operation that fetches and parses data from the network — for example, parsing Twitter. The user code could look like this:

```cpp
/**
* @param network           Network access object.
* @param opts              Fetch options - login, number of posts, etc.
* @return                  Async fetch task.
  */
  Task<TwitterPosts> fetchTwitterPosts(Network &network,
  const TwitterFetchOptions &opts) {
  Task<std::string> requestTask = network.request(makeRequestUrl(opts));

  return requestTask.then([](std::string_view jsonData) {
  TwitterPosts result;
  deserialize(Json::parse(jsonData), &result);
  return result;
  });
  }

void myAwesomeFunction(Network &network) {
// Download the latest 20 posts by Bjarne Stroustrup & print them.
TwitterFetchOptions opts("@stroustrup", 20);
TwitterPosts posts = fetchTwitterPosts(network, opts)
.run(globalThreadPool())
.join();
fmt::println("{}", posts);
}
```

Here, `Network::request` returns an object of type `Task` — an abstraction over an asynchronous operation, not tied to an execution context. Continuation support is implemented via the `Task::then` method, which also returns a `Task`. The `fetchTwitterPosts` function knows nothing about the execution context — it only contains the logic of the operation, while the context is passed to the `Task::run` method within `myAwesomeFunction` — in this case, the request is executed in the global thread pool.

The key point of the proposed API is the *orthogonality* of the abstractions we work with. Asynchronous operations are separate, execution contexts are separate. If desired, one could even implement a context that executes operations in separate *processes*, all without changing the code of the operations themselves.

Orthogonality is one of the key properties that abstractions in well-designed libraries possess.

> 📝 If you have used `boost::asio` or `Qt`, the code above may raise questions — for example, where is the event loop? Asynchronous operations can vary — you can wait for bytes to arrive over the network, or you can compute the MD5 of a 10-gigabyte file, and for the first example, a separate thread might not be necessary at all. There are no short answers to these questions; if you want to delve deeper into the subject, I recommend watching [Eric Niebler's talk on executors](https://www.youtube.com/watch?v=xLboNIf7BTg).


# API Design Rule #4
## Create Orthogonal and Interchangeable Abstractions

In fact, most C++ developers use a library almost every day that is an excellent illustration of this rule in practice. Of course, I am talking about the STL.

The STL defines two key abstractions — iterators and algorithms. Most importantly, these abstractions in the STL are orthogonal, allowing, for example, the single implementation of `std::find_if` to work for both `std::deque` and `std::vector`.

In the STL, data is orthogonal to the logic that operates on that data, and this approach can be extended to many other domains. Every time you write code that seems like something you have written before, think — maybe you are missing the right orthogonal abstractions to simply reuse it. For reuse, choose the type of polymorphism that fits the task:
* Virtual functions and abstract base classes for dynamic polymorphism.
* Overload sets, templates, and concepts for static polymorphism.


### A Bit About Polymorphism

Static polymorphism in C++ is mostly associated with templates, so you might have stumbled over "overload sets" above. To understand this, we need to recall that polymorphism in C++ comes in two forms:
* Intrusive — requiring direct support in the class code.
* Non-intrusive — implying that you can "adapt" any class to the requirements without changing the class code.

Virtual functions and abstract base classes implement intrusive dynamic polymorphism.

Overload sets implement non-intrusive static polymorphism and rely on the fact that the static interface of a class includes not only the class methods but also free functions accessible through [argument dependent lookup](https://en.cppreference.com/w/cpp/language/adl). Classic examples are `operator<<` for stream output and the [`PrintTo` function from Google Test](http://google.github.io/googletest/advanced.html).

Intrusive static polymorphism simply requires methods in the class. This type of polymorphism is generally less flexible.

The last combo is non-intrusive dynamic polymorphism. A classic example is [`QVariant` from Qt](https://doc.qt.io/qt-6/qvariant.html) and the accompanying [`QMetaType`](https://doc.qt.io/qt-6/qmetatype.html). At its most primitive level, non-intrusive dynamic polymorphism is `std::unordered_map<std::type_index, void(*)(void *)>`, mapping from a type to some operation on an object of that type.

In C++, it's important to master all types of polymorphism to be able to choose the right tool for your task.


### Example #6: Writing a Roguelike

All this talk about "drawing inspiration from the STL" and "using the right type of polymorphism" can sound too abstract, so let's look at a concrete example.

Suppose you've played a lot of [ADoM](http://adom.de/) and decided to write your own roguelike RPG. Classic roguelike RPGs were known for their lack of graphics, huge amounts of content (hundreds of types of monsters and equipment), and incredible flexibility — [the DevTeam thinks of everything](https://nethackwiki.com/wiki/The_DevTeam_Thinks_of_Everything). Such variety comes at a price — if you don't think ahead about how to design the game model, the game's logic will be spread thinly across your codebase. Implementing a cursed runic sword that sometimes hits your allies and drains their souls becomes a matter of adding code in ten different places. Sound familiar?

But let's move on to the code. Suppose you started with a base class for any item in the game:
```cpp
class Equipment {
public:
virtual ~Equipment() = default;
virtual void onUse() = 0;

    // ...
};
```

Any item can be used, so the base class has an `onUse` method. This method probably needs some parameters, but let's skip those for now and think about other types of items:
```cpp
class Weapon : public Equipment {
public:
virtual void onAttack(Monster &monster) = 0;

    // ...
};

class VampiricSword : public Weapon {
public:
virtual void onAttack(Monster &monster) override {
Damage damage(this, DMG_PHYSICAL, _dice.roll());
monster.takeDamage(damage);

        if (damage.amount <= 1) 
            return;

        Damage healing(this, DMG_DARKMAGIC, damage.amount / 2);
        owner().heal(healing);
    }

    // ...

private:
Dice _dice;
};
```

"Damn, this looks *solid*!" you think, and start adding different types of armor:
```cpp
class Armor : public Equipment {
public:
virtual void onTakeDamage(Damage &damage) = 0;

    // ...
};
```

Now you need to implement a shield, but here's the catch — you can also hit enemies with a shield!
```cpp
class Shield : public Armor, public Weapon { // Eeeeeh?
// ...
};
```

And now you have a problem. You might remember that C++ has virtual inheritance, and it's even used in the standard library! So, making `class Equipment` a virtual base class solves the problem, right?

I have a simple rule on this topic — **never** use diamond inheritance and virtual base classes. If you need diamond inheritance, there's something wrong with your design. Usually, you can replace inheritance with various forms of composition, resulting in a more flexible and intuitively understandable design.

> 📝 Yes, this means that the standard input-output streams are poorly designed — it's true, they were brought into C++ when C++ was a very different language (and called Cfront). The first edition of [The C++ Programming Language](https://www.stroustrup.com/1st.html) was published in 1985, so you can estimate how old `<iostream>` is. Today, we have a much better understanding of good design, and modern C++ is very different from C++ of the 80s. The C++ standard library has its share of contentious decisions (hello `vector<bool>`, greetings `std::locale`), and it's not always a model to follow.

In the case of the game model for a roguelike RPG, you might be inspired by the [Entity Component System](https://en.wikipedia.org/wiki/Entity_component_system) and come up with something like this:
```cpp
class Event {
public:
explicit Event(EventType type) : type(type) {}
virtual ~Event() = default;

    const EventType type;

    // ...
};

class Behaviour { // Behaviours are composable pieces of event-handling logic.
public:
explicit Behaviour(Entity *owner): _owner(owner) {}
virtual ~Behaviour() = default;

    virtual void process(Event *event) = 0;

    // ...

protected:
Entity *owner() const {
return _owner;
}

private:
Entity *const _owner = nullptr;
};

struct Entity {
std::vector<std::unique_ptr<Behaviour>> behaviours;

    // ...
};
```

In this approach, you have events exchanged between objects and behaviours that can handle these events. Individual items are instances of the `Entity` class, and importantly, to implement various items, you don't need to inherit from `Entity`; all the logic is contained in `Entity::behaviours`.

> 📝 The provided implementation is quite far from modern ECS and doesn't address "how to optimally store data associated with items." We will store data inside `Behaviour` subclasses, violating the orthogonality of data and logic, but simplifying the examples. In practice, for something more complex, you would need to store data separately, as modern ECS frameworks do.

Now let's define the basic events we will need to implement `VampiricSword`:
```cpp
/**
* When performing an attack, this event is sent to the attacker's items to
* populate the damage rolls.
  */
  class AttackOutEvent : public Event {
  public:
  AttackOutEvent() : Event(EVENT_ATTACK_OUT) {}

  std::vector<Damage> damageRolls;

  // ...
  };

/**
* When performing an attack, this event is sent to the target's items to
* apply armor & protection.
  */
  class AttackInEvent : public Event {
  public:
  AttackInEvent() : Event(EVENT_ATTACK_IN) {}

  std::vector<Damage> damageRolls;

  // ...
  };

/**
* After a successful attack, this event is sent back to the attacker's items
* to notify of success / failure.
  */
  class AttackNotifyEvent : public Event {
  public:
  AttackNotifyEvent() : Event(EVENT_ATTACK_NOTIFY) {}

  std::vector<Damage> damageRolls;

  // ...    
  };
  ```

Thus, the attack will be processed as follows:
* The player's items handle `AttackOutEvent` and populate the `damageRolls` array.
* The monster's items handle `AttackInEvent` and update the `damageRolls` array.
* Damage is dealt to the monster.
* The player's items receive an `AttackNotifyEvent` notification of success or failure.

Now let's implement `VampiricSword`:
```cpp
class WeaponBehaviour : public Behaviour {
public:
virtual void process(Event *event) override {
if (event->type != EVENT_ATTACK_OUT)
return;
AttackOutEvent *e = static_cast<AttackOutEvent *>(event);

        e->damageRolls.push_back(Damage(owner(), DMG_PHYSICAL, _dice.roll()));
    }

    // ...

private:
Dice _dice;
};

class LifeStealingBehaviour : public Behaviour {
public:
virtual void process(Event *event) override {
if (event->type != EVENT_ATTACK_NOTIFY)
return;
AttackNotifyEvent *e = static_cast<AttackNotifyEvent *>(event);

        int damageAmount = 0;
        for (const Damage &damage : e->damageRolls)
            if (damage.source == owner() && damage.type == DMG_PHYSICAL)
                damageAmount += damage.amount;

        if (damageAmount <= 1)
            return;

        // Get owning actor - monster or player. Monsters & player are 
        // entities too! 
        Entity *actor = actorOf(owner());

        // Owning actor can be null. E.g. this item is a sword lying on 
        // the ground, the room is dark, player is cursed, and his big 
        // toe connects with the pointy end.
        if (actor) {
            Damage healing(owner(), DMG_DARKMAGIC, damageAmount / 2);
            sendEvent(actor, SpellEvent(SPELL_VAMPIRIC_HEALING, healing));
        }
    }

    // ...
};

std::unique_ptr<Entity> makeVampiricSword(Dice damageDice) {
auto result = std::make_unique<Entity>();
result->behaviours.emplace_back(
std::make_unique<WeaponBehaviour>(result.get(), damageDice));
result->behaviours.emplace_back(
std::make_unique<LifeStealingBehaviour>(result.get()));
return result;
}
```

Read the code carefully — it's important that `WeaponBehaviour` and `LifeStealingBehaviour` know nothing about each other. Different `Behaviours` can be mixed and matched as desired. And now you can easily create the most incredible items:
* A spiked shield of chaos — `WeaponBehaviour` plus `ArmorBehaviour` plus `CorruptingBehaviour`.
* A fire sword — `WeaponBehaviour` plus `MagicDamageBehaviour(DMG_FIRE)`.
* An ice ring — `ResistanceBehaviour(DMG_ICE)` plus `VulnerabilityBehaviour(DMG_FIRE)`.

I won't provide the implementations of all these `Behaviours`, as it's generally clear what needs to happen there. What's important is that now:
* You can easily reuse code.
* You have incredible flexibility — for example, you can easily implement a sword that is fiery during the day and icy at night, reusing `MagicDamageBehaviour`.
* The code for individual features is now localized. You don't have the problem of feature code being spread across ten different places in your codebase.
* Monsters can also use items, and you don't need to change the item code for this.
* With some additional effort, you can now implement item loading from a file, allowing your game designer to write something like this in `items.json`:
  ```json
  {
  "unidentified_name" : "long sword",
  "name" : "vampiric sword",
  "description" : "A long sword imbued with dark magic that heals its owner when it's dealing damage to living creatures. Its blade is eerily warm to the touch.",
  "behaviours": [
  {
  "type" : "weapon",
  "damageDice" : "3d5+5"
  },
  {
  "type" : "lifeStealing"
  }
  ]
  }
  ```

And that's it! Now your game designer shakes your hand and treats you to a beer. And you don't need to write code every time they come up with another brilliant idea (which happens several times a day) — they can assemble what they need from the components themselves!

If you're interested in diving deeper into ECS details, I recommend [Brian Bucklew's talk on Caves of Qud](https://www.youtube.com/watch?v=U03XXzcThGU), [Bob Nystrom's talk on Roguelike game design](https://www.youtube.com/watch?v=JxI3Eu5DPwE), and the [ENTT documentation](https://github.com/skypjack/entt/wiki).


### Understanding Example #6

Returning to the design questions, let's think about what we actually did. At the start, we had one abstraction — items. The game logic existed around this abstraction, part of which we tried to attach to items by building a class hierarchy and adding virtual methods. And this didn't work — if we had continued down this slippery path, after the first hundred items we would have concluded that game development wasn't for us, and it was better to find a job handling JSON data.

So, we looked at what smart people had already come up with and applied a classic pattern — the [chain of responsibility](https://en.wikipedia.org/wiki/Chain-of-responsibility_pattern):
* `Event` — is a command in terms of the chain of responsibility pattern, an abstraction over an action or a separate step of some action;
* `Behaviour` — is a command handler, an abstraction over a separable piece of game logic;
* `Entity` — is a set of handlers implementing the chain of responsibility pattern, as well as an abstraction for game items.

Importantly, all these abstractions are *orthogonal* — `Events` know nothing about specific `Behaviours`, and `Behaviours` know nothing about each other and the encompassing `Entity` (except that it exists). Introducing additional orthogonal abstractions allowed us to organize the game logic and achieve incredible flexibility — what was spread thinly across virtual functions is now hidden behind a unified interface, and what previously required writing additional code in several places can now be implemented simply by changing game data files.

As a pleasant bonus, we gained testability for all our functionality — since all `Behaviours` are separable and can be easily tested in any combination.

> 📝 One of the signs that you've properly split your abstractions and arrived at a good API is the ease with which you write tests. If you have to insert `if(currentlyTesting)` in random places to properly test your code, there's definitely something wrong with your API. On the other hand, writing tests for a good API is usually easy and pleasant — as if the code was waiting to be covered by tests and was thoroughly prepared to welcome any developer who happened to wander into the `tests` folder.

> 📝 At C++ Russia, listeners correctly noted that debugging the new construction is more complex. This is true, but it's the price you pay for flexibility, and there's no escaping it. Often, a simple output of all `Events` to `stderr` can help you understand what's going wrong. And thanks to the testability of the design, after localizing the bug, you can always easily write a test.


# Summing Up

At the beginning of this article, I pointed out that the concepts of API design and software architecture are closely intertwined, and the last example illustrates this well — sometimes, to get a good API, you need to step up a level and make the right architectural decisions first.

In most cases, the rules listed above will be enough to help you arrive at a sufficiently good API. To recap:
1. Design APIs so they cannot be used incorrectly.
   *All possible ways of using your API should either work correctly or result in an error!*
2. Divide & Conquer.
   *Break your code down — into classes, modules, functions, and layers of abstraction.*
3. Spend time thinking of good names!
   *If you can't come up with a proper name, it means you've created a poor abstraction.*
4. Create orthogonal and interchangeable abstractions.
   *Check the quality of abstractions by the testability of your code — well-separated abstractions make APIs easy and pleasant to test! If you don't know where to start, recall the STL example, "data is orthogonal to logic."*

In practice, it's usually quite challenging to arrive at a good API on the first try — it requires experience, a deep understanding of the domain, and possible usage patterns. You might not have all of this for quite objective reasons. Therefore, I view API design as an *iterative process*. Your API should be good and flexible enough to solve your current tasks without causing users of this API to suffer, and if you can't achieve this state on the first try — iterate! Try different options, write client code, and usually, after three or four iterations, you can arrive at a sufficiently simple, flexible, and safe API.
