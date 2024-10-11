% Declare dynamic predicates to store lists, sort times, and cumulative times
:- dynamic saved_list/2.
:- dynamic sort_time/3.  % Stores individual times per run
:- dynamic cumulative_time/2.
:- dynamic times_list/2.  % Stores a list of times for each algorithm

% Generate a random list of given length
randomList(0, []).  % Base case: List with 0 elements is empty
randomList(N, [X|T]) :-
    N > 0,  
    Lower = 1,  
    Upper = 100,
    random(Lower, Upper, X),  % Generate a random number X between Lower and Upper
    N1 is N - 1,
    randomList(N1, T).  % Recursively generate rest of the list

% Create 50 random lists and store them in the knowledge base
create_and_save_lists :-
    between(1, 50, N),
    random_between(5, 10, Length),  % Increased length to reduce timing noise
    randomList(Length, List),
    assertz(saved_list(N, List)),
    fail.  % Fail to force backtracking and continue creating lists
create_and_save_lists.

% Print all saved lists from the knowledge base
print_saved_lists :-
    saved_list(ID, List),
    format("List ~w: ~w~n", [ID, List]),
    fail.  % Fail to force backtracking and print all lists
print_saved_lists.

% Swap the first two elements if they are not in order
swap([X, Y|T], [Y, X|T]) :- Y < X.
% Swap elements in the tail
swap([H|T], [H|T1]) :- swap(T, T1).

% Bubble Sort: Sort a list using bubble sort
bubbleSort(L, SL) :-
    swap(L, L1), !,  % Ensure at least one swap happens, use cut to prevent looping
    bubbleSort(L1, SL).
bubbleSort(L, L).  % Base case: list is sorted

% Ordered: Check if the list is sorted in non-decreasing order
ordered([]).
ordered([_]).
ordered([H1, H2|T]) :-
    H1 =< H2,
    ordered([H2|T]).

% Insertion Sort: Sort a list using insertion sort
insertionSort([], []).
insertionSort([H|T], Sorted) :-
    insertionSort(T, T1),
    insert(H, T1, Sorted).

% Insert element into the sorted list
insert(X, [], [X]).
insert(E, [H|T], [E, H|T]) :- E =< H, !.
insert(E, [H|T], [H|T1]) :- insert(E, T, T1).

% Merge Sort: Sort a list using merge sort
mergeSort([], []).
mergeSort([X], [X]) :- !.
mergeSort(L, Sorted) :-
    split_in_half(L, L1, L2),
    mergeSort(L1, S1),
    mergeSort(L2, S2),
    merge(S1, S2, Sorted).

% Split a list into two halves
split_in_half(L, L1, L2) :-
    length(L, N),
    Half is N // 2,
    length(L1, Half),
    append(L1, L2, L).

% Merge two sorted lists
merge([], L, L).
merge(L, [], L).
merge([H1|T1], [H2|T2], [H1|T]) :-
    H1 =< H2, !,
    merge(T1, [H2|T2], T).
merge([H1|T1], [H2|T2], [H2|T]) :-
    merge([H1|T1], T2, T).

% Quick Sort: Sort a list using quick sort
quickSort([], []).
quickSort([H|T], Sorted) :-
    split(H, T, Small, Big),
    quickSort(Small, S1),
    quickSort(Big, S2),
    append(S1, [H|S2], Sorted).

% Split list based on pivot
split(_, [], [], []).
split(Pivot, [H|T], [H|Small], Big) :-
    H =< Pivot, !,
    split(Pivot, T, Small, Big).
split(Pivot, [H|T], Small, [H|Big]) :-
    split(Pivot, T, Small, Big).

% Hybrid Sort: Combines small and big sorts based on a threshold
hybridSort(List, SmallAlg, BigAlg, Threshold, Sorted) :-
    length(List, N), N =< Threshold, !,
    call(SmallAlg, List, Sorted).
hybridSort(List, SmallAlg, BigAlg, Threshold, Sorted) :-
    ( BigAlg == mergeSort ->
        split_in_half(List, L1, L2),
        hybridSort(L1, SmallAlg, BigAlg, Threshold, S1),
        hybridSort(L2, SmallAlg, BigAlg, Threshold, S2),
        merge(S1, S2, Sorted)
    ; BigAlg == quickSort ->
        List = [H|T],
        split(H, T, L1, L2),
        hybridSort(L1, SmallAlg, BigAlg, Threshold, S1),
        hybridSort(L2, SmallAlg, BigAlg, Threshold, S2),
        append(S1, [H|S2], Sorted)
    ).

