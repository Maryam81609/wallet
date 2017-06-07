-module(wallet).

%% API
-export([credit/4, debit/4, transfer/5, get_val/3]).

-include_lib("eunit/include/eunit.hrl").

debit(Node, Wallet, Amount, ST) ->
    {ok, Tx1} = rpc:call(Node, antidote, start_transaction, [ST, []]),
    ok = rpc:call(Node, antidote, update_objects, [[{Wallet, decrement, Amount}], Tx1]),
    {ok, [Res1]} = rpc:call(Node, antidote, read_objects, [[Wallet], Tx1]),
    {ok, CT1} = rpc:call(Node, antidote, commit_transaction, [Tx1]),
    {Res1, {Tx1, CT1}}.

credit(Node, Wallet, Amount, ST) ->
    {ok, Tx2} = rpc:call(Node, antidote, start_transaction, [ST, []]),
    ok = rpc:call(Node, antidote, update_objects, [[{Wallet, increment, Amount}], Tx2]),
    {ok, [Res2]} = rpc:call(Node, antidote, read_objects, [[Wallet], Tx2]),
    {ok, CT2} = rpc:call(Node, antidote, commit_transaction, [Tx2]),
    {Res2, {Tx2, CT2}}.

transfer(Node, FromWallet, ToWallet, Amount, ST) ->
    {ok, TxTrnsfr} = rpc:call(Node, antidote, start_transaction, [ST, []]),
    ok = rpc:call(Node, antidote, update_objects, [[{FromWallet, decrement, Amount}, {ToWallet, increment, Amount}], TxTrnsfr]),
    {ok, CT} = rpc:call(Node, antidote, commit_transaction, [TxTrnsfr]),
    CT.

get_val(Node, Wallet, Clock) ->
    {ok, Tx} = rpc:call(Node, antidote, start_transaction, [Clock, []]),
    {ok, [Res]} = rpc:call(Node, antidote, read_objects, [[Wallet], Tx]),
    {ok, _CT1} = rpc:call(Node, antidote, commit_transaction, [Tx]),
    Res.