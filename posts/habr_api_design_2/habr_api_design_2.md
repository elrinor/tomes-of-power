RAII always and everywhere.

`[[nodiscard]]`
add_compile_options(/we4834) # Discarding return value of function with 'nodiscard' attribute
add_compile_options(-Werror=unused-result) # Ignoring return value of function declared with 'nodiscard' attribute // clang & gcc

`[[noreturn]]`
add_compile_options(-Werror=invalid-noreturn) # function declared 'noreturn' should not return. // clang

`std::unique_ptr`

`std::shared_ptr<void>`?

`noexcept`
add_compile_options(/we26447) # The function is declared noexcept but calls function 'X' that may throw exceptions
-Wexceptions # 'X' has a non-throwing exception specification but can still throw
https://clang.llvm.org/extra/clang-tidy/checks/bugprone/exception-escape.html


`enum class` && `using enum`

`class Flags`

`class BitFlags`

`int` everywhere

`fmt::format` & FMT_CONSTEVAL

`exceptions` - dont use for control flow, exception should usually mean "input is borked"
`assert` - programmer error

https://clang.llvm.org/docs/AttributeReference.html#lifetimebound

CMAKELISTS

threading annotations
https://clang.llvm.org/docs/ThreadSafetyAnalysis.html
https://stackoverflow.com/questions/30348480/clang-thread-safety-analysis-with-c-standard-library
https://llvm.org/devmtg/2011-11/Hutchins_ThreadSafety.pdf

[[clang::reinitializes]]

[[clang::acquire_handle]]

`_Nonnull`
`_Nullable`
`_Null_unspecified`
    valid_ptr<T>
    optional_ptr<T>


explicit
Explicit<>
std::same_as<T> value
= delete
static_assert("blabla")


const/pure
https://gcc.gnu.org/onlinedocs/gcc/Common-Function-Attributes.html



also check clang-tidy.











