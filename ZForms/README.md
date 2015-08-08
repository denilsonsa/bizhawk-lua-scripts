ZForms
======

A Lua wrapper around BizHawk's `forms` module.

Why?
----

Building user interfaces is annoying and time-consuming. It shouldn't be like this. It should be faster, easier, and more fun!

Objectives:

* Use object-oriented approach to building UI in BizHawk Lua scripts.
* Provide an API that should be...
    * more intuitive,
    * easier to use,
    * easier to understand,
    * easier to write.
* Provide convenience functions/methods/behavior when appropriate.
* Automatically calculate positions and sizes, when desired and when possible.
* Encourage people to build UIs for their scripts.
* Encourage people to modify and expand ZForms.

Why the name ZForms? Just because it is an easy and short name, and because Z is a shorter version of "EZ", which sounds like "easy".

API Documentation
-----------------

### Including the module

Make sure `ZForms.lua` file is in the same directory as your Lua script. Then just add the following code to your script:

```lua
    Z = require("ZForms")
```

If you don't want the `Z` variable in the global scope, you can add the `local` keyword:

```lua
    local Z = require("ZForms")
```

If you make changes to `ZForms.lua` file, those changes won't be visible until you reload the module. You can force reloading it by writing:

```lua
    -- Only required if you modify ZForms.lua.
    package.loaded["ZForms"] = nil
    local Z = require("ZForms")
```

If you want to store `ZForms.lua` inside a subdirectory, use the dot syntax:

```lua
    -- The file is located at "./foo/bar/ZForms.lua".
    local Z = require("foo.bar.ZForms")
```

### Basic concepts

Each UI element is a Lua object of a certain Lua class (both classes and objects are implemented using Lua tables).

Some UI elements are *widgets*  that are mapped to .Net objects. Other elements are implemented purely in Lua (such as `Z.Stacking` or `Z.Spacer`).

The constructor for each UI object receives a single parameter: a Lua table defining the object. This Lua table is usually defined inline, and sometimes contains definitions for children elements, making the whole definition look like a JSON object (but it is written using Lua syntax). This definition is designed to be powerful and concise at the same time.

UI widgets that are mapped to .Net objects usually have access to properties of the underlying .Net object. For convenience, such properties are implemented as methods that receive one optional parameter (a design inspired by jQuery APIs). They can be used like this:

```lua
    -- Retrieves the current title from the Form.
    print(myform:Title())
    -- Sets a new title.
    myform:Title("New title")
    -- It is possible to set and get the title in the same call.
    print(myform:Title("Yet another title"))
```

By Lua convention, methods are just functions that receive the instance as the first parameter. This parameter is implicitly defined as `self` when using the `function object:method(param1)` notation, or explicitly defined when using `object.method = function(self, param1)` notation.

Again, by the same Lua convention, calling a method using `:` (colon) implicitly passes the object instance as the first parameter. This means that `instance:method(foo)` is the same as `instance.method(instance, foo)`. In other words, always use `:` (colon) when calling methods and never again worry about it.

Some objects are responsible for defining the layout of other objects. So far, `Z.Stacking` is implemented, but other layout managers should be implemented in the future.

### Common attributes and methods

#### Common definition attributes

* `x`, `y`, `width`, `height` = Mostly optional, as default values are automatically set. Required for fine-tuning (such as when fitting a long text to a label).
* `id` = String that identifies a single UI object.
* `data` = Placeholder for any custom data (it is not used by ZForms module). Can be used for whatever purpose, such as having a single *onclick* handler on several buttons.
* `enabled` = Optional boolean, the widget will be disabled if set to false.
* `visible` = Optional boolean, the widget will be invisible if set to false.
* `tabindex` = Optional integer specifying its tab order (i.e. the order when the user presses the Tab key). Not used for forms or labels.

#### Common instance methods

* `:get(prop)` - Calls `forms.getproperty()` to retrieve the value of the specified .Net property, returns a string. You should probably use the specific methods instead (such as `:Text()` or `:Left()`).

* `:set(prop, value)` - Calls `forms.setproperty()` to set the value of the specified .Net property. You should probably use the specific methods instead (such as `:Text()` or `:Left()`).
* `:setlocation()` - Calls `forms.setlocation()` passing `self.x` and `self.y`. Optionally receives `x` and `y` as parameters and update `self.x` and `self.y` values. You shouldn't need to call this, unless you are dynamically relocating a widget.
* `:setsize()` - Calls `forms.setsize()` passing `self.width` and `self.height`. Optionally receives `width` and `height` as parameters and update `self.width` and `self.height` values. You shouldn't need to call this, unless you are dynamically resizing a widget.
* `:update_coords(x, y, available_width, available_height)` - Used internally, should not be used unless you are dynamically changing sizes and positions. TODO: Explain this.
* `build(form_handle)` - Used internally to create the .Net widgets. You should not call this manually, unless you really know what you are doing.