% Accumulate CPU time for each sorting algorithm (in milliseconds)
accumulate_time(Algorithm, Time) :-
    TimeInMilliseconds is Time * 1000,  % Convert seconds to milliseconds
    ( cumulative_time(Algorithm, PrevTime) ->
        NewTime is PrevTime + TimeInMilliseconds,
        retract(cumulative_time(Algorithm, PrevTime)),
        assertz(cumulative_time(Algorithm, NewTime))
    ; assertz(cumulative_time(Algorithm, TimeInMilliseconds))
    ).

% Store individual run times in a list
store_time(Algorithm, Time) :-
    TimeInMilliseconds is Time * 1000,  % Convert seconds to milliseconds
    ( times_list(Algorithm, Times) ->
        append(Times, [TimeInMilliseconds], NewTimes),
        retract(times_list(Algorithm, Times)),
        assertz(times_list(Algorithm, NewTimes))
    ; assertz(times_list(Algorithm, [TimeInMilliseconds]))
    ).

% Reset all cumulative times and times lists
reset_all_times :-
    retractall(cumulative_time(_, _)),
    retractall(times_list(_, _)).

% Process all saved lists recursively
run_sorts_for_all_lists :-
    saved_list(_, List),
    run_sorting_algorithms(List),
    fail.
run_sorts_for_all_lists.

% Run sorting algorithms and time each
run_sorting_algorithms(List) :-
    % Bubble Sort
    get_time(T0),
    bubbleSort(List, _),
    get_time(T1),
    T_Bubble is T1 - T0,
    accumulate_time(bubbleSort, T_Bubble),
    store_time(bubbleSort, T_Bubble),

    % Insertion Sort
    get_time(T2),
    insertionSort(List, _),
    get_time(T3),
    T_Insertion is T3 - T2,
    accumulate_time(insertionSort, T_Insertion),
    store_time(insertionSort, T_Insertion),

    % Merge Sort
    get_time(T4),
    mergeSort(List, _),
    get_time(T5),
    T_Merge is T5 - T4,
    accumulate_time(mergeSort, T_Merge),
    store_time(mergeSort, T_Merge),

    % Quick Sort
    get_time(T6),
    quickSort(List, _),
    get_time(T7),
    T_Quick is T7 - T6,
    accumulate_time(quickSort, T_Quick),
    store_time(quickSort, T_Quick),

    % Hybrid Sort (Insertion Sort + Merge Sort)
    get_time(T8),
    hybridSort(List, insertionSort, mergeSort, 10, _),
    get_time(T9),
    T_Hybrid1 is T9 - T8,
    accumulate_time(hybridSort_1, T_Hybrid1),
    store_time(hybridSort_1, T_Hybrid1),

    % Hybrid Sort (Insertion Sort + Quick Sort)
    get_time(T10),
    hybridSort(List, insertionSort, quickSort, 10, _),
    get_time(T11),
    T_Hybrid2 is T11 - T10,
    accumulate_time(hybridSort_2, T_Hybrid2),
    store_time(hybridSort_2, T_Hybrid2),

    % Hybrid Sort (Bubble Sort + Merge Sort)
    get_time(T12),
    hybridSort(List, bubbleSort, mergeSort, 10, _),
    get_time(T13),
    T_Hybrid3 is T13 - T12,
    accumulate_time(hybridSort_3, T_Hybrid3),
    store_time(hybridSort_3, T_Hybrid3),

    % Hybrid Sort (Bubble Sort + Quick Sort)
    get_time(T14),
    hybridSort(List, bubbleSort, quickSort, 10, _),
    get_time(T15),
    T_Hybrid4 is T15 - T14,
    accumulate_time(hybridSort_4, T_Hybrid4),
    store_time(hybridSort_4, T_Hybrid4).

% Print cumulative and average times for each algorithm
print_cumulative_and_average_times :-
    cumulative_time(Algorithm, CumulativeTime),
    times_list(Algorithm, Times),
    length(Times, Count),
    AverageTime is CumulativeTime / 1,  % Calculate average
    format('Algorithm: ~w, Cumulative CPU time: ~2f ms, Average CPU time: ~2f ms~n', [Algorithm, CumulativeTime, AverageTime]),
    fail.
print_cumulative_and_average_times.

% Print each algorithm's list of times
print_times_list :-
    times_list(Algorithm, Times),
    format('Algorithm: ~w, Times: ~w~n', [Algorithm, Times]),
    fail.
print_times_list.

% Provide each algorithm's list of times without modifying the database
get_times_list(Algorithm, Times) :-
    times_list(Algorithm, Times).
