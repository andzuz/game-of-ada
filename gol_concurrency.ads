with Arrays2D; use Arrays2D;

package Gol_concurrency is

  MAX_SIZE : Integer := 4;
  ITERATIONS : Integer := 3;
  FILE_IN_NAME : String := "matrix.txt";
  FILE_OUT_NAME : String := "matrix_out.txt";
  NUMBER_OF_WORKERS : Integer := 2;

  task Supervisor is
    entry Start_game;
    entry on_data_returned (
               data                  : Array2D;
               start_range           : Integer;
               end_range             : Integer;
               current_worker_number : Integer);
  end Supervisor;

  task type Worker_task is
    entry Get_worker_number_from_supervisor(worker_num : Integer);
    entry Fill_local_board_part(whole_board : Array2D);
    entry process_data;
  end Worker_task;

end Gol_concurrency;
