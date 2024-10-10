% Declare dynamic predicates to store lists, sort times, and cumulative times
:- dynamic saved_list/2.
:- dynamic sort_time/3.  % Stores individual times per run
:- dynamic cumulative_time/2.
:- dynamic times_list/2.  % Stores a list of times for each algorithm

randomList(0, []).  % Base case: List with 0 should be considered empty
randomList(N, [X|T]) :-
    N > 0,  % List can only contain positive #'s
    % Define upper and lower for random numbers to be between
    Lower = 1,  
    Upper = 100,
    
    random(Lower, Upper, X),  % Generate a random number X
    N1 is N - 1,  % Decrement N
    randomList(N1, T).  % Recursively generate rest of the list

% Create 50 random lists and store them in the knowledge base
create_and_save_lists :-
    between(1, 50, N),
    random_between(5, 10, Length),
    randomList(Length, List),
    assertz(saved_list(N, List)),
    fail.  % Fail to force backtracking and continue creating lists
create_and_save_lists.

% To print all saved lists from the knowledge base
print_saved_lists :-
    saved_list(ID, List),
    format("List ~w: ~w~n", [ID, List]),
    fail.  % Fail to force backtracking and print all lists
print_saved_lists.

/*swap the first two elements if they are not in order*/
swap([X, Y|T], [Y, X|T]) :- Y < X.
/*swap elements in the tail*/
swap([H|T], [H|T1]) :- swap(T, T1).

/*bubbleSort:
 * repeatedly compares and swaps adjacent elements 
 * until the list is sorted. It has a average/worst-case time complexity of O(n^2), making it inefficient for large lists.
 * It takes an unsorted list and returns a sorted list.
 *  */
bubbleSort(L,SL):-
  swap(L, L1), % at least one swap is needed
  !,
  bubbleSort(L1, SL).
bubbleSort(L, L). % here, the list is already sorted


/* ordered:
 * checks if a list is sorted in non-decreasing order.
 * It recursively compares all the elements, ensuring each one is less than or equal to it adjacent.
 * It succeeds if the list is ordered, and fails otherwise.
 * */
ordered([]).
ordered([_X]).
ordered([H1, H2|T]):-
  H1 =< H2,
  ordered([H2|T]).

/*insert(E, SL, SLE):
 * Inserts element E into sorted list SL, generating a new sorted list SLE.
 * */

/*insert (first clause): 
 * If SL is empty, SLE becomes only [E].
 * If E is less than or equal to the head of SL, place at front
 * */
insert(X, [],[X]).
insert(E, [H|T], [E,H|T]):-
  ordered(T),
  E =< H,
  !.
/*insert (second clause):
 * If E greater than SL head, use recursion to find the correct position in the tail
 * */
insert(E, [H|T], [H|T1]):-
  ordered(T),
  insert(E, T, T1).

/* insertionSort:
 * Recursively sorts the tail of the list and inserts head into the correct position until ordered.
 * Efficient for small lists, with a average/worst-case time complexity of O(n^2)
 *  */
insertionSort([], []).
insertionSort([H|T], SORTED) :-
  insertionSort(T, T1),
  insert(H, T1, SORTED).


/* mergeSort:
 * A divide-and-conquer sorting algorithm that recursively splits list into halves, sorts each half, and merges them back 
 * together in order until sorted. Average/worst-case time complexity of O(n log n), making it efficient for large lists.
 *  */
mergeSort([], []). % The empty list is sorted
mergeSort([X], [X]):-!.
mergeSort(L, SL):-
  split_in_half(L, L1, L2),
  mergeSort(L1, S1),
  mergeSort(L2, S2),
  merge(S1, S2, SL).

/* split_in_half: divides a list into two halves by calculating the midpoint to create two sublists*/
intDiv(N,N1, R):- R is div(N,N1).
split_in_half([], _, _):-!, fail.
split_in_half([X],[],[X]).
split_in_half(L, L1, L2):-
  length(L,N),
  intDiv(N,2,N1),
  length(L1, N1),
  append(L1, L2, L).

/* merge(S1, S2, S):
 * Combines two sorted lists S1 and S2 into a single sorted list S.
 * It compares the heads of both lists, appending the lesser to S, and recursively merges the remaining elements
 *  */
merge([], L, L). % comment
merge(L, [],L). % comment
merge([H1|T1],[H2|T2],[H1| T]):-
  H1 =< H2,
  merge(T1,[H2|T2],T).
