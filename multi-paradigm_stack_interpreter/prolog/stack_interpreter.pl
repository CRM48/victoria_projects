:- use_module(library(pio)).

/*
 * Stack-based language interpreter implemented in Prolog.
 *
 * Supports arithmetic, comparison and boolean operations,
 * stack manipulation, strings, vectors, matrices, conditional
 * operations, expression evaluation and lambda expressions.
 *
 * This implementation uses Prolog predicates, recursion and
 * pattern matching to process and evaluate stack-based expressions.
 */

main :-
    current_prolog_flag(argv, [FileName|_]),
    read_all_elements(FileName, List),
    process_stack(List, [], RevStack),
    reverse(RevStack, Stack),
    output_name(FileName, OutputFile),
    open(OutputFile, write, Stream),
    write_stack_to_file(Stack, Stream),
    close(Stream),
    halt.

output_name(FileName, OutputFile) :-
    string_chars(FileName, CharList),
    length(CharList, Len),
    StartIndex is max(Len - 7, 0),
    length(Prefix, StartIndex),
    append(Prefix, Last7Chars, CharList),
    string_chars(Last7String, Last7Chars),
    string_concat("output-", Last7String, OutputFile).

write_stack_to_file([], _).
write_stack_to_file([H|T], Stream) :-
    writeln(Stream, H),
    write_stack_to_file(T, Stream).

% Proces the file into a list of its elements
read_all_elements(File, Elements) :-
    open(File, read, Stream),
    read_string(Stream, _, Content),
    close(Stream),
    string_chars(Content, CharList),
    split(CharList, AllElements),
    remove_whitespace(AllElements, ValuedElements),
    convert_elements(ValuedElements, Elements).

/*
 * Tokenisation
 *
 * Splits the input into strings, lambda expressions,
 * vectors/matrices, words and individual tokens.
 */

% Base Case
split([], []).

% String Literal case
split(['"'|T], [String|Rest]) :-
    compute_string(T, ['"'], String, Remaining),
    split(Remaining, Rest), !.

% Lambda Case
split(['{'|T], [String|Rest]) :-
    compute_curly(T, ['{'], String, Remaining),
    split(Remaining, Rest), !.

% Matrix/Vector case
split(['['|T], [String|Rest]) :-
    compute_square(T, ['['], String, Remaining, 1),
    split(Remaining, Rest).

% Word case
split([H|T], [Word|Rest]) :-
    \+ is_whitespace(H),
    \+ is_special(H),
    build_word(T, [H], RevChars, Remaining),
    reverse(RevChars, WordChars),
    string_chars(Word, WordChars),
    split(Remaining, Rest), !.

% Character case
split([H|T], [H|Rest]) :-
    \+ is_special(H),
    split(T, Rest), !.


% Build a word until whitespace or special character is encountered
build_word([], Acc, Acc, []).
build_word([H|T], Acc, Acc, [H|T]) :- is_whitespace(H), !.
build_word([H|T], Acc, Word, Remaining) :- build_word(T, [H|Acc], Word, Remaining).


% If closing quote found, stop recursion
compute_string(['"'|Rest], Acc, String, Rest) :-
    reverse(['"'|Acc], CorrectOrder),
    string_chars(String, CorrectOrder), !.

% If not closing quote, keep recursing
compute_string([H|T], Acc, String, Rest) :- compute_string(T, [H|Acc], String, Rest).


% If closing curly brace found, stop
compute_curly(['}'|Rest], Acc, String, Rest) :-
    reverse(['}'|Acc], CorrectOrder),
    string_chars(String, CorrectOrder), !.

% If not closing brace, keep recursing
compute_curly([H|T], Acc, String, Rest) :- compute_curly(T, [H|Acc], String, Rest).

% If square brackets are equal, stop
compute_square(Rest, Acc, String, Remaining, 0) :-
    reverse(Acc, CorrectOrder),
    string_chars(String, CorrectOrder),
    Remaining = Rest, !.

