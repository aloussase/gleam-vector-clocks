import gleeunit
import gleeunit/should
import vector_clocks as vclock

pub fn main() {
  gleeunit.main()
}

pub fn example_test() {
  let a = vclock.fresh()
  let b = vclock.fresh()
  let a1 = vclock.increment("a", a)
  let b1 = vclock.increment("b", b)

  vclock.descends(a1, a) |> should.be_true
  vclock.descends(b1, b) |> should.be_true
  vclock.descends(a1, b1) |> should.be_false

  let a2 = vclock.increment("a", a1)
  let c = vclock.merge([a2, b1])
  let c1 = vclock.increment("c", c)

  vclock.descends(c1, a2) |> should.be_true
  vclock.descends(c1, b1) |> should.be_true
  vclock.descends(b1, c1) |> should.be_false
  vclock.descends(b1, a1) |> should.be_false
}

pub fn accessor_test() {
  todo
}

pub fn merge_test() {
  todo
}

pub fn merge_less_left_test() {
  todo
}

pub fn merge_less_right_test() {
  todo
}

pub fn merge_same_id_test() {
  todo
}

pub fn get_entry_test() {
  todo
}
