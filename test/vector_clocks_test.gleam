import argv
import gleam/io
import gleeunit
import gleeunit/should
import vector_clocks as vclock

pub fn main() {
  gleeunit.main()
}

pub fn example_test() {
  use <- test_filter("example_test")

  let a = vclock.fresh()
  let b = vclock.fresh()
  let a1 = vclock.increment(a, "a")
  let b1 = vclock.increment(b, "b")

  vclock.descends(a1, a) |> should.be_true
  vclock.descends(b1, b) |> should.be_true
  vclock.descends(a1, b1) |> should.be_false

  let a2 = vclock.increment(a1, "a")
  let c = vclock.merge([a2, b1])
  let c1 = vclock.increment(c, "c")

  vclock.descends(c1, a2) |> should.be_true
  vclock.descends(c1, b1) |> should.be_true
  vclock.descends(b1, c1) |> should.be_false
  vclock.descends(b1, a1) |> should.be_false
}

pub fn accessor_test() {
  use <- test_filter("accessor_test")

  let vc = [vclock.Dot("1", 1), vclock.Dot("2", 2)]

  vc |> vclock.get_counter("1") |> should.equal(1)
  vc |> vclock.get_counter("2") |> should.equal(2)
  vc |> vclock.get_counter("3") |> should.equal(0)
  vc |> vclock.all_nodes() |> should.equal(["1", "2"])
}

pub fn get_entry_test() {
  use <- test_filter("get_entry_test")

  let vc = vclock.fresh()
  let vc1 =
    vc
    |> vclock.increment("a")
    |> vclock.increment("b")
    |> vclock.increment("c")
    |> vclock.increment("a")

  vclock.get_dot(vc1, "a") |> should.equal(Ok(vclock.Dot("a", 2)))
  vclock.get_dot(vc1, "b") |> should.equal(Ok(vclock.Dot("b", 1)))
  vclock.get_dot(vc1, "c") |> should.equal(Ok(vclock.Dot("c", 1)))
  vclock.get_dot(vc1, "d") |> should.equal(Error(Nil))
}

pub fn merge_test() {
  use <- test_filter("merge_test")

  let v1 = [vclock.Dot("1", 1), vclock.Dot("2", 2), vclock.Dot("4", 4)]
  let v2 = [vclock.Dot("3", 3), vclock.Dot("4", 3)]

  vclock.merge([vclock.fresh()]) |> should.equal([])
  vclock.merge([v1, v2])
  |> should.equal([
    vclock.Dot("1", 1),
    vclock.Dot("2", 2),
    vclock.Dot("3", 3),
    vclock.Dot("4", 4),
  ])
}

pub fn merge_less_left_test() {
  use <- test_filter("merge_less_left_test")

  let v1 = [vclock.Dot("5", 5)]
  let v2 = [vclock.Dot("6", 6), vclock.Dot("7", 7)]

  vclock.merge([v1, v2])
  |> should.equal([vclock.Dot("5", 5), vclock.Dot("6", 6), vclock.Dot("7", 7)])
}

pub fn merge_less_right_test() {
  use <- test_filter("merge_less_right_test")

  let v1 = [vclock.Dot("6", 6), vclock.Dot("7", 7)]
  let v2 = [vclock.Dot("5", 5)]

  vclock.merge([v1, v2])
  |> should.equal([vclock.Dot("5", 5), vclock.Dot("6", 6), vclock.Dot("7", 7)])
}

fn test_filter(name: String, f: fn() -> Nil) -> Nil {
  case argv.load().arguments {
    ["--test-name-filter", test_name, ..] if test_name == name -> {
      io.println_error("Running test: " <> name)
      f()
    }
    ["--test-name-filter", _, ..] -> {
      io.println_error("Skipping test: " <> name)
      Nil
    }
    _ -> {
      io.println_error("Running test: " <> name)
      f()
    }
  }
}

fn skip(name: String, _f: fn() -> Nil) -> Nil {
  io.println_error("Skipping test: " <> name)
  Nil
}
