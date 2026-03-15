# ==============================================================================
# Task 2: Containment Graph - Questions
# CS 3210 - Lab 6
# Name: Fernandez
# ==============================================================================

# ==============================================================================
# Question 1: Can the containment graph become cyclic? Prove or disprove.
# ==============================================================================
#
# ANSWER: No, the containment graph cannot become cyclic.
#
# PROOF:
#
# Assume for contradiction that a cycle exists: A -> B -> ... -> A
#
# By the containment rule, an edge from node A to node B exists if and only if:
#   A.x <= B.x  AND  A.y <= B.y
#
# For a cycle to exist, we would need a path from A back to A:
#   A -> B -> C -> ... -> A
#
# This means:
#   A.x <= B.x <= C.x <= ... <= A.x
#   A.y <= B.y <= C.y <= ... <= A.y
#
# For the cycle to close (return to A), we need the last node to connect to A:
#   last.x <= A.x  AND  last.y <= A.y
#
# Combined with A.x <= ... <= last.x, this means A.x = last.x (and all between)
# Combined with A.y <= ... <= last.y, this means A.y = last.y (and all between)
#
# Therefore, ALL nodes in the cycle must have identical (x, y) coordinates.
# But if two nodes have the same coordinates, they are the same point.
# Since we skip self-loops (i != j check), no edge exists between identical points.
#
# CONTRADICTION: A cycle cannot exist.
#
# The containment graph is a Directed Acyclic Graph (DAG).
#
# ==============================================================================

# ==============================================================================
# Question 2: What is the maximum number of branches that a node can have?
# ==============================================================================
#
# ANSWER: n - 1 (where n is the total number of nodes)
#
# EXPLANATION:
#
# A node can have outgoing edges to ALL other nodes in the graph, except itself
# (since self-loops are not allowed).
#
# The maximum occurs when a node has coordinates (x, y) such that:
#   x <= x_j  AND  y <= y_j  for all other nodes j
#
# This happens when the node is at the "minimum" position - i.e., it has the
# smallest x and smallest y coordinates among all nodes.
#
# Example: A node at (0, 0) in a grid where all other nodes have positive
# coordinates will have edges to every other node.
#
# In the test cases:
#   - Node i at (0, 0) always has the maximum number of outgoing edges
#   - Case 1 (n=4): i has 3 outgoing edges (to f, e, j)
#   - Case 2 (n=4): i has 3 outgoing edges (to e, h, j)
#   - Case 3 (n=6): i has 5 outgoing edges (to f, g, e, h, j)
#   - Case 4 (n=6): i has 5 outgoing edges (to f, l, e, h, j)
#
# Therefore, the maximum number of branches = n - 1
#
# ==============================================================================
