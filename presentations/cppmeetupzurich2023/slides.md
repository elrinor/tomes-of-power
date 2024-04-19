---
# try also 'default' to start simple
theme: dracula
# random image from a curated Unsplash collection by Anthony
# like them? see https://unsplash.com/collections/94734566/slidev
# TODO
# background: https://source.unsplash.com/collection/94734566/1920x1080
# https://sli.dev/custom/highlighters.html
highlighter: shiki
# show line numbers in code blocks
lineNumbers: true
# some information about the slides, markdown enabled
# TODO
info: |
  Why are you reading this?
# persist drawings in exports and build
drawings:
  persist: true
# use UnoCSS - we're using windicss instead
# css: unocss
# page transition
transition: instant
# apply any windi css classes to the current slide
class: 'text-center'
# since the canvas gets smaller, the visual size will become larger
canvasWidth: 800
---




# What’s new in C++26

<!-- --------------------------------------------------------------------------------------------------------- -->




---
---



# News from the last C++ committee meeting

<br/>

* Uninitialized reads are no longer UB. It's "errorneous behaviour."
* Policy discussions started.
  * <span class="font-mono">[[nodiscard]]</span> policy approved. Which is, don't <span class="font-mono">[[nodiscard]]</span> in the standard.
  * <span class="font-mono">noexcept</span> policy discussion started.
* <span class="font-mono">std::string + std::string_view</span>.
* <span class="font-mono">= delete("should have a reason");</span>
* ...and some other minor stuff.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<!-- * <span class="font-mono">views::concat</span>.--------------------------------------------------------------------------------------------------------- -->




---
---



# Reminder: what's already in C++26

<br/>

* <span class="font-mono">std::function_ref</span> and <span class="font-mono">std::copyable_function</span>. 
* <span class="font-mono">pack...[indexing]</span>.
* <span class="font-mono">_</span> placeholder.
* Free function linear algebra interface based on BLAS.
* RCU & hazard pointers.
* <span class="font-mono">is_debugger_present()</span> & <span class="font-mono">breakpoint()</span>.
* ...and some other minor stuff.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<!-- --------------------------------------------------------------------------------------------------------- -->




---
---



# What C++26 is really about


<table>
    <thead>
      <tr>
        <th>
            Feature
          </th><th>
            Status
          </th><th>
            Current Target (Conservative)
          </th><th>
            Current Target (Optimistic)
          </th>
      </tr>
      <tr></tr>
    </thead>
    <tbody>
        <tr>
            <td>
              Senders
            </td><td>
              Processed by LWG
            </td><td>
              C++26
            </td><td>
              C++26
            </td>
        </tr><tr>
            <td>
              Networking
            </td><td>
              Depends on Senders
            </td><td>
              C++29
            </td><td>
              C++26
            </td>
        </tr><tr>
            <td>
              Linear Algebra
            </td><td>
              Plenary approved
            </td><td>
              C++26
            </td><td>
              C++26
            </td>
        </tr><tr>
            <td>
              SIMD
            </td><td>
              Forwarded to LWG
            </td><td>
              C++26
            </td><td>
              C++26
            </td>
        </tr><tr>
            <td>
              Contracts
            </td><td>
              Processed in SG21
            </td><td>
              C++29
            </td><td>
              C++26
            </td>
        </tr><tr>
            <td>
              Reflection
            </td><td>
              Forwarded to EWG
            </td><td>
              C++26
            </td><td>
              C++26
            </td>
        </tr><tr>
            <td>
              Pattern Matching
            </td><td>
              Presented in EWG
            </td><td>
              C++29
            </td><td>
              C++26
            </td>
        </tr>
    </tbody>
</table>

<style>
.slidev-layout { td {
    font-size: 16px !important;
    line-height: 18px;
    padding: 10px;
    padding-top: 2px;
    padding-bottom: 2px;
}}
</style>


<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<!-- --------------------------------------------------------------------------------------------------------- -->




---
---




# What we mortal coders need

<br/>

