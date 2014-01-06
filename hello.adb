with Ada.Text_IO;    use Ada.Text_IO;
with Arrays2D;
with TaskTest;
with Gol_concurrent; use Gol_concurrent;
with gnat.traceback.symbolic; use gnat.traceback.symbolic;
with ada.exceptions; use ada.exceptions;

-- GRA W ZYCIE
-- Autor : Andrzej Zuzak
-- schemat dzialania:
-- 2 workerow, 1 nadzorca
-- nadzorca wczytuje tablice z pliku
-- przechowuje on ja i daje kazdemu z workerow
-- uruchamia processing u kazdego z workerow
-- kazdy z workerow wczytuje swoja czesc tablicy
-- przechowuje on swoja czesc tablicy, jak i cala tablice
-- cala w zwiazku z tym, by mogl znac kolumny brzegowe, ktore nie naleza do jego czesci
-- jest to wedlug mnie szybsze niz wymuszanie synchronizacji w protected object
-- nastepnie workery wypelniaja tablice w supervisorze swoimi czesciami po processingu
-- supervisor widzac ze ma wypelniona tablice zapisuje ja do pliku
-- petla sie powtarza
-- zasaniczo workerow moze byc prawie dowolnie duzo -
-- 'prawie', bo liczba workerow musi byc calkowitym dzielnikiem rozmiaru tablicy

procedure Main is
begin
   null;
exception
    when e: others =>
        put_line("raised exception " & exception_name(e));
        put_line("traceback: ");
        put_line( symbolic_traceback(e));
end Main;
