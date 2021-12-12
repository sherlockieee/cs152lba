%%KB


%RULES


%KB rules when you have symptoms

answer('You need to contact CIGNA and Barbara Walder') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), \+reside(res), insured('CIGNA').
answer('You need to contact your provider and Barbara Walder') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), \+reside(res), \+insured('CIGNA').


answer('Visit A&O Test Centre') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), reside(res), res_hall(A&O).
answer('Visit a nearby Test Centre') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), reside(res), res_hall('Independent Housing').



%rules when you are to travel

answer('Visit A&O Test Centre') :-
    intention('I want to travel'), result(urgent), res_hall(A&O).
answer('Visit a nearby Test Center') :-
    intention('I want to travel'), result(urgent), res_hall('Independent Housing').
answer('Test privately') :-
    intention('I want to travel'), \+result(urgent), testing(at_home).
answer('Visit A&O Test Centre') :-
    intention('I want to travel'), \+result(urgent), testing(at_testing_center), reside(res), res_hall(A&O).
answer('Visit a nearby Test Centre') :-
    intention('I want to travel'), \+result(urgent), testing(at_testing_center), reside(res), res_hall('Independent Housing').



%rules when you interract with infected person

answer('You should isolate immediately'):-
    intention('I had a close contact with a COVID patient. What should I do?'), exposure(known), \+quarantine_status(qurantine).
answer('You should continue isolation till next testing date'):-
    intention('I had a close contact with a COVID patient. What should I do?'), exposure(known), quarantine_status(quarantine).

answer('Visit A&O Test Centre'):-
    intention('I had a close contact with a COVID patient. What should I do?'), \+exposure(known), \+symptoms(felt).
answer('Visit your provider'):-
    intention('I had a close contact with a COVID patient. What should I do?'), \+exposure(known), symptoms(felt),  \+reside(res), \+insured('CIGNA').
answer('Visit CIGNA'):-
    intention('I had a close contact with a COVID patient. What should I do?'), \+exposure(known), symptoms(felt), \+reside(res), insured('CIGNA').
answer('Visit A&O Test Centre'):-
    intention('I had a close contact with a COVID patient. What should I do?'), \+exposure(known), symptoms(felt), reside(res), res_hall(A&O).
answer('Visit a nearby Test Centre'):-
    intention('I had a close contact with a COVID patient. What should I do?'), \+exposure(known), symptoms(felt), reside(res), res_hall('Independent Housing').


% rules when for a non-urgent check

answer('Visit A&O Test Centre') :-
    intention('I am curious about some casual stuff'), testing(at_testing_center), res_hall(A&O).
answer('Visit A&O Test Centre') :-
    intention('I am curious about some casual stuff'), testing(at_testing_center), res_hall(A&O).
answer('Visit a nearby Test Centre') :-
    intention('I am curious about some casual stuff'), testing(at_testing_center), res_hall('Independent Housing').
answer('Visit a nearby Test Centre') :-
    intention('I am curious about some casual stuff'), testing(at_testing_center), res_hall('Independent Housing').
answer('Test privately') :-
    intention('I am curious about some casual stuff'), testing(at_home).



%FACTS
reside(X) :-
    ask('Do you live in the', X).

res_hall(X) :-
    menuask('Which res hall are you currently in?', X, [A&O, 'Independent Housing']).

testing(X) :-
    menuask('Where do you want to test?', X, [at_home, at_testing_center]).



exposure(X) :-
    ask('What is your source of exposure', X).

result(X) :- ask('Is your need for testing', X).

insured(X) :- ask('Are you medically-insured by', X).


intention(X) :-
    menuask('What is your intention for taking the COVID test?', X, ['I am experiencing COVID symptom(s), I want to know next steps', 'I want to travel', 'I had a close contact with a COVID patient. What should I do?', 'I am curious about some casual stuff']).


quarantine_status(X) :-
    ask('Are you currently in', X).


symptoms(X) :-
    ask('Are your symptoms', X).


% Asking clauses
multivalued(none). % We don't have any multivalued attributes

ask(A, V):-
known(yes, A, V), % succeed if true

!.    % stop looking

ask(A, V):-
known(_, A, V), % fail if false
!, fail.

% If not multivalued, and already known, don't ask again for a different value.
ask(A, V):-
\+multivalued(A),
known(yes, A, V2),
V \== V2,
!.

ask(A, V):-
read_py(A,V,Y), % get the answer
asserta(known(Y, A, V)), % remember it
user_response(Y),
Y == yes.    % succeed or fail


menuask(A, V, _):-
known(yes, A, V), % succeed if true
!.    % stop looking

menuask(A, V, _):-
known(yes, A, V2), % If already known, don't ask again for a different value.
V \== V2,
!,
fail.

menuask(A, V, MenuList) :-
 read_py_menu(A, X, MenuList),
 check_val(X, A, V, MenuList),
 asserta( known(yes, A, X) ),
 X == V.
check_val(X, _, _, MenuList) :-
 member(X, MenuList),
 !.
check_val(X, A, V, MenuList) :-
 system_response(X), system_response(' is not a legal value, try again.\n'),
 menuask(A, V, MenuList).

