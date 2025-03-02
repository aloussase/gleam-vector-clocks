/// Adapted from: https://github.com/basho/riak_core/blob/develop/src/vclock.erl
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string

pub type Vclock =
  List(Dot)

pub type Node =
  String

pub type Dot {
  Dot(node: Node, counter: Int)
}

pub fn fresh() -> Vclock {
  []
}

pub fn descends(va: Vclock, vb: Vclock) -> Bool {
  case va, vb {
    _, [] -> True
    _, [Dot(node_b, ctr_b), ..rest] -> {
      case
        list.find(va, fn(a) {
          let Dot(node_a, _ctr_a) = a
          node_a == node_b
        })
      {
        Ok(Dot(_node_a, ctr_a)) -> ctr_a >= ctr_b && descends(va, rest)
        _ -> False
      }
    }
  }
}

pub fn merge(vclocks: List(Vclock)) -> Vclock {
  case vclocks {
    [] -> []
    [vclock] -> vclock
    [vclock, ..rest] ->
      merge2(
        rest,
        vclock
          |> list.sort(fn(a, b) { int.compare(a.counter, b.counter) }),
      )
  }
}

fn merge2(vclocks: List(Vclock), vclock: Vclock) -> Vclock {
  case vclocks, vclock {
    [], _ -> vclock
    [aclock, ..rest], _ ->
      merge2(
        rest,
        merge3(
          aclock
            |> list.sort(fn(a, b) { int.compare(a.counter, b.counter) }),
          vclock,
          [],
        ),
      )
  }
}

fn merge3(v, n, acc) -> Vclock {
  case v, n {
    [], [] -> acc |> list.reverse
    [], n -> acc |> list.append(n) |> list.reverse
    v, [] -> acc |> list.append(v) |> list.reverse
    [Dot(node_v, ctr1) as nct1, ..rest_v], [Dot(node_n, ctr2) as nct2, ..rest_n]
    -> {
      case string.compare(node_v, node_n) {
        order.Lt -> merge3(rest_v, n, [nct1, ..acc])
        order.Gt -> merge3(v, rest_n, [nct2, ..acc])
        order.Eq -> {
          let ct = case int.compare(ctr1, ctr2) {
            order.Lt -> nct2
            order.Gt -> nct1
            // NOTE: Here we would use "last write wins", but we are not keeping
            // track of timestamps.
            order.Eq -> nct1
          }
          merge3(rest_v, rest_n, [ct, ..acc])
        }
      }
    }
  }
}

pub fn increment(node: Node, vclock: Vclock) -> Vclock {
  let new_dot =
    list.find_map(vclock, fn(dot) {
      let Dot(node_, ctr) = dot
      case node == node_ {
        True -> Ok(Dot(node, ctr + 1))
        _ -> Error(Nil)
      }
    })
    |> result.unwrap(Dot(node, 1))

  let new_vclock = list.filter(vclock, fn(dot) { dot.node != node })

  [new_dot, ..new_vclock]
}