> Greatest benefit to the community would be pattern matching. I did experiments 15 years ago, it has not been fashionable lately. We can’t expect it to just appear, people need to work on that. I would like to see structured concurrency finished. We almost had it for 3 releases. After that maybe static reflection. 

— Bjarne Stroustrup, <br/>latest committee meeting. 

<img src="/bjarne.png" style="height: 50%; position: fixed; bottom: 10px; right: 50px; "/>

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<!-- --------------------------------------------------------------------------------------------------------- -->




---
---




# This talk

1. Pattern Matching.
2. Reflection.
3. Lots of code.

<br/>

I've read the proposals & sat through the discussions at the committee meeting, so that you don't have to.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>



---
class: 'text-center'
---




<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

# Pattern matching




---
---



# Pattern matching: the WHY

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
            static_assert(always_false_v<T>, "Non-exhaustive visitor!");
    }, e);
}
```

<br/>

> C++ is a horrible language.

— Linus Torvalds, git mailing list.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: the WHY

```cpp {all}
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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: variants

```cpp {all}
struct Expression : std::variant<AddNode, MulNode, double> {};

double evaluate(const Expression &e) {
    return e match {
        AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
        MulNode: let arg => evaluate(*arg.l) * evaluate(*arg.r);
        double:  let arg => arg;
        _                => throw EvaluationException(); // e.valueless_by_exception().
    };
}
```

<br/>

* Matches are evaluated in order.
* Only expressions supported after <span class="font-mono">=></span>.
* Match expression <span class="font-mono">std::terminate()</span>s if nothing was matched.
* <span class="font-mono">let</span> to introduce a binding.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: std::any

```cpp {all}
using Expression = std::any;

double evaluate(const Expression &e) {
    return e match { 
        AddNode: let arg => evaluate(arg.l) + evaluate(arg.r);
        MulNode: let arg => evaluate(arg.l) * evaluate(arg.r);
        double:  let arg => arg;
        _                => throw EvaluationException(); // All other types.
    };
}
```

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: std::any

```cpp {all}
using Expression = std::any;

double evaluate(const Expression &e) {
    return e match { 
        AddNode: let arg => evaluate(arg.l) + evaluate(arg.r);
        MulNode: let arg => evaluate(arg.l) * evaluate(arg.r);
        double:  let arg => arg;
        _                => throw EvaluationException(); // All other types.
    };
}
```

<br/>

> You don't have to worry about what is not important. That is the beauty of C++. It lets you concentrate on what you consider important.

— Bjarne Stroustrup, as hallucinated by ChatGPT.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: polymorphic classes

```cpp {all}
struct Expression { virtual ~Expression() = default; };

double evaluate(const Expression &e) {
    return e match {
        AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
        MulNode: let arg => evaluate(*arg.l) * evaluate(*arg.r);
        ValNode: let arg => arg.v;
        _                => throw EvaluationException();
    };
}
```

<br/>

* There are techniques to make this more efficient than a sequence of <span class="font-mono">dynamic_cast</span>s.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: switches

```cpp {all}
double evaluate(Operation op, double l, double r) {
    return e match {
        Operation::Add => l + r;
        Operation::Mul => l * r;
        Operation::Val => l;
        _              => throw EvaluationException();
    };
}
```

<br/>

* Labels are constant expressions.
* Matches are checked in order with <span class="font-mono">operator==</span>.
* Effectively compiles into a <span class="font-mono">switch</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---


# Pattern matching: better than a switch

```cpp {all}
Color colorFromString(std::string_view s) {
    return s match {
        "red"    => Color::Red;
        "green"  => Color::Green;
        "blue"   => Color::Blue;
        "orange" => Color::Orange;
        _        => Color::Unknown;
    };
}
```

<br/>

* Remember that this is evaluated in order.
* There are opportunities for optimization if we allow compiler magic here.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: tuple-like objects

