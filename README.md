
# Overview

`CustomScrolling` is a sample iOS application to implement two manual scrolling layouts.
Each layout expands `currently centered` item and keeps all others collapsed.

The first layout only resizes views.

The second layout also makes sure `currently centered` item is always at the center.

# Preview

Here's how the application looks like:

![Preview][preview]

# SampleView XIB

![XIB structure][xib-structure]

`SampleView` contains two prominent `UIView`s:

* `ItemsView`
    * is parent to generated views representing items
* `GestureView`
    * gets `UIPanGestureRecognizer` installed at the start
    * is located closer to the user than `ItemsView` to intercept all gestures

# Structure overview

### Prominent top level directories

* `App/`
    * code specific to this application
* `External/`
    * code shared among different applications

### `App/` structure

* `App/AppDelegate.swift`
    * instantiates `SampleCoordinator`
    * creates `UIWindow` and sets its `rootViewController`
* `App/SimpleCallback.swift`
    * provides parameterless callback used for reporting
* `App/Sample/SampleCoordinator.swift`
    * creates `SampleView` instances for each layout
    * creates `UIViewController` and `UINavigationController` for each `SampleView`
    * creates `UITabBarController`
    * provides stub items to display
    * provides viewport and item heights
* `App/Sample/SampleView.swift`
    * configures scrolling with `Scrolling`, `ScrollingBounds`, and `UIPanGestureRecognizer`
    * accepts items to display
    * generates views for each item
    * invokes external layout function through `layoutReport` callback
* `App/Sample/Item.swift`
    * provides structure for storing item's id, title, and color
* `App/Sample/Layout01.swift`
    * provides `layViewsOut01` function to perform laying out each scrolling change
    * only resizes views
* `App/Sample/Layout02.swift`
    * provides `layViewsOut02` function to perform laying out each scrolling change
    * resizes views and makes sure `currently centered` item is always at the center

### `External/` files in use

* `External/Scrolling.swift`
    * accepts `UIView` to track pan gestures at
    * installs `UIPanGestureRecognizer` to the tracked view
    * reports vertical scrolling delta and velocity
* `External/ScrollingBounds.swift`
    * has viewport and content concepts
    * restricts scrolling to make content stay inside viewport 
    * only works when content's height is greater than viewport's one
* `External/UIView+Embed.swift`
    * provides `embeddedView` property extension to `UIView` classes
    * snaps child `UIView` to parent (host) `UIView` with constraints
* `External/UIView+NibFile.swift`
    * provides `loadFromNib` function extension to `UIView` classes
    * loads `UIView` derivative instance from `XIB`
* `External/UIViewControllerTemplate.swift`
    * creates `UIViewController` instance
    * accepts `UIView` to host and display

[preview]: readme/preview.gif
[xib-structure]: readme/xib-structure.png
