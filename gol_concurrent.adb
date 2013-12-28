with Arrays2D;
use Arrays2D;

package body Gol_concurrent is

  -- WORKER --------------------------------------------------------------------
  task body Worker is
    local_board_copy : Array2D(1..MAX_SIZE, 1..MAX_SIZE / 2);
    column_start_range : Integer;
    column_end_range : Integer;
    worker_number : Integer;
  begin

    loop
      accept fill_board_part(board : Array2D; column_from : Integer; column_to : Integer; current_worker_number : Integer) do
        column_start_range := column_from;
        column_end_range := column_to;
        worker_number := current_worker_number;

        Put_Line(Integer'Image(column_from));

        for I in 1..MAX_SIZE loop
          for J in column_from..column_to loop
            local_board_copy(I, J - (current_worker_number - 1)*MAX_SIZE/NUMBER_OF_WORKERS) := board(I,J);
          end loop;
        end loop;
      end fill_board_part;

    -- processing tablicy
      accept process_data;
      for I in local_board_copy'Range(1) loop
        for J in local_board_copy'Range(2) loop
          local_board_copy(I, J) := local_board_copy(I, J) * 3.0;
        end loop;
      end loop;

      Supervisor.on_data_returned(local_board_copy, column_start_range, column_end_range, worker_number);
    end loop;
  end Worker;

  -- NADZORCA ------------------------------------------------------------------
  task body Supervisor is
    workers : array(1..NUMBER_OF_WORKERS) of Worker;
    current_iteration_board : Array2D(1..MAX_SIZE, 1..MAX_SIZE);
    shared_gameboard : Shared_board;
  begin
    current_iteration_board := Get_array_from_file(IN_FILENAME, MAX_SIZE, MAX_SIZE);
    --to jeszcze poza petla:
    shared_gameboard.Set(current_iteration_board);


    for I in 1..10 loop
    --to juz w petli: wczytuje tablice do obecnej iteracji
      shared_gameboard.Get(current_iteration_board);

      for I in 1..NUMBER_OF_WORKERS loop
        workers(I).fill_board_part(current_iteration_board, MAX_SIZE/NUMBER_OF_WORKERS*(I-1)+1, MAX_SIZE/NUMBER_OF_WORKERS * I, I);
        workers(I).process_data;
      end loop;

    --loop
      for I in 1..NUMBER_OF_WORKERS loop
        accept on_data_returned(data : Array2D; start_range : Integer; end_range : Integer; current_worker_number : Integer) do

          for I in 1..MAX_SIZE loop
            for J in start_range..end_range loop
              current_iteration_board(I, J) := data(I, J - (current_worker_number - 1)*MAX_SIZE/NUMBER_OF_WORKERS);
            end loop;
          end loop;

        end on_data_returned;
      end loop;

      Put_Line("Received all the data");
      Print_array(current_iteration_board, MAX_SIZE, MAX_SIZE);
      shared_gameboard.Set(current_iteration_board);
      --koniec petli

      --write_array_to_file(current_iteration_board, OUT_FILENAME, MAX_SIZE, MAX_SIZE);
    end loop;

  end Supervisor;


  -- OBIEKT WSPOLDZIELONY ------------------------------------------------------
  protected body Shared_board is
    procedure Set(a_board : Array2D) is
    begin
      board := a_board;
    end Set;

    procedure Get(a_board : out Array2D) is
    begin
      a_board := board;
    end Get;
  end Shared_board;

end Gol_concurrent;
