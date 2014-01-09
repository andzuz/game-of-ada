with Ada.Text_IO;    use Ada.Text_IO;
with Gol_concurrency; use Gol_concurrency;

procedure Main is
begin
   Supervisor.Start_game;
end Main;
