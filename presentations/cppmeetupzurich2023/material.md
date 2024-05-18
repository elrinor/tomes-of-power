
Tokyo Meeting: 
https://www.reddit.com/r/cpp/comments/1bloatw/202403_tokyo_iso_c_committee_trip_report_third/
https://herbsutter.com/2024/03/22/trip-report-winter-iso-c-standards-meeting-tokyo-japan/

* [[nodiscard]] policy. Policies in general. https://isocpp.org/files/papers/P3201R0.html.
* noexcept policy discussions. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p3085r0.html
* Errorneous behaviour for uninitialized reads. https://isocpp.org/files/papers/P2795R5.html
*  = delete("should have a reason"); https://isocpp.org/files/papers/P2573R2.html
* string + string_view. https://isocpp.org/files/papers/P2591R5.html
* views::concat. https://isocpp.org/files/papers/P2542R8.html
* Vector RNG. https://isocpp.org/files/papers/P1068R11.pdf
* reference_wrapper comparisons. https://isocpp.org/files/papers/P2944R3.html
* Padded mdspan. https://wg21.link/P2642R6

Kona Meeting:
https://www.reddit.com/r/cpp/comments/17vnfqq/202311_kona_iso_c_committee_trip_report_second/
https://herbsutter.com/2023/11/11/trip-report-autumn-iso-c-standards-meeting-kona-hi-usa/

* Pack indexing https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2662r3.pdf
* BLAS https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p1673r13.html
* breakpoint() / is_debugger_present() https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2546r5.html

Varna Meeting:
https://www.reddit.com/r/cpp/comments/14h4ono/202306_varna_iso_c_committee_trip_report_first/
https://herbsutter.com/2023/06/16/trip-report-summer-iso-c-standards-meeting-varna-bulgaria/

* _ placeholder. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2169r4.pdf
* function_ref. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p0792r14.html
* Hazard pointers. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2530r3.pdf
* RCU. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2545r4.pdf
* copyable_function. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2548r6.pdf

Big stuff:
* Senders AKA execution. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2300r7.html
* LinALG. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p1673r13.html
* SIMD. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p1928r8.pdf
* Contracts. Looks like 29. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0542r5.html
* Reflection. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2996r0.html
* Pattern Matching. Looks like 29. https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2020/p1371r3.pdf

Slides:

--

We had a nice meeting in Tokyo

photo

200+ engineers, sakura, etc.

--

We have approved some mostly minor stuff, and here is a small list, and for me the most important part was
* "err behavior".
* Policy discussions. noexcept & [[nodiscard]].

--

But, what C++26 is really about? (table in Tokyo trip report on Reddit)

* Pattern Matching. C++29?
* Reflection.
* Senders.
* LinAlg.
* SIMD.
* Contracts. C++29?

Let's take a short look at each one of these with motivating examples. This is what this talk is about. I have read
through the proposals and participated in some of the discussions so that you don't have to.


Bjarne 2024:
Greatest benefit to the community would be pattern matching. I did experiments 15 years ago, it has not been fashionable lately.
We can’t expect it to just appear, people need to work on that. I would like to see structured concurrency finished.
We almost had it for 3 releases. After that maybe static reflection.

--

Pattern Matching.

https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2688r1.pdf (2024!)
https://github.com/mpark/wg21-papers/blob/main/P2688R1-slides.pdf

The why:

```cpp {all}
using Expression = std::variant<AddNode, MulNode, double>;

double evaluate(const Expression &e) {
    return std::visit<double>([]<class T>(const T &arg) {
        if constexpr (std::is_same_v<T, AddNode>)
            return evaluate(*arg.l) + evaluate(*arg.r);
        else if constexpr (std::is_same_v<T, MulNode>)
            return evaluate(*arg.l) * evaluate(*arg.r);
        else if constexpr (std::is_same_v<T, double>)
            return arg;
        else 
            static_assert(always_false_v<T>, "non-exhaustive visitor!");
    }, e);
}
```

OR

```
using Expression = std::variant<AddNode, MulNode, double>;

double evaluate(const Expression &e) {
    double value = 0.0;
    if (std::holds_alternative<AddNode>(e))
        value = evaluate(*std::get<AddNode>(e).l) + evaluate(*std::get<AddNode>(e).r);
    else if (std::holds_alternative<MulNode>(e))
        value = evaluate(*std::get<MulNode>(e).l) * evaluate(*std::get<MulNode>(e).r);
    else if (std::holds_alternative<double>(e))
        value = std::get<double>(e);
    else 
        assert(false && "eeeh?");
}
```

Suboptimal! And ugly!

--

```
struct Expression : std::variant<AddNode, MulNode, double> {};

double evaluate(const Expression &e) {
    return e match {
        AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
        MulNode: let arg => evaluate(*arg.l) * evaluate(*arg.r);
        double:  let arg => arg;
        _                => throw EvaluationException(); // e.valueless_by_exception() == true
    };
};
```

