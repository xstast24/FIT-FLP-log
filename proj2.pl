% FLP Logicky projekt - Rubikova kostka
% Filip Stastny (xstast24)
/********
 * MAIN 
 * Load a Rubik's cube and find a sequence of steps needed to solve the cube.
 ********/
start :-
	% Load input and parse it to a structure representing a Rubik's cube
	prompt(_, ''),
	read_input(Input),
	input_to_rubik(Input, Rubik),
	write_rubik(Rubik), % print the initial Rubik's cube
	
	% Find steps leading to a solved Rubik's cube
	MinDepth = 0, % find only solutions longer than this, e.g. minimally 2 rotations
	MaxDepth = 20, % find only solutions shorter than this, e.g. maximally 7 rotations
	solve_rubik_DFS(Rubik, SolutionSteps, MinDepth, MaxDepth),
	
	% Print the final output
	write_rubiks(SolutionSteps),
	halt.


/**********************
 * LOAD INPUT TO CUBE *
 **********************/
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


/*************
 * ROTATIONS
 * Up/Down/Front/Right/Left/Back clockwise and anti-clockwise.
 *************/
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
			[C9, E2, E3, C6, E5, E6, C3, E8, E9],
			[E1, A2, A3, E4, A5, A6, E7, A8, A9],
			Right,
			[C1, C2, F7, C4, C5, F4, C7, C8, F1],
			[D7, D4, D1, D8, D5, D2, D9, D6, D3],
			[A1, F2, F3, A4, F5, F6, A7, F8, F9]
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
			[A1, E2, E3, A4, E5, E6, A7, E8, E9],
			[F1, A2, A3, F4, A5, A6, F7, A8, A9],
			Right,
			[C1, C2, E7, C4, C5, E4, C7, C8, E1],
			[D3, D6, D9, D2, D5, D8, D1, D4, D7],
			[C9, F2, F3, C6, F5, F6, C3, F8, F9]
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
			[B3, B6, B9, E4, E5, E6, E7, E8, E9],
			Front,
			[B1, B2, F9, B4, B5, F8, B7, B8, F7],
			[C7, C4, C1, C8, C5, C2, C9, C6, C3],
			[E3, D2, D3, E2, D5, D6, E1, D8, D9],
			[F1, F2, F3, F4, F5, F6, D1, D4, D7]
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
			[D7, D4, D1, E4, E5, E6, E7, E8, E9],
			Front,
			[B1, B2, E1, B4, B5, E2, B7, B8, E3],
			[C3, C6, C9, C2, C5, C8, C1, C4, C7],
			[F7, D2, D3, F8, D5, D6, F9, D8, D9],
			[F1, F2, F3, F4, F5, F6, B9, B6, B3]
		]).


/*******************
 * SEARCH SOLUTION *
 *******************/
