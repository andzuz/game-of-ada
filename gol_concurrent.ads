with Ada.Text_IO;
use Ada.Text_IO;
with Arrays2D;
use Arrays2D;

package Gol_concurrent is

  MAX_SIZE : Integer := 4;
  NUMBER_OF_WORKERS : Integer := 2;
  IN_FILENAME : String := "matrix.txt";
  OUT_FILENAME : String := "matrix_out.txt";

  task type Worker is
    entry fill_board_part(board : Array2D; column_from : Integer; column_to : Integer; current_worker_number : Integer);
    entry process_data;
  end Worker;

  task Supervisor is
    entry on_data_returned(data : Array2D; start_range : Integer; end_range : Integer; current_worker_number : Integer);
  end Supervisor;

end Gol_concurrent;
