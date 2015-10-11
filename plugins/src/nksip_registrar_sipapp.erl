%% -------------------------------------------------------------------
%%
%% Copyright (c) 2013 Carlos Gonzalez Florido.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%% @doc NkSIP Registrar Plugin User Callbacks
-module(nksip_registrar_sipapp).
-author('Carlos Gonzalez <carlosj.gf@gmail.com>').

-export([sip_registrar_store/2]).


% @doc Called when a operation database must be done on the registrar database.
%% This default implementation uses the built-in memory database.
-spec sip_registrar_store(StoreOp, SrvId) ->
    [RegContact] | ok | not_found when 
        StoreOp :: {get, AOR} | {put, AOR, [RegContact], TTL} | 
                   {del, AOR} | del_all,
        SrvId :: nksip:app_id(),
        AOR :: nksip:aor(),
        RegContact :: nksip_registrar:reg_contact(),
        TTL :: integer().

sip_registrar_store(Op, SrvId) ->
    case Op of
        {get, AOR} ->
            nklib_store:get({nksip_registrar, SrvId, AOR}, []);
        {put, AOR, Contacts, TTL} -> 
            nklib_store:put({nksip_registrar, SrvId, AOR}, Contacts, [{ttl, TTL}]);
        {del, AOR} ->
            nklib_store:del({nksip_registrar, SrvId, AOR});
        del_all ->
            FoldFun = fun(Key, _Value, Acc) ->
                case Key of
                    {nksip_registrar, SrvId, AOR} -> 
                        nklib_store:del({nksip_registrar, SrvId, AOR});
                    _ -> 
                        Acc
                end
            end,
            nklib_store:fold(FoldFun, none)
    end.



