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




# Обзор C++26




---
layout: image-left
image: me.jpg
---




# Обо мне

- Пишу на C++ больше 15 лет.
- Основал WG21 Russia в 2016 вместе с [@apolukhin](https://github.com/apolukhin).
- В 2016-2019 представлял предложения от РФ в комитете.
- Руководил разработкой поискового движка в Яндексе.
- Руководил инфраструктурой, поиском и ML в Озоне.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
layout: full
---




# Этот доклад

1. Немного о том, что уже есть в С++26.
2. И о том, что мы на самом деле ждем от С++26.
3. Кратко о Pattern Matching.
4. Кратко о Рефлексии.
5. Много кода.
6. Много английских терминов и англицизмов.

<br/>

Я прочитал обсуждаемые предложения в стандарт и присутствовал на обсуждениях в комитете, чтобы вам не пришлось этого делать.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!-- 
Pattern Matching = сопоставление с образцом? Проверка соответствия шаблону? Распознавание шаблонов?
-->



---
---




# Новости со встречи в Токио

<br/>

* Чтение неинициализированной памяти теперь не является "неопределенным поведением" (UB). Появилось понятие "ошибочного поведения" (erroneous behavior).
* Началось обсуждение политик комитета.
  * Одобрили политику о <span class="font-mono">[[nodiscard]]</span> – не использовать <span class="font-mono">[[nodiscard]]</span> в стандарте.
  * Начали обсуждение политики о <span class="font-mono">noexcept</span>.
* <span class="font-mono">std::string + std::string_view</span>.
* <span class="font-mono">= delete("should have a reason");</span>
* ...и еще немного по мелочи.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!-- 
Also views::concat, but that's too minor.
Errorneous behavior here: https://isocpp.org/files/papers/P2795R5.html.
To quote:
Erroneous behavior is always the consequence of incorrect program code.
...it is still "wrong" to read an uninitialized value, but if you do read it and the implementation does not otherwise stop you, you get some specific value.
-->




---
---



# Что уже есть в С++26

<br/>

* <span class="font-mono">std::function_ref</span> и <span class="font-mono">std::copyable_function</span>. 
* <span class="font-mono">pack...[indexing]</span>.
* <span class="font-mono">_</span> для неиспользуемых переменных.
* Библиотека линейной алгебры на основе BLAS.
* Поддержка идиомы RCU.
* <span class="font-mono">is_debugger_present()</span> и <span class="font-mono">breakpoint()</span>.
* ...и еще немного по мелочи.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Что мы на самом деле ждем от C++26


<table>
    <thead>
      <tr>
        <th>
            &nbsp;
          </th><th>
            Статус
          </th><th>
            Консервативная оценка
          </th><th>
            Оптимистичная оценка
          </th>
      </tr>
      <tr></tr>
    </thead>
    <tbody>
        <tr>
            <td>
              Senders
            </td><td>
              Рассмотрено в LWG
            </td><td>
              <span class="text-green-300">C++26</span>
            </td><td>
              <span class="text-green-300">C++26</span>
            </td>
        </tr><tr>
            <td>
              Networking
            </td><td>
              Зависит от Senders
            </td><td>
              <span class="text-red-300">C++29</span>
            </td><td>
              <span class="text-green-300">C++26</span>
            </td>
        </tr><tr>
            <td>
              Линейная алгебра
            </td><td>
              Замержено!
            </td><td>
              <span class="text-green-300">C++26</span>
            </td><td>
              <span class="text-green-300">C++26</span>
            </td>
        </tr><tr>
            <td>
              SIMD
            </td><td>
              Направлено в LWG
            </td><td>
              <span class="text-green-300">C++26</span>
            </td><td>
              <span class="text-green-300">C++26</span>
            </td>
        </tr><tr>
            <td>
              Контракты
            </td><td>
              Рассмотрено в SG21
            </td><td>
              <span class="text-red-300">C++29</span>
            </td><td>
              <span class="text-green-300">C++26</span>
            </td>
        </tr><tr>
            <td>
              Рефлексия
            </td><td>
              Направлено в EWG
            </td><td>
              <span class="text-green-300">C++26</span>
            </td><td>
              <span class="text-green-300">C++26</span>
            </td>
        </tr><tr>
            <td>
              Pattern Matching
            </td><td>
              Рассматривается в EWG
            </td><td>
              <span class="text-red-300">C++29</span>
            </td><td>
              <span class="text-green-300">C++26</span>
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
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Что нужно обычным программистам

<br/>

> Наибольшую пользу для сообщества принесет pattern matching. Я проводил эксперименты с этим 15 лет назад. Мы не можем ожидать, что pattern matching просто появится в С++, люди должны работать над этим. И я хотел бы увидеть завершение работы над senders, это тянется уже три стандарта подряд. И после этого, возможно, статическую рефлексию.

— Бьёрн Страуструп, <br/>последнее заседание комитета.

<img src="/bjarne.png" style="height: 45%; position: fixed; bottom: 10px; right: 50px; "/>

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>



---
---



# Pattern matching: зачем?

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

> C++ — ужасный язык.

— Линус Торвальдс, рассылка git.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: зачем?

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
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: <span class="font-mono">std::variant</span>

```cpp {all}
using Expression = std::variant<AddNode, MulNode, double>;

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

* Матчи вычисляются по порядку.
* После <span class="font-mono">=></span> можно использовать только выражения.
* Если матч не был найден, то вызывается <span class="font-mono">std::terminate()</span>.
* <span class="font-mono">let</span> используется для объявления binding'ов.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: <span class="font-mono">std::any</span>

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
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: <span class="font-mono">std::any</span>

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

> Вам не нужно беспокоиться о том, что не важно. В этом красота C++. Он позволяет вам сосредоточиться на том, что вы считаете важным.

— Бьёрн Страуструп, как нагаллюцинировал ChatGPT.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: как?

```cpp {all}
struct Expression : std::variant<AddNode, MulNode, double> {};

double evaluate(const Expression &e) {
    // return e match {
    switch (e.index()) {
    //     AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
        case 0: {
            auto &&arg = get<0>(e);
            return evaluate(*arg.l) + evaluate(*arg.r);
        }
    //     ...
    //     double:  let arg => arg;
        case 2: {
            auto &&arg = get<2>(e);
            return arg;
        }
    //     _                => throw EvaluationException(); // e.valueless_by_exception().
        default:
            throw EvaluationException(); // e.valueless_by_exception().
    }
}
```

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!--
Note that match expressions support trailing return types --- the same way as lambdas.
std::variant_size<Expression> is well-formed, thus it's a variant => we go the variant way.
-->



---
---




# Pattern matching: как?

```cpp {all}
using Expression = std::any;

double evaluate(const Expression &e) {
    // return e match {
    //     AddNode: let arg => evaluate(*arg.l) + evaluate(*arg.r);
    if (auto *p = std::cast<Expression>::operator()<AddNode>(e)) {
        auto &&arg = *p;
        return evaluate(*arg.l) + evaluate(*arg.r);
    //     ...
    //     double:  let arg => arg;
    } else if (auto *p = std::cast<Expression>::operator()<double>(e)) {
        auto &&arg = *p;
        return arg;
    //     _                => throw EvaluationException(); // e.valueless_by_exception().
    } else {
        throw EvaluationException(); // e.valueless_by_exception().
    }
}
```

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!--
Note that we're using static operator(), this is C++23.
-->



---
---




# Pattern matching: полиморфные классы

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

* Внутри те же самые вызовы <span class="font-mono">std::cast</span>, который уже вызывает <span class="font-mono">dynamic_cast</span>. 
* Есть техники, позволяющие выполнить этот код быстрее, чем цепочку вызовов <span class="font-mono">dynamic_cast</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: <span class="font-mono">switch</span>

```cpp {all}
double evaluate(Operation op, double l, double r) {
    return op match {
        Operation::Add => l + r;
        Operation::Mul => l * r;
        Operation::Val => l;
        _              => throw EvaluationException();
    };
}
```

<br/>

* Метки являются константными выражениями.
* Матчи проверяются по порядку с помощью <span class="font-mono">operator==</span>.
* На деле компилируется в <span class="font-mono">switch</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---


# Pattern matching: лучше чем <span class="font-mono">switch</span>!

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

* Помните, что матчи вычисляются по порядку.
* Есть возможности для оптимизации если позволить компилятору применить немного магии.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: <span class="font-mono">std::tuple</span>

```cpp {all}
double evaluate(const std::tuple<Operation, double, double> &op) {
    return op match {
        [Operation::Add, let l, let r] => l + r;
        [Operation::Mul, let l, let r] => l * r;
        [Operation::Val, let v, _]     => v;
        _                              => throw EvaluationException();
    };
}
```

<br/>

* Код странный, исключительно для иллюстрации.
* Показывает, почему нам нужен <span class="font-mono">let</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: structured bindings

```cpp {all}
double classify(Point point) {
    return point match {
        [0, 0] => PointClass::Origin;
        [0, _] => PointClass::YAxis;
        [_, 0] => PointClass::XAxis;
        _      => PointClass::Other;
    };
}
```

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Паттерны можно компоновать!

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

* Также возможно:
  * <span class="font-mono">let [[a, b], c]</span>.
  * <span class="font-mono">[[0, 0], let c]</span>.
  * <span class="font-mono">[MyPair: let [a, b], 0]</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: использование <span class="font-mono">if</span>
 
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
if (expr match [let foo, 0]) {
    // `foo` is available here
}
```

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Pattern matching: точки кастомизации

* <span class="font-mono">operator==</span> для матчинга константных выражений.
* <span class="font-mono">std::tuple_size\<T\></span>, <span class="font-mono">std::tuple_element<I, T></span>, и <span class="font-mono">get\<I\>(v)</span> для типов, подобных <span class="font-mono">std::tuple</span>.
* <span class="font-mono">std::variant_size\<T\></span>, <span class="font-mono">std::variant_alternative<I, T></span>, и <span class="font-mono">index(v)</span> и <span class="font-mono">get\<I\>(v)</span> для типов, подобных <span class="font-mono">std::variant</span>.
* <span class="font-mono">std::cast</span> для <span class="font-mono">std::any</span>, <span class="font-mono">std::exception_ptr</span>, и полиморфных типов.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!--
Нужно сказать что все функции ищутся через ADL.
-->




---
---




# Pattern matching: открытые вопросы

* Матчинг для <span class="font-mono">std::variant<T, T></span>.
* Матчинг для <span class="font-mono">std::expected<T, T></span>.
* Вызов <span class="font-mono">std::terminate</span> если матч не был найден — это как-то чересчур...
  * Можем ли мы проверить во время компиляции, что <span class="font-mono">std::terminate</span> точно не будет вызван?
* Протоколы кастомизации. Протокол для типов, подобных <span class="font-mono">std::variant</span>, сейчас вызывает вопросы (например, <span class="font-mono">std::visit</span> не реализован в терминах существующего протокола).

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!--
И я не рассказал о матчинге для std::optional. Матч ?.
-->




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

# Рефлексия

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: немного истории

* Работа над предложеним началась до появления <span class="font-mono">constexpr</span>, когда у нас было только метапрограммирование на шаблонах.
* Reflection TS с <span class="font-mono">reflexpr</span> уходит корнями в 2010-е.
* Люди успели навелосипедить больше чем влезает на один слайд:
  * Boost.Describe.
  * Boost.PFR.
  * refl-cpp.
  * ...
* Дизайн последней итерации предложения основан на <span class="font-mono">consteval</span> функциях, которые появились только в C++20.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: базовые операции

```cpp {all}
constexpr std::meta::info r = ^int;
[:r:] value = 42;

std::vector<[:r:]> v = { value };

[:^vector<int>:]::iterator it;
```
<br/>

* <span class="font-mono">std::meta::info</span> — это непрозрачный тип для рефлексии.
* Префиксный оператор <span class="font-mono">^</span> выполняет рефлексию.
* <span class="font-mono">[:</span> и <span class="font-mono">:]</span> создают грамматические конструкции языка из объектов типа <span class="font-mono">std::meta::info</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!--
it makes no assumptions about the representation used within the implementation (e.g., it doesn’t advantage one compiler over another), it is trivially extensible (no types need to be added to represent additional language elements and meta-elements as the language evolves), and it allows convenient collections of heterogeneous constructs without having to surface reference semantics (e.g., a std::vector<std::meta::info> can easily represent a mixed template argument list — containing types and nontypes — without fear of slicing values).
-->




---
---



# Рефлексия: базовые операции


```cpp {all}
constexpr std::meta::info v = ^std::vector;
constexpr std::meta::info a = ^int;
constexpr std::meta::info va = std::meta::substitute(v, {a});

[:va:] vec = {1, 2, 3}; // Got std::vector<int> back.
```

<br/>

* Рефлексия работает для шаблонов.
* Есть ряд <span class="font-mono">consteval</span> функций, работающих с <span class="font-mono">std::meta::info</span>.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: доступ к полям

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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---



# Рефлексия: кодогенерация с помощью <span class="font-mono">template for</span>

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

* Сегодня вы можете сделать то же самое с помощью макросов или списков типов.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>
<!--
https://godbolt.org/z/d5G75ojYx
-->




---
---




# Рефлексия: <span class="font-mono">enum -> std::string</span>

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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: <span class="font-mono">std::string -> enum</span>

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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: <span class="font-mono">std::string -> enum</span>, но лучше

```cpp {all}
template<class E>
    requires std::is_enum_v<E>
consteval make_enum_pairs() {
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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: <span class="font-mono">std::tuple</span>

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

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: интересности

* Рефлексия читает текущее состояние компилятора.
* Рефлексия изменяет текущее состояние компилятора.

<br/>

```cpp {all}
constexpr auto type = ^std::vector<int>;

// This requires instantiation!
constexpr auto members = nonstatic_data_members_of(type);

// And we can check whether the type was instantiated...
constexpr bool fun = is_incomplete_type(type);
```

<br/>

Вы можете создать счетчик (как макрос <span class="font-mono">__COUNTER\__</span>) с помощью рефлексии. Ранее это можно было сделать через объявления, теперь это вызов <span class="font-mono">consteval</span> функции.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: открытые вопросы


Что делает этот код?
```cpp {all}
constexpr auto tmpl = template_of(^int);
```

* Бросает исключение?
* Возвращает <span class="font-mono">std::expected</span>?
* Возвращает пустой <span class="font-mono">std::meta::info</span>?
* Какой-то другой механизм? Ошибка компиляции с "not-a-constant-expression"?

Было бы хорошо сделать обработку ошибок через исключения, но нужна поддержка исключений в <span class="font-mono">constexpr</span> контексте.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Рефлексия: открытые вопросы

* Текущее предложение не решает вопрос генерации кода.
  * Как сгенерировать <span class="font-mono">switch</span>? Актуальный вопрос для многих!
* API <span class="font-mono">define_class</span> в его текущей форме вызывает вопросы.
  * Как добавлять методы?
  * Как добавить <span class="font-mono">[[no_unique_address]]</span> к полю?
  * ...

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
---




# Хотите узнать больше?

* [P2688R1](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2688r1.pdf): Pattern Matching: <span class="font-mono">match</span> Expression.
* [P2996R2](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2996r2.html): Reflection for C++26.
* [P2300R9](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2300r9.html): <span class="font-mono">std::execution</span>.
* [P1673R13](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p1673r13.html): A free function linear algebra interface based on the BLAS.
* [P1928R8](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2023/p1928r8.pdf): <span class="font-mono">std::simd</span> — merge data-parallel types from the Parallelism TS 2.
* [P2900R6](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2024/p2900r6.pdf): Contracts for C++.

<div class="text-gray-500 text-xs absolute bottom-0 right-0"><SlideCurrentNo/> / <SlidesTotal/></div>
<div class="text-gray-500 text-xs absolute bottom-0 left-0">Александр Фокин | Обзор С++26</div>




---
layout: end
---
