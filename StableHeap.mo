/// Priority Queue
///
/// This module provides purely-functional priority queue based on leftist heap

import O "Order";
import P "Prelude";
import L "List";
import I "Iter";

module {

    private type Tree<T> = ?(Int, T, Tree<T>, Tree<T>);

    public func default() : Tree<T>{
        var heap : Tree<T> = null;
        heap
    };

    /// Insert an element to the heap
    public func put(
        heap : Tree<T>,
        x : T,
        ord : (T, T) -> O.Order
        ) : Tree<T> {
            heap := merge(heap, ?(1, x, null, null), ord);
            heap
    };

    /// Return the minimal element
    public func peekMin(
        heap : Tree<T>,
        ord : (T, T) -> O.Order
        ) : ?T {
        switch heap {
            case (null) { null };
            case (?(_, x, _, _)) { ?x };
        }
    };

    /// Delete the minimal element
    public func deleteMin(
        heap : Tree<T>,
        ord : (T, T) -> O.Order
        ) {
        switch heap {
            case null {};
            case (?(_, _, a, b)) { heap := merge(a, b, ord) };
        }
    };

    /// Remove the minimal element and return its value
    public func removeMin(
        heap : Tree<T>,
        ord : (T, T) -> O.Order
        ) : ?T {
        switch heap {
            case null { null };
            case (?(_, x, a, b)) {
                heap := merge(a, b, ord);
                ?x
            };
        }
    };

    /// Convert iterator into a heap in O(N) time.
    public func fromIter<T>(iter : I.Iter<T>, ord : (T, T) -> O.Order) : Heap<T> {
        let heap = Heap<T>(ord);
        func build(xs : L.List<Tree<T>>) : Tree<T> {
            func join(xs : L.List<Tree<T>>) : L.List<Tree<T>> {
                switch(xs) {
                    case (null) { null };
                    case (?(hd, null)) { ?(hd, null) };
                    case (?(h1, ?(h2, tl))) { ?(merge(h1, h2, ord), join(tl)) };
                }
            };
            switch(xs) {
                case null { P.unreachable() };
                case (?(hd, null)) { hd };
                case _ { build(join(xs)) };
            };
        };
        let list = I.toList(I.map(iter, func (x : T) : Tree<T> { ?(1, x, null, null) } ));
        if (not L.isNil(list)) {
            let t = build(list);
            heap.unsafeUnshare(t);
        };
        heap
    };

    func rank<T>(heap : Tree<T>) : Int {
        switch heap {
            case null { 0 };
            case (?(r, _, _, _)) { r };
        }
    };

    func makeT<T>(x : T, a : Tree<T>, b : Tree<T>) : Tree<T> {
        if (rank(a) >= rank(b)) {
            ?(rank(b) + 1, x, a, b)
        } else {
            ?(rank(a) + 1, x, b, a)
        };
    };

    func merge<T>(h1 : Tree<T>, h2 : Tree<T>, ord : (T, T) -> O.Order) : Tree<T> {
        switch (h1, h2) {
            case (null, h) { h };
            case (h, null) { h };
            case (?(_, x, a, b), ?(_, y, c, d)) {
                switch (ord(x,y)) {
                    case (#less) { makeT(x, a, merge(b, h2, ord)) };
                    case _ { makeT(y, c, merge(d, h1, ord)) };
                };
            };
        };
    };


}
