# Navigation Foundation

## Purpose
Provides a lightweight road-graph route query for the current open-world prototype.

## Scope
- Stores the current road intersection graph.
- Finds a route between the nearest road intersections.
- Returns world-space points for map presentation.

## Public API

    NavigationService.find_route(start_position, destination)

Returns `PackedVector3Array`. An empty array means no route was found.

## Dependencies
- Godot 4.x.
- Built-in `AStar2D`.
- No external module dependency.

## Current graph
The graph uses the existing road axes:
- X: -65, 0, 65
- Z: -90, -12, 70

## Limitations
- This is a route-preview foundation, not character path-following.
- Start and destination are snapped to the nearest intersection.
- It does not yet model one-way roads, traffic, road closures, sidewalks,
  building entrances, or obstacle-aware local navigation.
- Road graph coordinates must be updated when the map road layout changes.

## Verification
Open the project in Godot Android and check for parser errors.
Then open the full map and tap a destination to inspect the route preview.