% If opening brace, add to count
compute_square(['['|Rest], Acc, String, Remaining, Count) :-
    NewCount is Count + 1,
    compute_square(Rest, ['['|Acc], String, Remaining, NewCount).

% If closing brace, minus from count
compute_square([']'|Rest], Acc, String, Remaining, Count) :-
    NewCount is Count - 1,
    compute_square(Rest, [']'|Acc], String, Remaining, NewCount).

% If not brace, continue
compute_square([H|Rest], Acc, String, Remaining, Count) :- compute_square(Rest, [H|Acc], String, Remaining, Count).


% Whitespace definitions
is_whitespace(' ')  :- !.
is_whitespace('\n') :- !.
is_whitespace('\t') :- !.
is_whitespace('\r') :- !.

% Special character definitions
is_special('"')  :- !.
is_special('{')  :- !.
is_special('}')  :- !.
is_special('[')  :- !.
is_special(']')  :- !.

% Remove whitespace, tab, or newline elements
remove_whitespace([], []).
remove_whitespace([H|T], R) :-
    is_whitespace(H), !,
    remove_whitespace(T, R).
remove_whitespace([H|T], [H|R]) :-
    remove_whitespace(T, R).

% Convert elements to ints/floats where possible
convert_elements([], []).
convert_elements([H|T], [Converted|Rest]) :-
    convert(H, Converted),
    convert_elements(T, Rest).

convert(H, Number) :-
    ( atom(H) -> atom_string(H, S) ; S = H ),
    number_string(Number, S), !.

convert(H, true) :-
    ( atom(H) -> atom_string(H, S) ; S = H ),
    S = "true", !.

convert(H, false) :-
    ( atom(H) -> atom_string(H, S) ; S = H ),
    S = "false", !.

convert(H, List) :-
    ( atom(H) -> atom_string(H, S) ; S = H ),
    string_chars(S, ['['|_]),  % looks like a list
    catch(term_string(List, S), _, fail),
    is_list(List), !.

convert(H, H).


/*
 * Stack evaluation
 *
 * Processes each token according to its type and applies
 * the corresponding operation to the stack.
 */

% Base case
process_stack([], Stack, Stack).

% Add Ints, Floats, Bools and matrices/vectors to the stack
process_stack([H|T], Stack, Result) :-
    (integer(H); float(H); is_bool(H); is_list(H)),
    process_stack(T, [H|Stack], Result), !.

% Add strings
process_stack([H|T], Stack, Result) :-
    string_chars(H, [First | _]),
    First = '"',
    process_stack(T, [H|Stack], Result), !.

% Add quotes
process_stack([H|T], Stack, Result) :-
    string_chars(H, [First | Rest]),
    (First = '\''),
    string_chars(Op, Rest),
    convert(Op, ConvOp),
    process_stack(T, [ConvOp|Stack], Result), !.

% Regular commands (work regardless of type)
process_stack([Command|T], Stack, Result) :-
    is_command(Command),
    apply_command(Command, Stack, NewStack),
    process_stack(T, NewStack, Result), !.

