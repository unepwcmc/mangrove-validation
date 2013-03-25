# Note on Backbone.ViewManager

You may be wondering why there is a `view_manager.js.coffee` and an
`old_view_manager.js.coffee`. The answer is, of course, the budget for
this project is currently very small and there is a bug that results in
nested ViewManagers not firing event bindings (such as clicks). For now,
the solution is to continue to use the previous ViewManager in the
IslandRouter, and use the new ViewManager version in the IslandView (to
solve a synchronicity issue).

Godspeed.
