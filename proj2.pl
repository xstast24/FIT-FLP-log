/************
 * LOAD INPUT
 ************/
%Reads line from stdin, terminates on LF or EOF.
read_line(L,C) :-
	get_char(C),
	(isEOFEOL(C), L = [], !;
		read_line(LL,_),% atom_codes(C,[Cd]),
		[C|LL] = L).

%Tests if character is EOF or LF.
isEOFEOL(C) :-
	C == end_of_file;
	(char_code(C,Code), Code==10).

read_lines(Ls) :-
	read_line(L,C),
	( C == end_of_file, Ls = [] ;
	  read_lines(LLs), Ls = [L|LLs]
	).

% rozdeli radek na podseznamy
split_line([],[[]]) :- !.
split_line([' '|T], [[]|S1]) :- !, split_line(T,S1).
split_line([32|T], [[]|S1]) :- !, split_line(T,S1).    % aby to fungovalo i s retezcem na miste seznamu
split_line([H|T], [[H|G]|S1]) :- split_line(T,[G|S1]). % G je prvni seznam ze seznamu seznamu G|S1

% vstupem je seznam radku (kazdy radek je seznam znaku)
split_lines([],[]).
split_lines([L|Ls],[H|T]) :- split_lines(Ls,T), split_line(L,H).

read_input(Input) :- read_lines(LL), split_lines(LL, Input).

% tri radky vstupu (kazdy ma 3 symboly [x,x,x]) slouci do seznamu odpovidajicimu jedne strane
get_input_side(Row1, Row2, Row3, Side) :- append(Row1, Row2, Row1_2), append(Row1_2, Row3, Side).
% tri radky pro 4 strany (format [[1,1,1][2,2,2][3,3,3][4,4,4]]) slouci do seznamu 4 stran
get_input_sides([], [], [], Sides, Sides).
get_input_sides([H1|Row1], [H2|Row2], [H3|Row3], TmpSides, Sides) :-
	get_input_side(H1, H2, H3, Side),
	append(TmpSides, [Side], Tmp),
	get_input_sides(Row1, Row2, Row3, Tmp, Sides).

% load input to rubik cube, each side is list of its fields, sorted 1-9 from left to right (then from top to bottom)
% format [E_side5, A_side1, B_side2, C_side3, D_side4, F_side6]
% E = top, A = front, B = right, C = back, D = left, F = bottom
input_to_rubik([[L1], [L2], [L3], L4, L5, L6, [L7], [L8], [L9]], Rubik) :- 
	get_input_side(L1, L2, L3, Side5), get_input_sides(L4, L5, L6, [], Sides1to4), get_input_side(L7, L8, L9, Side6),
	append([Side5], Sides1to4, Sides1to5), append(Sides1to5, [Side6], Rubik).

/***********
 * ROTATIONS
 ***********/
% rotate top clockwise (looking on this side)
rotU_up(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			Bottom
		],
		[
			[E7, E4, E1, E8, E5, E2, E9, E6, E3],
			[B1, B2, B3, A4, A5, A6, A7, A8, A9],
			[C1, C2, C3, B4, B5, B6, B7, B8, B9],
			[D1, D2, D3, C4, C5, C6, C7, C8, C9],
			[A1, A2, A3, D4, D5, D6, D7, D8, D9],
			Bottom
		]).

% rotate top anti-clockwise (looking on this side)
rotU_up_rev(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			Bottom
		],
		[
			[E3, E6, E9, E2, E5, E8, E1, E4, E7],
			[D1, D2, D3, A4, A5, A6, A7, A8, A9],
			[A1, A2, A3, B4, B5, B6, B7, B8, B9],
			[B1, B2, B3, C4, C5, C6, C7, C8, C9],
			[C1, C2, C3, D4, D5, D6, D7, D8, D9],
			Bottom
		]).

% rotate bottom clockwise (looking on this side)
rotD_down(
		[
			Top,
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			Top,
			[D1, D2, D3, A4, A5, A6, A7, A8, A9],
			[A1, A2, A3, B4, B5, B6, B7, B8, B9],
			[B1, B2, B3, C4, C5, C6, C7, C8, C9],
			[C1, C2, C3, D4, D5, D6, D7, D8, D9],
			[F7, F4, F1, F8, F5, F2, F9, F6, F3]
		]).

% rotate bottom anti-clockwise (looking on this side)
rotD_down_rev(
		[
			Top,
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			Top,
			[A1, A2, A3, A4, A5, A6, B7, B8, B9],
			[B1, B2, B3, B4, B5, B6, C7, C8, C9],
			[C1, C2, C3, C4, C5, C6, D7, D8, D9],
			[D1, D2, D3, D4, D5, D6, A7, A8, A9],
			[F3, F6, F9, F2, F5, F8, F1, F4, F7]
		]).

% rotate front clockwise (looking on this side)
rotF_front(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			Back,
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, E3, E4, E5, E6, D3, D6, D9],
			[A7, A4, A1, A8, A5, A2, A9, A6, A3],
			[E7, B2, B3, E8, B5, B6, E9, B8, B9],
			Back,
			[D1, D2, F1, D4, D5, F2, D7, D8, F3],
			[B7, B4, B1, F4, F5, F6, F7, F8, F9]
		]).