```cpp {all}
double evaluate(const std::tuple<Operation, double, double> &op) {
    return op match {
        [Operation::Add, let l, let r] => l + r;
        [Operation::Mul, let l, let r] => l * r;
        [Operation::Val, let v, let _] => v;
        _                              => throw EvaluationException();
    };
}
```

<br/>

* Code is retarded, for illustrative purposes only.
* Shows why we need <span class="font-mono">let</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: structured bindings

```cpp {all}
double classify(Point point) {
    return point match {
        [0, 0]     => PointClass::Origin;
        [0, let _] => PointClass::YAxis;
        [let _, 0] => PointClass::XAxis;
        _          => PointClass::Other;
    };
}
```

<br/>

* This is C++ and we can't have nice things, so <span class="font-mono">_</span>s in the code are conceptually different.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching is composable!

```cpp {all}
using Expression = std::any;

double evaluate(const std::any &e) {
    return e match { 
        AddNode: let [l, r] => evaluate(l) + evaluate(r);
        MulNode: let [l, r] => evaluate(l) * evaluate(r);
        double:  let v      => v;
        _                   => throw EvaluationException();
    };
}
```

<br/>

* Also possible:
  * <span class="font-mono">let [[a, b], c]</span>.
  * <span class="font-mono">let [[0, 0], c]</span>.
  * <span class="font-mono">[MyPair: let [a, b], 0]</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---

# Pattern matching: ifs everywhere!
 
```cpp {all}
int fib(int n) {
    return n match {
        let x if (x < 0) => 0;
        1 => n;
        2 => n;
        let x => fib(x - 1) + fib(x - 2);
    };
}
```

<br/>

```cpp {all}
if (expr match [foo, 0]) {
    // `foo` is available here
}
```

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Pattern matching: extension points

* <span class="font-mono">operator==</span> for constant expression matches.
* <span class="font-mono">std::tuple_size&lt;T></span>, <span class="font-mono">std::tuple_element<I, T></span>, ADL <span class="font-mono">get&lt;I>(v)</span> for tuple-like types.
* <span class="font-mono">std::variant_size&lt;T></span>, <span class="font-mono">std::variant_alternative<I, T></span>, ADL <span class="font-mono">index(v)</span> and <span class="font-mono">get&lt;I>(v)</span> for variant-like types.
* ADL <span class="font-mono">cast&lt;T>(v)</span> for <span class="font-mono">std::any</span>, <span class="font-mono">std::exception_ptr</span>, polymorphic types.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>





---
---



# Pattern matching: open questions

* Matching <span class="font-mono">std::variant<T, T></span>.
* Matching <span class="font-mono">std::expected<T, T></span>.
* <span class="font-mono">std::terminate</span> if we match nothing is a bit... excessive?
  * Do we do anything with non-exhaustive match expressions at compile time?
* Fully specified extension protocols. Right now variant protocol isn't really a thing (<span class="font-mono">std::visit</span> isn't even implemented in terms of this "protocol").

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
class: 'text-center'
---




<br/>
<br/>
<br/>
<br/>
<br/>
<br/>
<br/>

# Reflection




---
---

# Reflection: prior art

* Started pre-<span class="font-mono">constexpr</span>, when we only had template-based metaprogramming.
* Reflection TS with <span class="font-mono">reflexpr</span> goes way back to 2010s.
* People have been having fun for a long time:
  * Boost.Describe.
  * Boost.PFR.
  * refl-cpp.
  * ...
* Design settled on <span class="font-mono">consteval</span> functions, and C++ didn't have these for a long time (<span class="font-mono">consteval</span> is C++20, same as <span class="font-mono">constexpr std::vector</span>).

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>




---
---




# Reflection: reflecting & unreflecting

```cpp {all}
constexpr std::meta::info r = ^int;
[:r:] value = 42;

std::vector<[:r:]> v = { value };

[:^vector<int>:]::iterator it;
```
<br/>

* <span class="font-mono">std::meta::info</span> is an opaque type for reflection.
* Prefix <span class="font-mono">^</span> reflects.
* Splicers in the form <span class="font-mono">[: refl :]</span> produce grammatical elements from reflections. "Accordion operator."