```
struct Expression : std::variant<AddNode, MulNode, double, float> {};

double evaluate(const Expression &e) {
    return e match {
        AddNode:             let arg => evaluate(*arg.l) + evaluate(*arg.r);
        MulNode:             let arg => evaluate(*arg.l) * evaluate(*arg.r);
        std::floating_point: let arg => arg;
        _                            => throw EvaluationException(); // e.valueless_by_exception() == true
    };
};
```

// only expressions after =>, throw allowed, break, continue, return. If you want more ==> do the do expression.
// std::terminate if nothing matched.
// "let" because we need to distinguish between referring to previous names and introducing new ones.

Other alternatives considered:
```
double evaluate(const Expression &e) {
    return inspect(e) {
        <AddNode> arg => evaluate(*arg.l) + evaluate(*arg.r);
        <MulNode> arg => evaluate(*arg.l) * evaluate(*arg.r);
        <double>  arg => arg;
    };
};

double evaluate(const Expression &e) {
    return inspect(e) {
        arg as AddNode => evaluate(*arg.l) + evaluate(*arg.r);
        arg as MulNode => evaluate(*arg.l) * evaluate(*arg.r);
        arg as double  => arg;
    };
};
```

Also std::any:

```
double evaluate(const std::any &e) {
    return e match { 
        AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
        MulNode: let arg => evaluate(*arg.l) * evaluate(*arg.r);
        double:  let arg => arg;
        _                => throw EvaluationException();
    };
}

```

Also polymorphism:

```
struct ExpressionNode {
    virtual ~ExpressionNode() = default;
    // ...
};

double evaluate(const ExpressionNode &e) {
    return e match {
        AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
        MulNode: let arg => evaluate(*arg.l) * evaluate(*arg.r);
        ValNode: let arg => arg.v;
        _                => throw EvaluationException();
    };
}
```

Also switches:

```
double evaluate(Operation op, double l, double r) {
    return e match {
        Operation::Add => l + r;
        Operation::Mul => l * r;
        Operation::Val => l;
        _              => throw EvaluationException();
    };
}
```

But better than switches:
```
Color colorFromString(std::string_view s) {
    return s match {
        "red"    => Color::Red;
        "orange" => Color::Orange;
        "blue"   => Color::Blue;
        _        => Color::Unknown;
    };
}
```


Also tuple-like objects:

```
double evaluate(const std::tuple<Operation, double, double> &op) {
    return op match {
        [Operation::Add, let l, let r] => l + r;
        [Operation::Mul, let l, let r] => l * r;
        [Operation::Val, let v, let _] => v;
        _                              => throw EvaluationException();
    };
}
```

Also structured binding over structs:

```
double classify(Point point) {
    return point match {
        [0, 0]     => PointClass::Origin;
        [0, let _] => PointClass::YAxis;
        [let _, 0] => PointClass::XAxis;
        _          => PointClass::Other;
    };
}
```

And all together:

```
double evaluate(const std::any &e) {
    return e match { 
        AddNode: let [l, r] => evaluate(*l) + evaluate(*r);
        MulNode: let [l, r] => evaluate(*l) * evaluate(*r);
        double:  let v      => v;
        _                   => throw EvaluationException();
    };
}
```

Also ifs:

```
int fib(int n) {
    return n match {
        let x if (x < 0) => 0;
        1 => n;
        2 => n;
        let x => fib(x - 1) + fib(x - 2);
    };
}
```

Also simple form:

```
if (expr match [0, 0]) {
    // `foo` is available here
}
```

Extension points:
```

operator== for values.

std::tuple_size, std::tuple_element, get<I> for tuples.

std::variant_size_v<T>, index(v), std::variant_alternative_t<I, V>, and get<I>(v) --- not really a protocol, not used
by std::visit.

cast<T> for casts (std::any, poly types, std::exception_ptr (through try_cast)).

```

Open questions:

std::variant<T, T>
std::expected<T, T>

flesh out extension protocols. variant-protocol is not really a thing.

std::terminate for a match that matches nothing.

and what to do about non-exhaustive match expressions. Fallthrough is one thing, std::terminate is another.

--


------------------------------------------------------------------------------------------------------------------------

Reflection

https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2996r2.html
https://docs.google.com/presentation/d/1plTna9qreBPu6G4ZWBUMBq_XmqJ5qAVFswWRGqp_xrw/edit#slide=id.p

Has been long in the works, lots of prior art:
* Reflection TS with reflexpr, goes way back to 2010s.
* Boost.Describe.
* Boost.PFR.
* refl-cpp. https://github.com/veselink1/refl-cpp
* ...

* Design went from metafunctions to consteval functions, and C++ didn't have these for a long time (consteval is C++20).

--

Latest reflection:

Reflecting & unreflecting
```cpp {all}

constexpr std::meta::info r = ^int;
[:r:] value = 42;
std::vector<[:r:]> v = { value };

[:^vector<int>:]::iterator it;

```

// std::meta::info is an opaque type for reflection.
a reflection operator (prefix ^) that produces a reflection value for its operand construct,
a number of consteval metafunctions to work with reflections (including deriving other reflections), and
constructs called splicers to produce grammatical elements from reflections (e.g., [: refl :]).

