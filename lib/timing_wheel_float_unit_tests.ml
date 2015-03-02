open Core_kernel.Std

(* module Timing_wheel_float = Timing_wheel_debug.Debug (Time) (Timing_wheel_float) *)

open Timing_wheel_float

include Core_kernel.Timing_wheel_unit_tests.Make (Timing_wheel_float)

let sec = Time.Span.of_sec

TEST_UNIT =
  let t = create_unit () in
  let start = start t in
  List.iter
    [ Time.sub start (sec (2. *. Float.of_int Int.max_value));
      Time.add start (sec (2. *. Float.of_int Int.max_value));
      Time.of_float Float.max_value;
    ]
    ~f:(fun time ->
      assert (does_raise (fun () -> interval_num t time));
      assert (does_raise (fun () -> interval_start t time)));
;;

(* Check that default [level_bits] gives desired range of times. *)
TEST_UNIT =
  let zone = Time.Zone.find_exn "America/New_York" in
  let start =
    Time.of_date_ofday ~zone
      (Date.create_exn ~y:2000 ~m:Month.Jan ~d:1)
      Time.Ofday.start_of_day
  in
  List.iter
    [ Word_size.W32, Time.Span.millisecond, Date.create_exn ~y:2000 ~m:Month.Jan ~d:7;
      Word_size.W64, Time.Span.microsecond, Date.create_exn ~y:2073 ~m:Month.Jan ~d:1;
    ]
    ~f:(fun (word_size, alarm_precision, max_alarm_lower_bound) ->
      let level_bits = Level_bits.default word_size in
      let t = create ~config:(Config.create ~level_bits ~alarm_precision ()) ~start in
      assert (Date.(>=)
                (Time.to_date ~zone (alarm_upper_bound t))
                max_alarm_lower_bound))
;;
