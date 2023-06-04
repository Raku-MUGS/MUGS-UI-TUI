# Client-Side TUI Graphing

Ideas for doing client-side graphing (for e.g. lag times, frame times, etc.)
clearly and efficiently (in both cost and screen real estate) in a TUI.


## Smoke Graphs

Make every graph a smoke graph.  Redraw each data row (for vertical graphs) or
column (for horizontal graphs) up to max-smoke-color-resolution times before
moving data front forward.  Allow the user to specify that they want to move
time forward even slower as well, either saturating at max color or dividing
color by slowdown (potentially rounding up so as to make a single data point at
least barely visible).


## Vertical Graphs

Instead of drawing graphs with time moving horizontally -- and thus requiring
redrawing multiple disconnected columns of pixels for the different graphs
during each frame -- draw them vertically, so that (assuming they are kept in
sync), refreshing a single screen row can update all graphs at once.


## Small Multiples

Each graph can be relatively small, because of the vertical smoke graph style.
Improve this by having no individual bottom or top caps, sharing any common
scale bars, and spacing the graphs with a wavefront indicator line (so that
graph space doesn't need to be wasted on that).

With this design, 4 screen rows give 8 vertical pixels; with color resolution
of e.g. 16, this allows 128 data points before looping (or 112 for the 7
currently static pixel rows plus the currently updating pixel row).  At 30fps,
this is around 4 seconds per loop, which seems in the range of "informative but
not horribly distracting".


## Alternate Scalings

In addition to linear and logarithmic data scaling, consider something in
between such as square root scaling (or in general x**(1/N) scaling).  This
would allow a wider input data variation without completely visually squashing
the top data values into a flat line.


## Track Jitter

Some data is shown better not as a flat value, but as the jitter around the
expected (or average) value.  Perhaps red for negative, blue for positive
jitter?  Or draw a centerline (or moving average line) and show the jitter
around that?
