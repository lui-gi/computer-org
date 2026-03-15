Insertion sort is a simple sorting algorithm that iteratively inserts each element of an unsorted list into
its correct position within the sorted portion of the list.
The algorithm of Insertion sort is described as follows:
Algorithm 1 Insertion Sort
Require: Array A of length n
Ensure: A is sorted in non-decreasing order
1: for i ← 2 to n do
2: key ← A[i]
3: j ← i − 1
4: while j > 0 and A[j] > key do
5: A[j + 1] ← A[j]
6: j ← j − 1
7: end while
8: A[j + 1] ← key
9: end for
Implement the algorithm above using the RISC-V RV32I instruction set. The starter code, insertion_sort.s
is provided.