(** * 6.887 Formal Reasoning About Programs, Spring 2017 - Pset 10 *)

Require Import Frap.

(* Authors: 
 * Joonwon Choi (joonwonc@csail.mit.edu)
 * Adam Chlipala (adamc@csail.mit.edu) 
 *)

Set Implicit Arguments.

(** * Hoare Logic with Input/Output Traces *)

(* If you are already satisfied enough with Hoare logic you've learned in the
 * lecture, it's too early -- there are several Hoare-logic variants for more
 * complicated verification for more complex languages. In this problem set, we
 * will implement one of its variants, a Hoare logic that deals with
 * input/output traces.
 *
 * As we learned in compiler verification, behaviors of a program can be
 * defined as sequences of external communications with the outside world. Hoare
 * logic certainly can be used for proving properties about program behaviors.
 * Besides valuation and heap, we will need to keep track of traces of a program
 * to ensure the properties we want, sometimes by proving invariants in the
 * middle of the program.
 *
 * The problem set consists of 4 tasks; basically we ask you to formally prove 
 * the correctness of some programs using Hoare logic:
 * 1) To design a big-step operational semantics of the given language.
 * 2) To define a Hoare logic for the language, and to prove the consistency
 *    between the semantics and the logic.
 * 3) To verify three example programs we provide, using Hoare logic.
 * 4) To design your own interesting program and to verify it.
 *)

(** * Language syntax *)

(* There is nothing special with the definitions of [exp] and [bexp]; they are
 * exactly same as we've seen in the lecture.
 *)
Inductive exp :=
| Const (n : nat)
| Var (x : string)
| Read (e1 : exp)
| Plus (e1 e2 : exp)
| Minus (e1 e2 : exp)
| Mult (e1 e2 : exp).

Inductive bexp :=
| Equal (e1 e2 : exp)
| Less (e1 e2 : exp).

(* [heap] and [valuation] are also as usual. *)
Definition heap := fmap nat nat.
Definition valuation := fmap var nat.

(* Besides [heap] and [valuation], we have one more component to verify using 
 * Hoare logic, called [io]. We keep track of inputs and outputs of a certain
 * program, regarding them as meaningful communication with the outside world.
 * When a program is executed, it generates [trace], which is a list of [io]s,
 * meaning inputs and outputs occurred during the execution. Traces are also
 * called behaviors of a program.
 *)
Inductive io := In (v : nat) | Out (v : nat).
Definition trace := list io.

(* We now have two types of assertions: [iassertion] is used only for asserting 
 * properties of internal states. [eassertion] can be used for asserting 
 * properties of [trace]s as well as internal states.
 *)
Definition iassertion := heap -> valuation -> Prop.
Definition assertion := trace -> heap -> valuation -> Prop.

(* [cmd] has more constructors than what we've seen, called [Input] and
 * [Output]. As expected, semantically they generates [io]s, eventually forming
 * a [trace] of a program.
 *)
Inductive cmd :=
| Skip
| Assign (x : var) (e : exp)
| Write (e1 e2 : exp)
| Seq (c1 c2 : cmd)
| If_ (be : bexp) (then_ else_ : cmd)
| While_ (inv : assertion) (be : bexp) (body : cmd)

| Assert (a : iassertion) (* Note that we are using [iassertion], not 
                           * [assertion] for [Assert]. While [valuation] and
                           * [heap] are internal states directly manipulated by
                           * a program, [trace] is rather an abstract notion for
                           * defining a behavior of a program.
                           *)

| Input (x : var) (* [Input] takes an input from the external world and assigns
                   * the value to the local variable [x].
                   *)
| Output (e : exp). (* [Output] prints an evaluated value from [e]. *)

(** We here provide fancy notations for our language. *)

Coercion Const : nat >-> exp.
Coercion Var : string >-> exp.
Notation "*[ e ]" := (Read e) : cmd_scope.
Infix "+" := Plus : cmd_scope.
Infix "-" := Minus : cmd_scope.
Infix "*" := Mult : cmd_scope.
Infix "=" := Equal : cmd_scope.
Infix "<" := Less : cmd_scope.
Definition set (dst src : exp) : cmd :=
  match dst with
  | Read dst' => Write dst' src
  | Var dst' => Assign dst' src
  | _ => Assign "Bad LHS" 0
  end.
Infix "<-" := set (no associativity, at level 70) : cmd_scope.
Infix ";;" := Seq (right associativity, at level 75) : cmd_scope.
Notation "'when' b 'then' then_ 'else' else_ 'done'" :=
  (If_ b then_ else_) (at level 75, b at level 0) : cmd_scope.
Notation "{{ I }} 'while' b 'loop' body 'done'" := (While_ I b body) (at level 75) : cmd_scope.
Notation "'assert' {{ I }}" := (Assert I) (at level 75) : cmd_scope.
Notation "x '<--' 'input'" := (Input x) (at level 75) : cmd_scope.
Notation "'output' e" := (Output e) (at level 75) : cmd_scope.
Delimit Scope cmd_scope with cmd.

Infix "+" := plus : reset_scope.
Infix "-" := minus : reset_scope.
Infix "*" := mult : reset_scope.
Infix "=" := eq : reset_scope.
Infix "<" := lt : reset_scope.
Delimit Scope reset_scope with reset.
Open Scope reset_scope.


