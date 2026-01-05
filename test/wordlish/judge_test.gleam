import gleeunit/should
import wordlish/judge.{Absent, Correct, Present, judge}

pub fn all_correct_test() {
  judge("HELLO", "HELLO")
  |> should.equal([
    #("H", Correct),
    #("E", Correct),
    #("L", Correct),
    #("L", Correct),
    #("O", Correct),
  ])
}

pub fn all_absent_test() {
  judge("ABCDE", "FGHIJ")
  |> should.equal([
    #("A", Absent),
    #("B", Absent),
    #("C", Absent),
    #("D", Absent),
    #("E", Absent),
  ])
}

pub fn mixed_results_test() {
  // C,R,A,E are correct positions, N is absent
  judge("CRANE", "CRATE")
  |> should.equal([
    #("C", Correct),
    #("R", Correct),
    #("A", Correct),
    #("N", Absent),
    #("E", Correct),
  ])
}

pub fn present_test() {
  // All letters exist but wrong positions
  judge("REACT", "CRATE")
  |> should.equal([
    #("R", Present),
    #("E", Present),
    #("A", Correct),
    #("C", Present),
    #("T", Present),
  ])
}

// --- Duplicate letter tests (Step 4) ---

pub fn duplicate_abate_apart_test() {
  // Both have 2 A's, both A's match positions
  // A[0] vs A[0]: Correct
  // B[1] vs P[1]: Absent
  // A[2] vs A[2]: Correct
  // T[3] vs R[3]: Present (T at position 4)
  // E[4] vs T[4]: Absent
  judge("ABATE", "APART")
  |> should.equal([
    #("A", Correct),
    #("B", Absent),
    #("A", Correct),
    #("T", Present),
    #("E", Absent),
  ])
}

pub fn duplicate_excess_test() {
  // EERIE has 3 E's, ELDER has 2 E's (position 0, 3)
  // E[0] vs E[0]: Correct → consume E[0]
  // E[1] vs L[1]: Present → consume E[3]
  // R[2] vs D[2]: Present
  // I[3] vs E[3]: Absent
  // E[4] vs R[4]: Absent (no E left!)
  judge("EERIE", "ELDER")
  |> should.equal([
    #("E", Correct),
    #("E", Present),
    #("R", Present),
    #("I", Absent),
    #("E", Absent),
  ])
}

// --- Edge cases (Step 5) ---

pub fn all_same_letter_correct_test() {
  judge("AAAAA", "AAAAA")
  |> should.equal([
    #("A", Correct),
    #("A", Correct),
    #("A", Correct),
    #("A", Correct),
    #("A", Correct),
  ])
}

pub fn all_same_letter_absent_test() {
  judge("AAAAA", "BBBBB")
  |> should.equal([
    #("A", Absent),
    #("A", Absent),
    #("A", Absent),
    #("A", Absent),
    #("A", Absent),
  ])
}

pub fn empty_strings_test() {
  judge("", "")
  |> should.equal([])
}
