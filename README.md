# S5W Dial (QML)

This repository contains my work to port my [C++ Qt analog meter
widget](https://bitbucket.org/mpyne/dial-demo/) to use native QML instead. This
permits a much more efficient GPU-accelerated scene graph to be used (as long
as you have a GPU, but basically everyone does in 2021, even on mobile).

The result looks like this:

![Screenshot](screenshot.png)

You can see what it looks like in [video form](dial-video.mkv) as well.

## Synopsis

    $ make test    (this uses `qmlscene` to show 3 specific sensors as an example)

If you are using a KDE Plasma 5 system you can also install a Plasmoid widget
using this meter:

    $ make install_plasmoid

Once installed, you should be able to add an analog meter using the 'Add
Widgets' function in Plasma.  You will currently need to configure the widget
once you've dragged it onto your desktop to change the data source to use one
of the base KSysGuard sensors.

There are many available KSysGuard sensors. You can find their names by
running KSysGuard yourself and viewing its list of sensors. The names look like
some of these examples:

* `mem/physical/available`  (which lists available physical memory)
* `cpu/system/TotalLoad`    (which shows overall system load across all CPUs)

## Future Improvements

* Apparently the Plasma devs developed a way for sensors to have
  [interchangable visualizations in
  Plasma](https://store.kde.org/browse/cat/597/order/latest/).  I didn't know
  about that before I did this, so this Plasmoid doesn't support that.  It sure
  would be nice if someone figured out how to make that happen.
* The widget is not anti-aliased on Plasma for some reason that I can't figure
  out. In particular this really seems to make the text labels ugly even above
  and beyond what you would expect for merely being 'aliased' text, almost like
  it's drawn at a lower resolution and then scaled up. This doesn't seem to
  affect the `qmlscene` based test for some reason.
* I should probably package this on store.kde.org at some point but I'm just
  trying to get this put into a git repo at this point.