merge([H1|T1], [H2|T2], [H2|T]):-
  H2 =< H1,
  merge([H1|T1], T2, T).

/* split:
 * Divides list into two sublists based on pivot element X. Elements <= X are put in a SMALL list, and those
 * greater than X are put in BIG list.
 *  */
split(_, [],[],[]).
  split(X, [H|T], [H|SMALL], BIG):-
  	H =< X,
  	split(X, T, SMALL, BIG).
split(X, [H|T], SMALL, [H|BIG]):-
  X =< H,
  split(X, T, SMALL, BIG).

/* quickSort:
 * Uses split to divide list into two sublists based on pivot element X, based on SMALL and BIG as previously explained.
 * Then it recursively sorts the sublists and combines them with pivot X to generate the sorted list LS. It is best for 
 * large lists, with an average time complexity of O(n log n) and worst time complexity of O(n^2)
 *  */
quickSort([], []).
quickSort([H|T], LS):-
  split(H, T, SMALL, BIG),
  quickSort(SMALL, S),
  quickSort(BIG, B),
  append(S, [H|B], LS).


/* hybridSort:
 * When the length of LIST is less than THRESHOLD, then hybridSort calls SMALL
 * 
 * When the length of list LIST is greater than or equal to THRESHOLD, then hybridSort behaves
 * like one of the BIG sorts, but it does NOT call it, essentially replicating the behavior of the original implementation
 *  */
hybridSort(LIST, SMALLALG, BIGALG, THRESHOLD, SLIST):-
  length(LIST, N), N =< THRESHOLD, % If list size less than threshold, do small algorithm
  call(SMALLALG, LIST, SLIST). % call the respective small algorithm (bubbleSort or insertionSort)

hybridSort(LIST, SMALLALG, BIGALG, THRESHOLD, SLIST):-
  length(LIST, N), N > THRESHOLD, % If list size more than threshold, do big algorithm
   ( BIGALG == mergeSort -> % If mergeSort, replicate mergeSort behavior with recursive hybridSort in place of mergeSort 
        split_in_half(LIST, L1, L2),
        hybridSort(L1, SMALLALG, mergeSort, THRESHOLD, S1),
        hybridSort(L2, SMALLALG, mergeSort, THRESHOLD, S2),
        merge(S1, S2, SLIST)
    ; BIGALG == quickSort -> % If quickSort, replicate quickSort behavior with recursive hybridSort in place of quickSort 
   		[H|T] = LIST, % Get the head and tail of list for quicksort 
        split(H, T, L1, L2),
        hybridSort(L1, quickSort, BIGALG, THRESHOLD, S1),
        hybridSort(L2, quickSort, BIGALG, THRESHOLD, S2),
        append(S1, [H|S2], SLIST)
    ).

% Accumulate CPU time for each sorting algorithm (in milliseconds)
accumulate_time(Algorithm, TimeInSeconds) :-
    TimeInMilliseconds is TimeInSeconds * 1000,  % Convert to ms
    ( cumulative_time(Algorithm, PrevTime) ->
        NewTime is PrevTime + TimeInMilliseconds,
        retract(cumulative_time(Algorithm, PrevTime)),
        assertz(cumulative_time(Algorithm, NewTime))
    ; assertz(cumulative_time(Algorithm, TimeInMilliseconds))
    ).

% Store each individual run time in a list (for easier Python consumption)
store_time(Algorithm, TimeInMilliseconds) :-
    ( times_list(Algorithm, Times) ->
        append(Times, [TimeInMilliseconds], NewTimes),
        retract(times_list(Algorithm, Times)),
        assertz(times_list(Algorithm, NewTimes))
    ; assertz(times_list(Algorithm, [TimeInMilliseconds]))
    ).