#### Common instance properties

* `:Left()`, `:Right()`, `:Top()`, `:Bottom()` - Position of each edge. (integer)
* `:Width()`, `:Height()` - Size of the widget (for the form window, it is the external size, including the borders and titlebar). (integer)
* `:Enabled()` - Defines if the widget will be enabled (can respond to user interaction) or disabled. (boolean)
* `:Visible()` - Defines if the widget will be visible or hidden. (boolean)
* `:TabIndex()` - A number specifying its tab order (i.e. the order when the user presses the Tab key). (integer)
* `:UseWaitCursor()` - Shows the hourglass (busy) mouse cursor when the pointer is on top of this widget. (boolean)

### Z.Form

Defines a form window, which will contain all other UI elements.

```lua
    myform = Z.Form({
      type = "form",
      child = { ... },
    })
```

#### Z.Form definition attributes

* `type` = Must be `"form"`.
* `child` = Must be a definition of another widget. Usually, it is a `Z.Stacking` definition.
* `title` = Optional window title, as string.
* `where` = Optional form location, relative to the main BizHawk window. Search for `Z.Form.where` at `ZForms.lua` for details, or just look at `demo_form_where.lua`.
* `default_width`, `default_height` = Optional integers for the default window size. When possible, the ZForm module will try to automatically calculate the dimensions to fit all children.
* `controlbox` = Optional boolean, if false the icon and the buttons will be removed from the title bar.
* `showicon` = Optional boolean, if true there will be an icon at the title bar. ZForms sets this to false by default.
* `topmost` = Optional boolean, sets this form window always-on-top.

#### Z.Form instance methods

* `:destroy()` - Closes the form window. After the form is destroyed, you must not call any other method on the form object, nor access any of the children. Doing so is undefined behavior.

#### Z.Form instance properties

* `:Title()` or `:Text()` - Title of the form window. (string)
* `:ControlBox()` - Shows or hides the icon and the buttons from the title bar. (boolean)
* `:ShowIcon()` - Shows or hides the icon from the title bar. (boolean)
* `:TopMost()` - Sets the form window always-on-top of other windows. (boolean)

### Z.Stacking

Layout manager that places the children elements vertically after each other. Their width will be expanded to the maximum available width. The height will be automatically calculated. If you are familiar with HTML and CSS, it is similar to `display: block`.

```lua
    {
      type = "stacking",
      children = {
        { ... },
        { ... },
        { ... },
      },
    }
```

#### Z.Stacking definition attributes

* `type` = Must be `"stacking"`.
* `children_default_height` = Optional integer, defines the default height for children elements that don't have any height defined.
* `children` = Must be a list of definitions of children elements.

### TODO!

* Document:
    * Checkbox, Button, Label, Spacer
* Implement:
    * Storing the `id` of each element in a convenient place.
    * Absolute layout manager.
    * MAYBE side-by-side layout.
    * MAYBE grid layout.
    * Dropdown widget.
    * Other widgets?
    * More demos!

.Net properties and type conversions
------------------------------------

It is not possible to set the value of a .Net property of the following types:

* `Appearance`
* `CheckState`
* `ContentAlignment`
* `FormBorderStyle`
* `Color`
* `Cursor`
* `FlatStyle`
* `Font`
* Any other non-primitive type (including enums)

This affects the following properties:

* `Appearance`
* `BackColor`, `ForeColor`
* `CheckState`
* `Cursor`
* `FlatStyle`
* `Font`
* `FormBorderStyle`
* `TextAlign`
* Possibly others

Trying to set such properties will throw the following exception:

> An exception of type 'System.InvalidCastException' occurred in mscorlib.dll but was not handled in user code

If anyone wants to lift this limitation in BizHawk, look for [`SetProperty()` method in `EmuLuaLibrary.forms.cs`](https://github.com/TASVideos/BizHawk/blob/64126fbad/BizHawk.Client.EmuHawk/tools/Lua/Libraries/EmuLuaLibrary.Forms.cs#L489), also look at `demo_property_types.lua`. Not all of these properties are extremely useful, though.
