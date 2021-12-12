%%KB


%RULES


%KB rules when you have symptoms

answer('You need to contact CIGNA and Barbara Walder') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), \+reside(city), insured('CIGNA').
answer('You need to contact your provider and Barbara Walder') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), \+reside(city), \+insured('CIGNA').


answer('Get a PCR test at Ostbahnhof Test Center') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), reside(city), res_hall('A&O').
answer('Get a PCR test at a nearby test center') :- intention('I am experiencing COVID symptom(s), I want to know next steps'), reside(city), res_hall('Independent Housing').



%rules when you are to travel

answer('Get free antigen test at A&O Test Centre') :-
    intention('I want to travel'), urgency(urgent), reside(city), res_hall('A&O'), testing('At testing center').
answer('Get free antigen test at nearby Test Center') :-
    intention('I want to travel'), urgency(urgent), reside(city), res_hall('Independent Housing'), testing('At testing center').
answer('Order a test kit on Amazon') :-
    intention('I want to travel'), testing('At home').
answer('Get a PCR test at Ostbahnhof Test Center') :-
    intention('I want to travel'), \+urgency(urgent), testing('At testing center'), reside(city), res_hall('A&O').
answer('Get a PCR test at a nearby test center') :-
    intention('I want to travel'), \+urgency(urgent), testing('At testing center'), reside(city), res_hall('Independent Housing').
answer('Visit your local city website') :-
    intention('I want to travel'), \+reside(city).



%rules when you interract with infected person

answer('You should isolate immediately'):-
    intention('I came in close contact with a COVID patient'), exposure(positive), \+quarantine_status(quarantine).
answer('You should continue isolation until the next testing date'):-
    intention('I came in close contact with a COVID patient'), exposure(positive), quarantine_status(quarantine).

answer('Get free antigen test at A&O Test Centre'):-
    intention('I came in close contact with a COVID patient'), \+exposure(positive), \+symptoms(felt), reside(city), res_hall('A&O').
answer('Get free antigen test at nearby Test Centre'):-
    intention('I came in close contact with a COVID patient'), \+exposure(positive), \+symptoms(felt), reside(city), res_hall('Independent Housing').
answer('You need to contact your provider and Barbara Walder'):-
    intention('I came in close contact with a COVID patient'), \+exposure(positive),  \+reside(city), \+insured('CIGNA').
answer('You need to contact CIGNA and Barbara Walder'):-
    intention('I came in close contact with a COVID patient'), \+exposure(positive), \+reside(city), insured('CIGNA').
answer('Get a PCR test at Ostbahnhof Test Center'):-
    intention('I came in close contact with a COVID patient'), \+exposure(positive), symptoms(felt), reside(city), res_hall('A&O').
answer('Get a PCR test at a nearby test center'):-
    intention('I came in close contact with a COVID patient'), \+exposure(positive), symptoms(felt), reside(city), res_hall('Independent Housing').


% rules for a non-urgent check

answer('Get free antigen test at A&O Test Centre') :-
    intention('It\'s not urgent, I just want to make sure I\'m safe.'), testing('At testing center'), reside(city), res_hall('A&O').
answer('Get free antigen test at nearby Test Centre') :-
    intention('It\'s not urgent, I just want to make sure I\'m safe.'), testing('At testing center'), reside(city), res_hall('Independent Housing').
answer('Visit your local city website') :-
    intention('It\'s not urgent, I just want to make sure I\'m safe.'), testing('At testing center'), \+reside(city).
answer('Order a test kit on Amazon') :-
    intention('It\'s not urgent, I just want to make sure I\'m safe.'), testing('At home').



%FACTS

res_hall(X) :-
    menuask('Which res hall are you currently in?', X, ['A&O', 'Independent Housing']).

testing(X) :-
    menuask('Where do you want to test?', X, ['At home', 'At testing center']).

reside(X) :-
    ask('Are you currently in the', X).

exposure(X) :-
    ask('Is your recent test result', X).

urgency(X) :- ask('Is your need for testing', X).

insured(X) :- ask('Are you medically-insured by', X).

intention(X) :-
    menuask('Why do you want to take the COVID test?', X, ['I am experiencing COVID symptom(s), I want to know next steps', 'I want to travel', 'I came in close contact with a COVID patient', 'It\'s not urgent, I just want to make sure I\'m safe.']).


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
 system_response('That is not a legal value, try again.\n'),
 menuask(A, V, MenuList).

