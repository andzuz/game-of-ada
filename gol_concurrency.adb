with Arrays2D; use Arrays2D;
with Ada.Text_IO; use Ada.Text_IO;
with Gol_utils; use Gol_utils;

-- logika Nadzorcy i Workerow
package body Gol_concurrency is

  -- Nadzorca
  task body Supervisor is
    tmp_board : Array2D(1..MAX_SIZE, 1..MAX_SIZE);
    supervisor_board : Array2D(1..MAX_SIZE + 2, 1..MAX_SIZE + 2);
    workers : array(1..NUMBER_OF_WORKERS) of Worker_task;
  begin
    accept Start_game;

    Put_Line("Nadzorca: Odebrano sygnal startu");

    -- wczytanie planszy i wypelnienie brzegow zerami
    tmp_board := Get_GOL_board_from_file(FILE_IN_NAME, MAX_SIZE);
    MAX_SIZE := MAX_SIZE + 2;
    Fill_edges_with_zeros(tmp_board, supervisor_board, MAX_SIZE);

    Put_Line("Nadzorca: Wczytano tablice z pliku i wypelniono brzegi zerami:");
    Print_array(supervisor_board,MAX_SIZE,MAX_SIZE);

    -- nadanie workerom numerow i wypelnienie ich czesci planszy lokalnych
    for I in 1..NUMBER_OF_WORKERS loop
      workers(I).Get_worker_number_from_supervisor(I);
      workers(I).Fill_local_board_part(supervisor_board);
    end loop;

    -- glowna petla gry
    for J in 1..ITERATIONS loop
       Put_Line("Nadzorca: START NOWEJ ITERACJI");

       -- niech kazdy worker przetwarza swoja czesc
       for I in 1 .. NUMBER_OF_WORKERS loop
         workers(I).process_data;
       end loop;

       for I in 1 .. NUMBER_OF_WORKERS loop

         -- skladanie przetworzonej tablicy
         accept on_data_returned (
               data                  : Array2D;
               start_range           : Integer;
               end_range             : Integer;
               current_worker_number : Integer) do

           for I in 1..MAX_SIZE loop
             for J in start_range..end_range loop
               supervisor_board(I,J) := data( I, J-(MAX_SIZE/NUMBER_OF_WORKERS-1)*(current_worker_number-1) );
             end loop;
           end loop;

         end on_data_returned;
       end loop;

       Put_Line("Nadzorca: Odebrano od workerow i scalono przetworzona tablice:");
       Print_array(supervisor_board, MAX_SIZE, MAX_SIZE);
    end loop;

    Put_Line("Nadzorca: Zapisywanie tablicy do pliku..");

    -- zapisywanie do pliku
    Write_GOL_board_to_file(supervisor_board, FILE_OUT_NAME, MAX_SIZE);
  end Supervisor;


  -- Worker --------------------------------------------------------------------
  task body Worker_task is
    worker_id : Integer;
    local_board_copy : Array2D(1..MAX_SIZE + 2, 1..((MAX_SIZE+2)/NUMBER_OF_WORKERS)+1);
  begin
    -- nadaja workerowi unikalny numer
    accept Get_worker_number_from_supervisor(worker_num : Integer) do
      worker_id := worker_num;
    end Get_worker_number_from_supervisor;

    -- wypelniaja jego lokalna kopie tablicy
    accept Fill_local_board_part(whole_board : Array2D) do
    -- wszystkie zakresy sa uzmiennione - wole wyliczac je na podstawie innych
    -- parametrow programu niz wpisywac 'na sztywno'
    declare
      var_start_range : Integer := (MAX_SIZE / NUMBER_OF_WORKERS * (worker_id-1)) + worker_id mod 2;
      var_end_range : Integer := (MAX_SIZE/NUMBER_OF_WORKERS * worker_id) + worker_id mod 2;
      var_decrement : Integer := (MAX_SIZE/NUMBER_OF_WORKERS-1)*(worker_id-1);
    begin
      for I in 1..MAX_SIZE loop
        for J in var_start_range..var_end_range loop
          local_board_copy( I, J-var_decrement ) := whole_board(I,J);
        end loop;
      end loop;
    end;end Fill_local_board_part;

    Put_Line("   Worker " & Integer'Image(worker_id) & ": Wypelniono lokalna czesc planszy");

    for I in 1..ITERATIONS loop

       -- nastepuje przetwarzanie danych
       accept process_data;
       -- wszystkie zakresy sa uzmiennione - wole wyliczac je na podstawie innych
       -- parametrow programu niz wpisywac 'na sztywno'
       declare
         var_start_range : Integer := (MAX_SIZE / NUMBER_OF_WORKERS * (worker_id-1)) + worker_id mod 2 + 2*(worker_id-1);
         var_end_range : Integer := (MAX_SIZE/NUMBER_OF_WORKERS * worker_id) + worker_id mod 2;
       begin
         Apply_gol_logic_to_board(local_board_copy, MAX_SIZE, (MAX_SIZE)/NUMBER_OF_WORKERS+1);

         Put_Line("   Worker " & Integer'Image(worker_id) & ": Przetworzono lokalna czesc planszy");
         Put_Line("   Worker " & Integer'Image(worker_id) & ": Trwa wysylanie przetworzonej czesci do nadzorcy..");

         -- oraz odsylanie przetworzonej porcji tablicy do nadzorcy
         Supervisor.on_data_returned(local_board_copy, var_start_range, var_end_range, worker_id);
       end;
    end loop;

  end Worker_task;

end Gol_concurrency;
