@abstract class_name PathFinder extends Node
## Abstract algorithm class for finding paths on a [Graph]

## Finds path between two [Vertex] nodes on a [Graph]
@abstract func find_path(start : Vertex, target : Vertex, graph : Graph) -> Array[Vertex]