/* Using DFS algorithm, for given Rubik's cube return list of rubik cube states that lead to the solution. Each state is reachable from
the previous one, using a single rotation (Up/Down/Front/Right/Left/Back and their reverse equivalents). Parameters:
@Rubik cube - rubik cube combination to start with
@SolutionSteps - returns a list of steps (cubes) leading to the solution
@MinDepth -  min. length of a possible solution (e.g. 5 if wanted only solutions longer than 5 steps)
@MaxDepth - max. depth for searching - will not search solutions longer than this
*/
solve_rubik_DFS(
		[	
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		SolutionSteps,
		MinDepth,
		MaxDepth)
	:- 
	get_shortest_solution(
		[		
			[E1, E2, E3, E4, E5, E6, E7, E8, E9],
			[A1, A2, A3, A4, A5, A6, A7, A8, A9],
			[B1, B2, B3, B4, B5, B6, B7, B8, B9],
			[C1, C2, C3, C4, C5, C6, C7, C8, C9],
			[D1, D2, D3, D4, D5, D6, D7, D8, D9],
			[F1, F2, F3, F4, F5, F6, F7, F8, F9]
		],
		[	
			[E5, E5, E5, E5, E5, E5, E5, E5, E5],
			[A5, A5, A5, A5, A5, A5, A5, A5, A5],
			[B5, B5, B5, B5, B5, B5, B5, B5, B5],
			[C5, C5, C5, C5, C5, C5, C5, C5, C5],
			[D5, D5, D5, D5, D5, D5, D5, D5, D5],
			[F5, F5, F5, F5, F5, F5, F5, F5, F5]
		],
		SolutionSteps,
		MaxDepth,
		MinDepth).

/*Get shortest number of rotations leading to the result. Parameters:
@Rubik - starting cube combination
@RubikDesired - target cube combination (the one we want to reach)
@SolutionSteps - list of cube combinations leading to the target (each reachable by a single rotation from the previous one)
@MaxDepth - max. depth for searching - will not search solutions longer than this
@CurrentDepth - min. length of a possible solution (e.g. 5 if wanted only solutions longer than 5 steps)
*/
get_shortest_solution(Rubik, RubikDesired, SolutionSteps, MaxDepth, CurrentDepth) :-
		MaxDepth @>= CurrentDepth,
		(
			(get_solution_steps(Rubik, RubikDesired, [], SolutionSteps, CurrentDepth, ReachedDepth),
			ReachedDepth == 0)
			;
			(TmpDepth is CurrentDepth + 1,
			get_shortest_solution(Rubik, RubikDesired, SolutionSteps, MaxDepth, TmpDepth))
		).
	

/*Get list of all steps from input Rubik to solution RubikDesired. Parameters:
@Rubik - init with starting cube combination
@RubikDesired - init with target cube combination (the one we want to reach)
@PreviousSteps - init with [] (empty list), temporary list of combinations
@SolutionSteps - list of cube combinations leading to the target (each reachable by a single rotation from the previous one)
@Depth - init with preferred depth for searching (will not search solutions longer than this)
@ReachedDepth - is 0 if solution found, is 1 if solution not found
% Note: Searches always the solution with closest length to given Depth. E.g. if solution by 4 steps exists,
% but Depth is 20, this will find a solution near to 20 steps long (but not longer than 20).
*/
% found solution, set ReachedDepth to 0 (false), so the solution is accepted
get_solution_steps(Rubik, Rubik, SolutionSteps, SolutionSteps, _, ReachedDepth) :- ReachedDepth is 0, !.
% iterations reached max depth and no solution found, set ReachedDepth to 1 (true), so the solution is not used
get_solution_steps(_, _, _, _, 0, ReachedDepth) :- ReachedDepth is 1.
% try all rotations until got a solution
get_solution_steps(Rubik, RubikDesired, PreviousSteps, SolutionSteps, Depth, ReachedDepth) :-
	TmpDepth is Depth - 1,
	TmpDepth @>= 0,
	% test all rotations, any of them can lead to a result
	(
		(rotU_up(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotU_up_rev(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotD_down(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotD_down_rev(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotF_front(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotF_front_rev(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotR_right(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotR_right_rev(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotL_left(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotL_left_rev(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotB_back(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
		;
		(rotB_back_rev(Rubik, TmpRubik),
		append(PreviousSteps, [TmpRubik], TmpSteps),
		get_solution_steps(TmpRubik, RubikDesired, TmpSteps, SolutionSteps, TmpDepth, ReachedDepth),
		ReachedDepth == 0)
	).


/****************
 * PRINT OUTPUT *
 ****************/
% print list of rubik cubes to output, separated by an empty line
write_rubiks([]).
write_rubiks([Cube | Cubes]) :-
	nl, nl, write_rubik(Cube), write_rubiks(Cubes).

% print rubik cube to output
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
	writef("%w%w%w\n%w%w%w\n%w%w%w", [F1, F2, F3, F4, F5, F6, F7, F8, F9]).

% check if list is not empty - true if non-empty, false if empty
non_empty([_|_]) :- true.