Why single type?

Other advantages of a single opaque type include:

it makes no assumptions about the representation used within the implementation (e.g., it doesn’t advantage one compiler over another),
it is trivially extensible (no types need to be added to represent additional language elements and meta-elements as the language evolves), and
it allows convenient collections of heterogeneous constructs without having to surface reference semantics (e.g., a std::vector<std::meta::info>
can easily represent a mixed template argument list — containing types and nontypes — without fear of slicing values).

Member access.

```cpp {all}

struct Person { 
    std::string name;
    std::string surname;
};

consteval auto member_named(std::string_view name) {
    for (std::meta::info field : nonstatic_data_members_of(^Person)) {
        if (name_of(field) == name) return field;
    }
}

int main() {
  Person p;
  p.[:member_named("name"):] = "John";
  p.[:member_named("surname"):] = "Doe";
  p.[:member_named("nickname"):] = "Coder"; // Error.
}

```

Substitution & codegen
```cpp {all}
using StringHandler = std::string(*)(const void *);

template<class T>
static std::string stringize(const void *ptr) {
    return std::to_string(*static_cast<const T *>(ptr));
}

constexpr std::array types = {^int, ^float, ^double}; // And maybe more.

constexpr std::array handlers = [] {
    std::array<StringHandler, types.size()> result;
    template for (std::size_t i = 0; constexpr auto e : types)
        result[i++] = &stringize<typename[:e:]>;
    return result;
}();

https://godbolt.org/z/d5G75ojYx
```

--


enum to string
```

template <typename E>
  requires std::is_enum_v<E>
constexpr std::string enum_to_string(E value) {
  template for (constexpr auto e : std::meta::enumerators_of(^E)) {
    if (value == [:e:]) {
      return std::string(std::meta::name_of(e));
    }
  }

  return "<unnamed>";
}

enum Color { red, green, blue };
static_assert(enum_to_string(Color::red) == "red");
static_assert(enum_to_string(Color(42)) == "<unnamed>");

```

string to enum
```
template <typename E>
  requires std::is_enum_v<E>
constexpr std::optional<E> string_to_enum(std::string_view name) {
  template for (constexpr auto e : std::meta::enumerators_of(^E)) {
    if (name == std::meta::name_of(e)) {
      return [:e:];
    }
  }

  return std::nullopt;
}
```

string to enum, but better:

```
template<class E>
constexpr make_enum_pairs() {
    constexpr auto size = std::meta::enumerators_of(^E).size();
    std::array<std::pair<std::string_view, E>, size> result;
    for (std::size_t i = 0; auto e : std::meta::enumerators_of(^E)) {
        result[i++] = {name_of(e), value_of<E>(e)};
    }
    return result;
}

enum Color { red, green, blue };
constexpr auto mapping = frozen::make_unordered_map(make_enum_pairs<Color>());
```

Tuple
```

template<typename... Ts> struct Tuple {
  struct storage;
  [:define_class(^storage, { data_member_spec(^Ts)... }):] data;
  Tuple(): data{} {}
  Tuple(Ts const& ...vs): data{ vs... } {}
};

```

Tuple p2
```
template<std::size_t I, typename... Ts>
struct std::tuple_element<I, Tuple<Ts...>> {
    static constexpr std::array types = {^Ts...};
    using types = [: types[I] :];
};

consteval std::meta::info get_nth_nsdm(std::meta::info r, std::size_t n) {
  return nonstatic_data_members_of(r)[n];
}

template<std::size_t I, typename... Ts>
constexpr auto get(Tuple<Ts...> &t) noexcept
  -> std::tuple_element_t<I, Tuple<Ts...>>& {
  return t.data.[:get_nth_nsdm(^decltype(t.data), I):];
}
```

Member-wise hash_append:
```
template <typename H, typename T> requires std::is_standard_layout_v<T>
void hash_append(H& algo, T const& t) {
    template for (constexpr auto mem : nonstatic_data_members_of(^T)) {
        hash_append(algo, t.[:mem:]);
    }
}
```


Problems:
* Reflection observes compilation state
* Reflection modifies compilation state
    * nonstatic_data_members_of(^std::pair<int, int>) requires instantiation
    * is_incomplete_type is a state accessor, doh!

2 => can make a counter on reflection (could do it before with declarations, now it's a function).


Open questions:

Error handling, what does `constexpr auto tmpl = template_of(^int);` do:
* throw?
* std::excpected?
* null std::meta::info
* not-a-constant-expression? new mechanism, basically

exceptions are nice but we don't have constexpr exceptions yet.

https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p3068r0.pdf



-------------------------------------------------------------

Senders.

https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p2300r7.html

The problem:
- We need more than std::thread, std::future, std::async, std::mutex, etc.
- std::future is a disgrace. Not composable, not cancellable => in all complex codebases needed to roll out smth custom. Lifetime management is a mess.
- We have parallel algos that are not composable.
- Need anything more complex? Roll out your stuff, and suffer.


--

Concepts:
- Execution resources. Place of execution.
-