% rotate front anti-clockwise (looking on this side)
rotF_front_rev(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			Back,
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, E3, E4, E5, E6, B1, B4, B7],
			[A3, A6, A9, A2, A5, A8, A1, A4, A7],
			[F3, B2, B3, F2, B5, B6, F1, B8, B9],
			Back,
			[D1, D2, E9, D4, D5, E8, D7, D8, E7],
			[D3, D6, D9, F4, F5, F6, F7, F8, F9]
		]).
		
% rotate right clockwise (looking on this side)
rotR_right(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			Left,
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, A3, E4, E5, A6, E7, E8, A9],
			[A1, A2, F3, A4, A5, F6, A7, A8, F9],
			[B7, B4, B1, B8, B5, B2, B9, B6, B3],
			[E9, C2, C3, E6, C5, C6, E3, C8, C9],
			Left,
			[F1, F2, C7, F4, F5, C4, F7, F8, C1]
		]).

% rotate right anti-clockwise (looking on this side)
rotR_right_rev(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			Left,
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, C7, E4, E5, C4, E7, E8, C1],
			[A1, A2, E3, A4, A5, E6, A7, A8, E9],
			[B3, B6, B9, B2, B5, B8, B1, B4, B7],
			[F9, C2, C3, F6, C5, C6, F3, C8, C9],
			Left,
			[F1, F2, A3, F4, F5, A6, F7, F8, A9]
		]).
% rotate left clockwise (looking on this side)
rotL_left(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			Right,
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			Right,
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D7, D4, D1, D8, D5, D2, D9, D6, D3],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		]).

% rotate left anti-clockwise (looking on this side)
rotL_left_rev(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			Right,
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			Right,
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D7, D4, D1, D8, D5, D2, D9, D6, D3],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		]).

% rotate back clockwise (looking on this side)
rotB_back(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			Front,
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			Front,
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C7, C4, C1, C8, C5, C2, C9, C6, C3],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		]).

% rotate back anti-clockwise (looking on this side)
rotB_back_rev(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			Front,
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			Front,
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C7, C4, C1, C8, C5, C2, C9, C6, C3],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		]).
	
/******
 * MAIN
 ******/
start :-
	prompt(_, ''),
	read_input(Input),
	input_to_rubik(Input, Rubik),
	write_rubik(Rubik),
	halt.

/**************
 * PRINT OUTPUT
 **************/
write_rubik(
		[
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		]) :-
	writef("%w%w%w\n%w%w%w\n%w%w%w\n", [E1, E2, E3, E4, E5, E6, E7, E8, E9]),
	writef("%w%w%w %w%w%w %w%w%w %w%w%w\n", [A1, A2, A3, B1, B2, B3, C1, C2, C3, D1, D2, D3]),
	writef("%w%w%w %w%w%w %w%w%w %w%w%w\n", [A4, A5, A6, B4, B5, B6, C4, C5, C6, D4, D5, D6]),
	writef("%w%w%w %w%w%w %w%w%w %w%w%w\n", [A7, A8, A9, B7, B8, B9, C7, C8, C9, D7, D8, D9]),
	writef("%w%w%w\n%w%w%w\n%w%w%w\n", [F1, F2, F3, F4, F5, F6, F7, F8, F9]).


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
/* nacte zadany pocet radku */
read_lines2([],0).
read_lines2(Ls,N) :-
	N > 0,
	read_line(L,_),
	N1 is N-1,
	read_lines2(LLs, N1),
	Ls = [L|LLs].

/* vypise seznam radku (kazdy radek samostatne) */
write_lines2([]).
write_lines2([H|T]) :- writeln(H), write_lines2(T). %(writeln je "knihovni funkce")

/* rozdeli radek na podseznamy -- pracuje od konce radku */
%zalozit prvni (tzn. posledni) seznam:
split_line2([],[[]]) :- !.
%pridat novy seznam:
split_line2([' '|T], [[]|S1]) :- !, split_line2(T,S1).
%pridat novy seznam, uchovat oddelujici znak:
split_line2([H|T], [[],[H]|S1]) :- (H=','; H=')'; H='('), !, split_line2(T,S1).
%pridat znak do existujiciho seznamu:
split_line2([H|T], [[H|G]|S1]) :- split_line2(T,[G|S1]).

/* pro vsechny radky vstupu udela split_line2 */
% vstupem je seznam radku (kazdy radek je seznam znaku)
split_lines2([],[]).
split_lines2([L|Ls],[H|T]) :- split_lines2(Ls,T), split_line2(L,H).

/* nacte N radku vstupu, zpracuje, vypise */
start2(N) :-
		prompt(_, ''),
		read_lines2(LL, N),
		split_lines2(LL,S),
		write_lines2(S).


% prevede retezec na seznam atomu
% pr.: string("12.35",S). S = ['1', '2', '.', '3', '5'].
retezec([],[]).
retezec([H|T],[C|CT]) :- atom_codes(C,[H]), retezec(T,CT).

% prevede seznam cislic na cislo
% pr.: cislo([1,2,'.',3,5],X). X = 12.35
cislo(N,X) :- cislo(N,0,X).
cislo([],F,F).
cislo(['.'|T],F,X) :- !, cislo(T,F,X,10).
cislo([H|T],F,X) :- FT is 10*F+H, cislo(T,FT,X).
cislo([],F,F,_).
cislo([H|T],F,X,P) :- FT is F+H/P, PT is P*10, cislo(T,FT,X,PT).

% existuje knihovni predikat number_chars(?Number, ?CharList)
% pr.: number_chars(12.35, ['1', '2', '.', '3', '5']).
