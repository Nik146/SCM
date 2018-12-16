-module(mordor).
-export([start/0,select_all/1,hello/0,add_user/3]).
-include_lib("user.hrl").
-include_lib("stdlib/include/qlc.hrl").

start() -> spawn(fun loop/0).

select_all(Table_name) -> 
	do(qlc:q([X||X<-mnesia:table(Table_name)])).

do(Q)->
	F=fun()->qlc:e(Q) end,
	{atomic, Val}=mnesia:transaction(F),
	Val.

add_user(Name, Age, V) ->
	Row = #user{name=Name, age=Age, v=V },
	F = fun() ->
		mnesia:write(Row) end,
	mnesia:transaction(F).

hello()->
	"hello".

loop() ->
	receive
		{info} ->
			mnesia:info(),
			loop();
		{add, [{Name, Age, V},From]} ->
			From ! add_user(Name, Age, V),
			loop();
		{select, Table_name,From} ->
			From ! select_all(Table_name),
			loop();
		{hello, From} ->
			From ! { hello(), self()},
			loop()
	end.