% Run and time each sorting algorithm for a given list
run_sorting_algorithms(List) :-
    % Bubble Sort
    statistics(cputime, T0),
    bubbleSort(List, _SortedBubble),
    statistics(cputime, T1),
    T_Bubble is (T1 - T0) * 1000,  % Convert to ms
    accumulate_time(bubbleSort, T_Bubble),
    store_time(bubbleSort, T_Bubble),
    format('Algorithm: bubbleSort, CPU time: ~2f ms~n', [T_Bubble]),

    % Insertion Sort
    statistics(cputime, T2),
    insertionSort(List, _SortedInsertion),
    statistics(cputime, T3),
    T_Insertion is (T3 - T2) * 1000,  % Convert to ms
    accumulate_time(insertionSort, T_Insertion),
    store_time(insertionSort, T_Insertion),
    format('Algorithm: insertionSort, CPU time: ~2f ms~n', [T_Insertion]),

    % Merge Sort
    statistics(cputime, T4),
    mergeSort(List, _SortedMerge),
    statistics(cputime, T5),
    T_Merge is (T5 - T4) * 1000,  % Convert to ms
    accumulate_time(mergeSort, T_Merge),
    store_time(mergeSort, T_Merge),
    format('Algorithm: mergeSort, CPU time: ~2f ms~n', [T_Merge]),

    % Quick Sort
    statistics(cputime, T6),
    quickSort(List, _SortedQuick),
    statistics(cputime, T7),
    T_Quick is (T7 - T6) * 1000,  % Convert to ms
    accumulate_time(quickSort, T_Quick),
    store_time(quickSort, T_Quick),
    format('Algorithm: quickSort, CPU time: ~2f ms~n', [T_Quick]),

    % Hybrid Sort (Insertion Sort + Merge Sort)
    statistics(cputime, T8),
    hybridSort(List, insertionSort, mergeSort, 5, _SortedHybrid1),
    statistics(cputime, T9),
    T_Hybrid1 is (T9 - T8) * 1000,  % Convert to ms
    accumulate_time(hybridSort_1, T_Hybrid1),
    store_time(hybridSort_1, T_Hybrid1),
    format('Algorithm: hybridSort_1 (InsertionSort + MergeSort), CPU time: ~2f ms~n', [T_Hybrid1]),

    % Hybrid Sort (Insertion Sort + Quick Sort)
    statistics(cputime, T10),
    hybridSort(List, insertionSort, quickSort, 5, _SortedHybrid2),
    statistics(cputime, T11),
    T_Hybrid2 is (T11 - T10) * 1000,  % Convert to ms
    accumulate_time(hybridSort_2, T_Hybrid2),
    store_time(hybridSort_2, T_Hybrid2),
    format('Algorithm: hybridSort_2 (InsertionSort + QuickSort), CPU time: ~2f ms~n', [T_Hybrid2]),

    % Hybrid Sort (Bubble Sort + Merge Sort)
    statistics(cputime, T12),
    hybridSort(List, bubbleSort, mergeSort, 5, _SortedHybrid3),
    statistics(cputime, T13),
    T_Hybrid3 is (T13 - T12) * 1000,  % Convert to ms
    accumulate_time(hybridSort_3, T_Hybrid3),
    store_time(hybridSort_3, T_Hybrid3),
    format('Algorithm: hybridSort_3 (BubbleSort + MergeSort), CPU time: ~2f ms~n', [T_Hybrid3]),

    % Hybrid Sort (Bubble Sort + Quick Sort)
    statistics(cputime, T14),
    hybridSort(List, bubbleSort, quickSort, 5, _SortedHybrid4),
    statistics(cputime, T15),
    T_Hybrid4 is (T15 - T14) * 1000,  % Convert to ms
    accumulate_time(hybridSort_4, T_Hybrid4),
    store_time(hybridSort_4, T_Hybrid4),
    format('Algorithm: hybridSort_4 (BubbleSort + QuickSort), CPU time: ~2f ms~n', [T_Hybrid4]).


% Process all saved lists recursively
run_sorts_for_all_lists :-
    saved_list(ID, List),
    !,
    run_sorting_algorithms(List),
    retract(saved_list(ID, List)),
    run_sorts_for_all_lists.
run_sorts_for_all_lists :- true.

% Print cumulative and average times for each algorithm
print_cumulative_and_average_times :-
    cumulative_time(Algorithm, CumulativeTime),
    times_list(Algorithm, Times),
    length(Times, Count),
    AverageTime is CumulativeTime / Count,  % Calculate average
    format('Algorithm: ~w, Cumulative CPU time: ~2f ms, Average CPU time: ~2f ms~n', [Algorithm, CumulativeTime, AverageTime]),
    retract(cumulative_time(Algorithm, CumulativeTime)),
    fail.
print_cumulative_and_average_times :- true.

% Print each algorithm list of times
print_times_list :-
    times_list(Algorithm, Times),
    format('Algorithm: ~w, Times: ~w~n', [Algorithm, Times]),
    retract(times_list(Algorithm, Times)),
    fail.
print_times_list :- true.