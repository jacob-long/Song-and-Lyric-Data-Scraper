# require 'tk'
# require 'tkextlib/tile'
# root = TkRoot.new
#
# content = Tk::Tile::Frame.new(root) {padding "3 3 12 12"}
# frame = Tk::Tile::Frame.new(content) {borderwidth 5; relief "sunken"; width 200; height 100}
# namelbl = Tk::Tile::Label.new(content) {text "Name"}
# name = Tk::Tile::Entry.new(content)
# $option_one = TkVariable.new( 1 )
# one = Tk::Tile::CheckButton.new(content) {text "One"; variable $option_one; onvalue 1}
# $option_two = TkVariable.new( 0 )
# two = Tk::Tile::CheckButton.new(content) {text "Two"; variable $option_two; onvalue 1}
# $option_three = TkVariable.new( 1 )
# three = Tk::Tile::CheckButton.new(content) {text "Three"; variable $option_three; onvalue 1}
# ok = Tk::Tile::Button.new(content) {text "Okay"}
# cancel = Tk::Tile::Button.new(content) {text "Cancel"}
#
# content.grid :column => 0, :row => 0, :sticky => 'nsew'
# frame.grid :column => 0, :row => 0, :columnspan => 3, :rowspan => 2, :sticky => 'nsew'
# namelbl.grid :column => 3, :row => 0, :columnspan => 2, :sticky => 'nw', :padx => 5
# name.grid :column => 3, :row => 1, :columnspan => 2, :sticky => 'new', :pady => 5, :padx => 5
# one.grid :column => 0, :row => 3
# two.grid :column => 1, :row => 3
# three.grid :column => 2, :row => 3
# ok.grid :column => 3, :row => 3
# cancel.grid :column => 4, :row => 3
#
# TkGrid.columnconfigure( root, 0, :weight => 1 )
# TkGrid.rowconfigure( root, 0, :weight => 1 )
# TkGrid.columnconfigure( content, 0, :weight => 3 )
# TkGrid.columnconfigure( content, 1, :weight => 3 )
# TkGrid.columnconfigure( content, 2, :weight => 3 )
# TkGrid.columnconfigure( content, 3, :weight => 1 )
# TkGrid.columnconfigure( content, 4, :weight => 1 )
# TkGrid.rowconfigure( content, 1, :weight => 1)
#
# Tk.mainloop

require 'tk'
require 'tkextlib/tile'

root = TkRoot.new
root.title = "Window"

n = Tk::Tile::Notebook.new(root)do
  height 110
  place('height' => 100, 'width' => 200, 'x' => 10, 'y' => 10)
end

f1 = TkFrame.new(n)
f2 = TkFrame.new(n)
f3 = TkFrame.new(n)

n.add f1, :text => 'One', :state =>'disabled'
n.add f2, :text => 'Two'
n.add f3, :text => 'Three'

Tk.mainloop