<!--
it makes no assumptions about the representation used within the implementation (e.g., it doesn’t advantage one compiler over another), it is trivially extensible (no types need to be added to represent additional language elements and meta-elements as the language evolves), and it allows convenient collections of heterogeneous constructs without having to surface reference semantics (e.g., a std::vector<std::meta::info> can easily represent a mixed template argument list — containing types and nontypes — without fear of slicing values).
-->




---
---



# Reflection: reflecting & unreflecting


```cpp {all}
constexpr std::meta::info v = ^std::vector;
constexpr std::meta::info a = ^int;
constexpr std::meta::info va = std::meta::substitute(v, {a});

[:va:] vec = {1, 2, 3}; // Got std::vector<int> back.
```

<br/>

* Can reflect & unreflect templates.
* A number of <span class="font-mono">consteval</span> functions are offered that work with <span class="font-mono">std::meta::info</span>.




---
---




# Reflection: member access

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




---
---



# Reflection: codegen with template for




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
```

<br/>

* Today you would normally do this with macros.

<!--
https://godbolt.org/z/d5G75ojYx
-->




---
---



# Reflection: enum to string

```cpp {all}
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



---
---




# Reflection: string to enum

```cpp {all}
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



---
---




# Reflection: string to enum, but better

```cpp {all}
template<class E>
    requires std::is_enum_v<E>
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



---
---



# Reflection: tuple

```cpp {all}
template<typename... Ts> struct Tuple {
  struct storage;
  [:define_class(^storage, { data_member_spec(^Ts)... }):] data;
  Tuple(): data{} {}
  Tuple(Ts const& ...vs): data{ vs... } {}
};

template<std::size_t I, typename... Ts>
struct std::tuple_element<I, Tuple<Ts...>> {
    static constexpr std::array types = {^Ts...};
    using type = [: types[I] :]; // Or you can do pack...[indexing].
};

consteval std::meta::info get_nth_nsdm(std::meta::info r, std::size_t n) {
    return nonstatic_data_members_of(r)[n];
}

template<std::size_t I, typename... Ts>
constexpr auto get(Tuple<Ts...> &t) noexcept -> std::tuple_element_t<I, Tuple<Ts...>>& {
    return t.data.[:get_nth_nsdm(^decltype(t.data), I):];
}
```




---
---




# Reflection: hash_append

```cpp {all}
template <typename H, typename T> 
    requires std::is_standard_layout_v<T>
void hash_append(H& algo, T const& t) {
    template for (constexpr auto mem : nonstatic_data_members_of(^T)) {
        hash_append(algo, t.[:mem:]);
    }
}
```



---
---



# Reflection: fun

* Reflection observes compilation state. 
* Reflection modifies compilation state.

<br/>

```cpp {all}
constexpr auto type = ^std::vector<int>;

// This requires instantiation!
constexpr auto members = nonstatic_data_members_of(type);

// And we can check whether the type was instantiated...
constexpr bool fun = is_incomplete_type(type);
```

<br/>

Thus, you can make a counter (like the <span class="font-mono">\_\_COUNTER\_\_</span> macro) on reflection. Could do it before with declarations, now it's just a <span class="font-mono">consteval</span> function call.




---
---




# Reflection: open questions


What does this code de? 
```cpp {all}
constexpr auto tmpl = template_of(^int);
```

* Throws?
* Returns <span class="font-mono">std::expected</span>?
* Returns an empty <span class="font-mono">std::meta::info</span>?
* Some other mechanism? Fails to compile with "not-a-constant-expression"?

Would be nice to do this with exceptions, need <span class="font-mono">constexpr</span> exceptions in the language.




---
---




# Reflection: open questions


* Current proposal also doesn't solve the codegen question. Template <span class="font-mono">switch</span>, anyone?
* <span class="font-mono">define_class</span> API in its current form is questionable. How do we add member functions? How do we add <span class="font-mono">[[no_unique_address]]</span> to a member?



---
layout: end
---