% Comparisons (only for string or number pairs)
process_stack([Comparison|T], [H, S | Stack], Result) :-
    is_comparison(Comparison),
    ((is_string(H), is_string(S)); (number(H), number(S))),
    apply_comparison(Comparison, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Integer and float binary operators
process_stack([Op | T], [H, S | Stack], Result) :-
    is_num_operator(Op),
    (integer(H); float(H)),
    (integer(S); float(S)),
    apply_operator(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Integer and float unary operators (only ~ at this case)
process_stack([Op | T], [H | Stack], Result) :-
    is_unary_num_operator(Op),
    (integer(H); float(H)),
    apply_operator(Op, [H | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Boolean binary operators
process_stack([Op | T], [H, S | Stack], Result) :-
    is_bool_operator(Op),
    (is_bool(H), is_bool(S)),
    apply_bool_comparison(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Boolean unary operators
process_stack([Op | T], [H | Stack], Result) :-
    is_unary_bool_operator(Op),
    is_bool(H),
    apply_operator(Op, [H | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Two string input operators (just + in this case)
process_stack([Op | T], [H, S | Stack], Result) :-
    is_string_operator(Op),
    (is_string(H), is_string(S)),
    apply_string_operator(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% String and Int inputs
process_stack([Op | T], [H, S | Stack], Result) :-
    is_special_string_operator(Op),
    (integer(H), is_string(S)),
    apply_string_operator(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Binary Matrix operators
process_stack([Op | T], [H, S | Stack], Result) :-
    is_matrix_operator(Op),
    (is_matrix(H), is_matrix(S)),
    apply_matrix_operator(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Unary Matrix operators (TRANSP)
process_stack([Op | T], [H | Stack], Result) :-
    is_unary_matrix_operator(Op),
    is_matrix(H),
    apply_matrix_operator(Op, [H | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Binary Vector operators
process_stack([Op | T], [H, S | Stack], Result) :-
    is_vector_operator(Op),
    (is_vector(H), is_vector(S)),
    apply_vector_operator(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Unary Vector operators (TRANSP)
process_stack([Op | T], [H | Stack], Result) :-
    is_vector_operator(Op),
    is_vector(H),
    apply_vector_operator(Op, [H | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Matrix and Vector operations (*)
process_stack([Op | T], [H, S | Stack], Result) :-
    is_matrix_vector_operator(Op),
    ((is_matrix(H), is_vector(S)); (is_vector(H), is_matrix(S))),
    apply_matrix_operator(Op, [H, S | Stack], NewStack),
    process_stack(T, NewStack, Result), !.

% Handle Lambdas
process_stack([H | T], Stack, Result) :-
    string_chars(H, [First | _]),
    First = '{',
    apply_lambda_operations(H, Stack, NewStack),
    process_stack(T, NewStack, Result), !.

% Unexpected input
process_stack([H | _], _, _) :- 
    writeln("Error, could not process:"), writeln(H), 
    fail.


/*
 * Operator definitions
 *
 * Defines the supported operators and the operand types
 * they can be applied to.
 */

is_num_operator("+"). 
is_num_operator("*").
is_num_operator("-").
is_num_operator("/").
is_num_operator("**").
is_num_operator("%").
is_num_operator("<<").
is_num_operator(">>").
is_num_operator("^").
is_unary_num_operator("~").

is_bool_operator("&").
is_bool_operator("|").
is_bool_operator("^").
is_unary_bool_operator("!").
is_unary_bool_operator("IFELSE").

is_string_operator("+"). 
is_special_string_operator("*").

is_list_operator("+").
is_list_operator("x").
is_list_operator("TRANSP").

is_matrix_operator("+").
is_matrix_operator("*").
is_unary_matrix_operator("TRANSP").

is_vector_operator("+").
is_vector_operator("*").
is_vector_operator("x").
is_vector_operator("TRANSP").

is_matrix_vector_operator("*").

is_command("DROP").
is_command("DUP").
is_command("SWAP").
is_command("ROT").
is_command("ROLL").
is_command("ROLLD").
is_command("EVAL").

is_comparison("==").
is_comparison("!=").
is_comparison(">").
is_comparison("<").
is_comparison(">=").
is_comparison("<=").
is_comparison("<=>").

/*
 * Operator implementations
 *
 * Contains the predicates used to perform arithmetic,
 * comparison, boolean, string, vector and matrix operations.
 */

apply_operator("+", [X, Y | Rest], [Sum | Rest]) :- Sum is X + Y.
apply_operator("*", [X, Y | Rest], [Product | Rest]) :- Product is X * Y.
apply_operator("-", [X, Y | Rest], [Difference | Rest]) :- Difference is Y - X.
apply_operator("/", [X, Y | Rest], [Division | Rest]) :- Division is Y / X.
apply_operator("**", [X, Y | Rest], [Division | Rest]) :- Division is Y ** X.
apply_operator("%", [X, Y | Rest], [Division | Rest]) :- Division is Y mod X.
apply_operator("<<", [X, Y | Rest], [Result | Rest]) :- Result is Y << X.
apply_operator(">>", [X, Y | Rest], [Result | Rest]) :- Result is Y >> X.
apply_operator("~", [X | Rest], [Result | Rest]) :- Result is \ X.
apply_operator("^", [X, Y | Rest], [Result | Rest]) :- Result is xor(Y, X).
apply_operator("!", [X | Rest], [Result | Rest]) :- bool_not(X, Result).
apply_operator("IFELSE", [X | Rest], Result) :- ifelse(Rest, X, Result).

apply_command("DROP", [_ | Rest], Rest).
apply_command("DUP", [X | Rest], [X, X |Rest]).
apply_command("SWAP", [X, Y | Rest], [Y, X | Rest]).
apply_command("ROT", [X, Y, Z | Rest], [Z, X, Y | Rest]).
apply_command("ROLL", [X | Rest], Result) :- roll(Rest, X, [], Result).
apply_command("ROLLD", [X | Rest], Result) :- rolld(Rest, X, Result).
apply_command("EVAL", [Op | Stack], Result) :- process_stack([Op], Stack, Result).

apply_comparison("==", [X, Y | Rest], [Result | Rest]) :- (Y == X -> Result = true ; Result = false).
apply_comparison("!=", [X, Y | Rest], [Result | Rest]) :- (Y \== X -> Result = true ; Result = false).
apply_comparison(">", [X, Y | Rest], [Result | Rest]) :- (Y > X -> Result = true ; Result = false).
apply_comparison("<", [X, Y | Rest], [Result | Rest]) :- (Y < X -> Result = true ; Result = false).
apply_comparison(">=", [X, Y | Rest], [Result | Rest]) :- (Y >= X -> Result = true ; Result = false).
apply_comparison("<=", [X, Y | Rest], [Result | Rest]) :- (Y =< X -> Result = true ; Result = false).
apply_comparison("<=>", [X, Y | Rest], [Result | Rest]) :- (Y < X -> Result = -1; Y > X -> Result = 1; Y == X -> Result = 0).

apply_bool_comparison("&", [X, Y | Rest], [Result | Rest]) :- bool_and(X, Y, Result).
apply_bool_comparison("|", [X, Y | Rest], [Result | Rest]) :- bool_or(X, Y, Result).
apply_bool_comparison("^", [X, Y | Rest], [Result | Rest]) :- bool_xor(X, Y, Result).


apply_matrix_operator("+", [X, Y | Rest], [Result | Rest]) :- matrix_add(Y, X, Result).
apply_matrix_operator("*", [X, Y | Rest], [Result | Rest]) :- matrix_multiply(Y, X, Result).
apply_matrix_operator("TRANSP", [X | Rest], [Result | Rest]) :- transpose(X, Result).

apply_vector_operator("+", [X, Y | Rest], [Result | Rest]) :- vector_add(Y, X, Result).
apply_vector_operator("*", [X, Y | Rest], [Result | Rest]) :- dot_product(Y, X, Result).
apply_vector_operator("x", [X, Y | Rest], [Result | Rest]) :- cross_product(Y, X, Result).
apply_vector_operator("TRANSP", [X | Rest], [Result | Rest]) :- transpose_vector(X, Result).

% Need to figure out a way to remove the end quotes of Y and start of X
apply_string_operator("+", [X, Y | Rest], [Result | Rest]) :- 
    remove_quotes(Y, Stripped_Y),
    remove_quotes(X, Stripped_X),
    combine_strings(Stripped_Y, Stripped_X, Nude_Result),
    add_quotes(Nude_Result, Result).

apply_string_operator("*", [X, Y | Rest], [Result | Rest]) :-
    remove_quotes(Y, Stripped_Y),
    multiply_strings(Stripped_Y, X, Nude_Result),
    add_quotes(Nude_Result, Result).

apply_lambda_operations(H, Stack, Result) :-
    % Split lambda expression into number of parameters, and the expression
    remove_braces(H, Inner),
    split_string(Inner, "|", " ", [ArgStr, BodyStr]),
    normalize_space(atom(ArgStrClean), ArgStr), 
    atom_number(ArgStrClean, N),

    % Pop N elements and substitute into expression
    pop_n_elements(N, Stack, Args, RemainingStack),
    reverse(Args, RevArgs),
    make_var_map(RevArgs, 0, VarPairs),
    split_string(BodyStr, " ", "", BodyElements),
    
    substitute_variables(BodyElements, VarPairs, H, SubstitutedBody), 
    

    % Convert elements and process the expression
    convert_elements(SubstitutedBody, ConvertedElements),
    process_stack(ConvertedElements, RemainingStack, Result).


/*
 * Helper predicates
 *
 * Utility predicates used by the stack operations,
 * matrix/vector functions and lambda evaluation.
 */

% Roll N elements
roll(Rest, 0, _, Rest).
roll([H | Rest], 1, Acc, [H | Result]) :-
    reverse(Acc, RevAcc),
    append(RevAcc, Rest, Result).

roll([H | T], N, Acc, Result) :-
    N1 is N - 1,
    roll(T, N1, [H | Acc], Result).

% Roll in reverse order
rolld(Rest, 0, Rest).
rolld([H | Rest], N, Result) :-
    Num is N-1,
    length(Substring, Num),
    append(Substring, Remainder, Rest),
    append(Substring, [H], Acc),
    append(Acc, Remainder, Result).

% Handle if else command
ifelse([_ | Rest], true, Rest).
ifelse([H, _ | Rest], false, [H | Rest]).


% Bool operations
bool_and(true, true, true).
bool_and(_, _, false).

bool_or(false, false, false).
bool_or(_, _, true).

bool_xor(false, true, true).
bool_xor(true, false, true).
bool_xor(_, _, false).

bool_not(true, false).
bool_not(false, true).

% Remove from and add quotes to strings
remove_quotes(String, Result) :-
    string_chars(String, Chars),
    append(['"'], End, Chars),
    append(Middle, ['"'], End),
    string_chars(Result, Middle).

add_quotes(String, Result) :- 
    string_chars(String, Chars),
    append(['"' | Chars], ['"'], QuotedChars),
    string_chars(Result, QuotedChars).

remove_braces(String, Result) :-
    string_chars(String, Chars),
    append(['{'], End, Chars),
    append(Middle, ['}'], End),
    string_chars(Result, Middle).

% Combine two strings
combine_strings(First, Second, Result) :- string_concat(First, Second, Result).

% Append string to itself (Num-1) times
multiply_strings(_, 0, "") :- !.
multiply_strings(String, Num, Result) :-
    Num > 0,
    N1 is Num - 1,
    multiply_strings(String, N1, Partial),
    string_concat(Partial, String, Result).


% Adds two matrices element-wise
matrix_add([], [], []).
matrix_add([Row1|Rest1], [Row2|Rest2], [RowSum|RestSum]) :-
    vector_add(Row1, Row2, RowSum),
    matrix_add(Rest1, Rest2, RestSum).

% Adds two vectors element-wise
vector_add([], [], []).
vector_add([X|Xs], [Y|Ys], [Z|Zs]) :-
    Z is X + Y,
    vector_add(Xs, Ys, Zs).

add_vertices([], [], []).
add_vertices([X|Xs], [Y|Ys], [Z|Zs]) :-
    Z is X + Y,
    add_vertices(Xs, Ys, Zs).

% Multiply two matrices
matrix_multiply(A, B, Result) :-
    wrap_vector_if_needed(A, A1),
    wrap_vector_if_needed(B, B1),
    transpose(B1, BT),  % Transpose B to access its columns as rows
    maplist(multiply_row(BT), A1, Intermediate),
    flatten_if_column_matrix(Intermediate, Result).

% Multiply one row of A by all rows of BT (columns of B)
multiply_row(BT, Row, ResultRow) :- maplist(dot_product(Row), BT, ResultRow).

% Dot product of two vectors
dot_product([], [], 0).
dot_product([X|Xs], [Y|Ys], Result) :-
    dot_product(Xs, Ys, Partial),
    Result is Partial + X * Y.

% Cross product of two vectors
cross_product([A1, A2, A3], [B1, B2, B3], [C1, C2, C3]) :-
    C1 is A2 * B3 - A3 * B2,
    C2 is A3 * B1 - A1 * B3,
    C3 is A1 * B2 - A2 * B1.

% Transpose of a matrix
transpose([], []).
transpose([[]|_], []) :- !.
transpose(Matrix, [Row|Rows]) :-
    maplist(list_head_tail, Matrix, Row, RestMatrix),
    transpose(RestMatrix, Rows).

% Transpose a Vector
transpose_vector(Vector, Matrix) :-maplist(wrap_in_list, Vector, Matrix).

list_head_tail([H|T], H, T).
wrap_in_list(Element, [Element]).

% Wraps vector in [] for matrix multiplication
wrap_vector_if_needed(List, Matrix) :-
    is_vector(List), !,
    maplist(wrap_in_list, List, Matrix).
wrap_vector_if_needed(Matrix, Matrix).

% Matrix/Vector multiplication results in column matrix, this converts to vector
is_column_matrix([]).
is_column_matrix([[ _ ] | T]) :- is_column_matrix(T).

flatten_column_matrix(Matrix, Flat) :- maplist(nth0(0), Matrix, Flat).

flatten_if_column_matrix(Matrix, Flat) :-
    is_column_matrix(Matrix),
    flatten_column_matrix(Matrix, Flat).

flatten_if_column_matrix(Matrix, Matrix).



% Lambda predicates
pop_n_elements(0, Stack, [], Stack).
pop_n_elements(N, [H|T], [H|Rest], Remaining) :-
    N > 0,
    N1 is N - 1,
    pop_n_elements(N1, T, Rest, Remaining).

make_var_map([], _, []).
make_var_map([Value | Rest], Index, [VarName-Value | MapRest]) :-
    atomic_list_concat(['x', Index], VarName),
    NextIndex is Index + 1,
    make_var_map(Rest, NextIndex, MapRest).

substitute_variables([], _, _, []).
substitute_variables([H|T], VarMap, Lambda, [ValueStr|RestSub]) :-
    atom_string(HAtom, H),
    member(HAtom-Value, VarMap), !,
    term_string(Value, ValueStr),
    substitute_variables(T, VarMap, Lambda, RestSub).
substitute_variables(["SELF"|T], VarMap, Lambda, [QuotedLambda | RestSub]) :-
    string_concat("'", Lambda, QuotedLambda),
    substitute_variables(T, VarMap, Lambda, RestSub).
substitute_variables([H|T], VarMap, Lambda, [H|RestSub]) :- substitute_variables(T, VarMap, Lambda, RestSub).


/*
 * Type checking
 *
 * Predicates used to identify strings, booleans,
 * vectors and matrices.
 */

% Checks if string element
is_string(Element) :-
    string(Element),
    string_chars(Element, [First|_]),
    First = '"'.

% Facts to define bool elements
is_bool(false).
is_bool(true).

% Checks if matrix element
is_matrix([]).
is_matrix([H|T]) :- is_list(H), is_matrix(T). 

% Checks if vector element
is_vector([]).
is_vector(List) :- is_list(List), \+ is_matrix(List).

/*
 * Finally, this is a function for type checking.
 */


% Prints typing of elements
print_elements_with_types([]).
print_elements_with_types([H|T]) :-
    ( integer(H) -> Type = 'integer'
    ; float(H)   -> Type = 'float'
    ; atom(H)    -> Type = 'atom'
    ; string(H)  -> Type = 'string'
    ; is_matrix(H) -> Type = 'matrix'
    ; is_list(H) -> Type = 'list'
    ; Type = 'unknown'
    ),
    format('Value: ~w, Type: ~w~n', [H, Type]),
    print_elements_with_types(T).

