with Ada.Text_IO; use Ada.Text_IO;
with Arrays2D;    use Arrays2D;
with Gol_logic;   use Gol_logic;

-- pakiet przechowujacy logike Workerow i Supervisora
package Gol_concurrent is

   -- rozmiar boku planszy
   MAX_SIZE          : Integer := 6;
   -- ilosc workerow, musi byc calkowitym dodatnim dzielnikiem boku planszy
   NUMBER_OF_WORKERS : Integer := 2;
   -- nazwa pliku odczytu macierzy
   IN_FILENAME       : String  := "matrix.txt";
   -- -||- zapisu
   OUT_FILENAME      : String  := "matrix_out.txt";
   -- ilosc iteracji Gry
   ITERATIONS        : Integer := 4;

   task type Worker is
      -- entry sluzy do wypelnienia czastki calej tablicy - kazdy worker ma
      -- lokalna kopie swojej czesci
      entry fill_board_part
        (board                 : Array2D;
         column_from           : Integer;
         column_to             : Integer;
         current_worker_number : Integer);

      -- entry sluzy do uruchomienia mechanizmu przetwarzania czesci tablicy
      entry process_data;
   end Worker;

   task Supervisor is
      -- entry sluzy do poskladania danych. Wywoluja je workery gdy odsylaja
      -- swoje przetworzone czastki. Wtedy do calej tablicy w supervisorze
      -- wpisywane sa te czastki w odpowiednich miejscach
      entry on_data_returned
        (data                  : Array2D;
         start_range           : Integer;
         end_range             : Integer;
         current_worker_number : Integer);
   end Supervisor;

end Gol_concurrent;