(** * Task 1: A big-step operational semantics for commands *)

(* Your first task is to define a big-step operational semantics for commands.
 * While it should be very similar to what we've seen in the lecture, it should
 * also represent something about [io]s (or [trace]). Make sure the semantics
 * presents correct relations between [Input]/[Output] and [trace]. Semantics
 * for [Assert] also should be related to [trace].
 *
 * We provide the signature of the semantics below. Remove the [Axiom] and
 * define the semantics with the same name (exec) and the type.
 *)

(** * Define your semantics here! *)

Axiom exec : trace -> heap -> valuation -> cmd ->
             trace -> heap -> valuation -> Prop.


(** * Task 2 : Hoare logic *)

(* We also ask you to write Hoare logic for our language. The logic should
 * have a form of { P } c { Q }, where "P" and "Q" have a type of [assertion]
 * and "c" has a type of [cmd]. It should be also very similar to the Hoare
 * logic we've defined in the lecture.
 *)

(* Certainly the logic should be consistent to the semantics you defined, so we
 * also ask you to prove a relation between the Hoare logic and the semantics.
 * You will need this consistency to prove the correctness of example programs
 * we will provide soon. 
 *)

(** Task 2-1: Define your Hoare logic here! *)

Axiom hoare_triple : assertion -> cmd -> assertion -> Prop.

Notation "[[ tr , h , v ]] ~> e" := (fun tr h v => e%reset) (at level 90).
Notation "{{ P }} c {{ Q }}" :=
  (hoare_triple P c%cmd Q) (at level 90, c at next level).

(** Task 2-2: Prove the consistency theorem. *)

Theorem hoare_triple_big_step :
  forall pre c post,
    hoare_triple pre c post ->
    forall tr h v tr' h' v',
      exec tr h v c tr' h' v' ->
      pre tr h v -> post tr' h' v'.
Proof.
Admitted.


(** * Task 3: Verification of some example programs *)

(* Now it's time to verify programs using the Hoare logic you've just defined!
 * We provide three example programs and three corresponding correctness 
 * theorems. You are required to prove the theorems stated below using Hoare
 * logic.
 *)

(** Task 3-1: adding two inputs -- prove [add_two_inputs_ok] *)

Example add_two_inputs :=
  ("x" <-- input;;
   "y" <-- input;;
   output ("x" + "y"))%cmd.

Theorem add_two_inputs_ok:
  forall tr h v tr' h' v',
    exec tr h v add_two_inputs tr' h' v' ->
    tr = nil ->
    exists vx vy, tr' = [Out (vx + vy); In vy; In vx].
Proof.
Admitted.

(** Task 3-2: finding the maximum of three numbers -- prove [max3_ok] *)

Example max3 :=
  ("x" <-- input;;
   "y" <-- input;;
   "z" <-- input;;
   when "x" < "y" then
     when "y" < "z" then
       output "z"
     else 
       output "y"
     done
   else
     when "x" < "z" then
       output "z"
     else
       output "x"
     done
   done)%cmd.

Definition max3_fun (x y z: nat) :=
  if lt_dec x y then
    if lt_dec y z then z else y
  else
    if lt_dec x z then z else x.

Inductive max3_spec : trace -> Prop :=
| M3s: forall x y z tr,
    tr = [Out (max3_fun x y z); In z; In y; In x] ->
    max3_spec tr.

Theorem max3_ok:
  forall tr h v tr' h' v',
    exec tr h v max3 tr' h' v' ->
    tr = nil ->
    max3_spec tr'.
Proof.
Admitted.

(** Task 3-3: Fibonacci sequence -- prove [fibonacci_ok] *)

Inductive fibonacci_spec : trace -> Prop :=
| Fs0: fibonacci_spec nil
| Fs1: fibonacci_spec [Out 1]
| Fs2: fibonacci_spec [Out 1; Out 1]
| Fsn:
    forall x y tr,
      fibonacci_spec (Out y :: Out x :: tr) ->
      fibonacci_spec (Out (x + y) :: Out y :: Out x :: tr).

Example fibonacci (n: nat) :=
  ("cnt" <- 0;;
   "x" <- 0;;
   "y" <- 1;;
   output "y";;
   {{ fun _ _ _ => True }} (* It is allowed to change this loop invariant for
                            * your easy proof!
                            *)
   while "cnt" < n loop
     "tmp" <- "y";;
     "y" <- "x" + "y";;
     "x" <- "tmp";;
     "cnt" <- "cnt" + 1;;
     output "y"
   done)%cmd.

Theorem fibonacci_ok (n: nat):
  forall tr h v tr' h' v',
    exec tr h v (fibonacci n) tr' h' v' ->
    tr = nil ->
    fibonacci_spec tr'.
Proof.
Admitted.


(** * Task 4: Implement your own program to verify. *)

(* The last task is to implement your own program and to verify its correctness
 * using Hoare logic. You may feel that the three examples we provided were 
 * nothing to do with [heap]. Design a program that employes the heap structure,
 * and prove its correctness.
 *)

(** Define your own program and prove its correctness here! *)
