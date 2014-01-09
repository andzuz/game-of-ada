with Ada.Text_IO;    use Ada.Text_IO;
with Gol_concurrency; use Gol_concurrency;
with Arrays2D; use Arrays2D;

procedure Main is
   arr : Array2D(1..3, 1..3);
begin
   Supervisor.Start_game;
end Main;
