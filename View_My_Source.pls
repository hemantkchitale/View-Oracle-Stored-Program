-- the table which lists users authorized to view only specific objects
create table authorized_view_source
(username  varchar2(30),
object_type varchar2(23),
object_name varchar2(30))
/


-- the PLSQL function that prints the code for an object 
-- only if the user invoking it is authorized (see above table)
create or replace function view_my_source(object_type_in in varchar2, object_name_in in varchar2)
    return clob
    as
    return_clob clob;
    line_out varchar2(4000);
    line_count pls_integer;
    line_no pls_integer;
    verify_count pls_integer;
    return_source  clob;
 
   begin
    select count(*) into verify_count from authorized_view_source
   --  check if any of these three predicates fail
    where username = user
    and object_type = object_type_in
    and object_name = object_name_in;
 
    if verify_count = 0 then
   -- don't tell if the object exists or not
    raise_application_error(-20001,'You are not authorized to view the source code of this object');
    return('FAILURE');
 
    else
 
    select count(*) into line_count from user_source
    where 1=1
    and type = object_type_in
    and name = object_name_in;
 
    return_clob := ' ';
 
    for line_no in 1..line_count
    loop
    return_clob := return_clob || line_out;
    select text into line_out from user_source
    where 1=1
    and type = object_type_in
    and name = object_name_in
    and line = line_no;
    end loop;
    return_clob := return_clob || line_out;
 
    return return_clob;
    end if;
 
   end view_my_source;
/
