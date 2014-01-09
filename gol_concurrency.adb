with Arrays2D; use Arrays2D;
with Ada.Text_IO; use Ada.Text_IO;
with Gol_utils; use Gol_utils;

package body Gol_concurrency is

  task body Supervisor is
    tmp_board : Array2D(1..MAX_SIZE, 1..MAX_SIZE);
    supervisor_board : Array2D(1..MAX_SIZE + 2, 1..MAX_SIZE + 2);
    workers : array(1..NUMBER_OF_WORKERS) of Worker_task;
  begin
    accept Start_game;

    Put_Line("Nadzorca: Odebrano sygnal startu");

    tmp_board := Get_GOL_board_from_file(FILE_IN_NAME, MAX_SIZE);
    MAX_SIZE := MAX_SIZE + 2;
    Fill_edges_with_zeros(tmp_board, supervisor_board, MAX_SIZE);

    Put_Line("Nadzorca: Wczytano tablice z pliku i wypelniono brzegi zerami:");
    Print_array(supervisor_board,MAX_SIZE,MAX_SIZE);

    for I in 1..NUMBER_OF_WORKERS loop
      workers(I).Get_worker_number_from_supervisor(I);
      workers(I).Fill_local_board_part(supervisor_board);
    end loop;

    for J in 1..ITERATIONS loop
       Put_Line("Nadzorca: START NOWEJ ITERACJI");

       for I in 1 .. NUMBER_OF_WORKERS loop
         workers(I).process_data;
       end loop;

       for I in 1 .. NUMBER_OF_WORKERS loop
         --workers(I).process_data;

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
    Write_GOL_board_to_file(supervisor_board, FILE_OUT_NAME, MAX_SIZE);
  end Supervisor;

  task body Worker_task is
    worker_id : Integer;
    local_board_copy : Array2D(1..MAX_SIZE + 2, 1..((MAX_SIZE+2)/NUMBER_OF_WORKERS)+1);
  begin
    accept Get_worker_number_from_supervisor(worker_num : Integer) do
      worker_id := worker_num;
    end Get_worker_number_from_supervisor;

    accept Fill_local_board_part(whole_board : Array2D) do
      if worker_id = 1 then
        for I in 1..MAX_SIZE loop
          for J in 1 + (MAX_SIZE/NUMBER_OF_WORKERS * (worker_id - 1)).. 1+(MAX_SIZE/NUMBER_OF_WORKERS * worker_id) loop
            local_board_copy(I, J) := whole_board(I,J);
          end loop;
        end loop;
      else
        for I in 1..MAX_SIZE loop
          for J in MAX_SIZE/NUMBER_OF_WORKERS*(worker_id-1)..MAX_SIZE/NUMBER_OF_WORKERS*worker_id loop
            local_board_copy( I, J-(MAX_SIZE/NUMBER_OF_WORKERS-1) ) := whole_board(I,J);
          end loop;
        end loop;
        null;
      end if;
    end Fill_local_board_part;
    Put_Line("   Worker " & Integer'Image(worker_id) & ": Wypelniono lokalna czesc planszy");

    for I in 1..ITERATIONS loop
       accept process_data;
       Apply_gol_logic_to_board(local_board_copy, MAX_SIZE, (MAX_SIZE)/NUMBER_OF_WORKERS+1);
       Put_Line("   Worker " & Integer'Image(worker_id) & ": Przetworzono lokalna czesc planszy");

       Put_Line("   Worker " & Integer'Image(worker_id) & ": Trwa wysylanie przetworzonej czesci do nadzorcy..");
       if worker_id = 1 then
         Supervisor.on_data_returned(local_board_copy, 1, 1+(MAX_SIZE/NUMBER_OF_WORKERS*(worker_id)), worker_id);
       else
         Supervisor.on_data_returned(local_board_copy, 2+(MAX_SIZE/NUMBER_OF_WORKERS*(worker_id-1)), MAX_SIZE, worker_id);
       end if;
    end loop;

  end Worker_task;

end Gol_concurrency;
